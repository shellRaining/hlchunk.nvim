local treesitter = vim.treesitter
local fn = vim.fn
local Scope = require("hlchunk.utils.scope")
local ft = require("hlchunk.utils.ts_node_type")

local function is_suit_type(node_type)
    local is_spec_ft = ft[vim.bo.ft]
    if is_spec_ft then
        return is_spec_ft[node_type] and true or false
    end

    for _, rgx in ipairs(ft.default) do
        if node_type:find(rgx) then
            return true
        end
    end
    return false
end

---@param bufnr number check the bufnr has treesitter parser
local function has_treesitter(bufnr)
    local has_lang, lang = pcall(treesitter.language.get_lang, vim.bo[bufnr].filetype)
    if not has_lang then
        return false
    end

    local has, parser = pcall(treesitter.get_parser, bufnr, lang)
    if not has or not parser then
        return false
    end
    return true
end

local chunkHelper = {}

---@enum CHUNK_RANGE_RETCODE
chunkHelper.CHUNK_RANGE_RET = {
    OK = 0,
    CHUNK_ERR = 1,
    NO_CHUNK = 2,
    NO_TS = 3,
}

---@param pos HlChunk.Pos 0-index (row, col)
local function get_chunk_range_by_context(pos)
    local base_flag = "nWz"
    local cur_row_val = vim.api.nvim_buf_get_lines(pos.bufnr, pos.row, pos.row + 1, false)[1]
    local cur_char = string.sub(cur_row_val, pos.col + 1, pos.col + 1)

    local beg_row = fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or "")) --[[@as number]]
    local end_row = fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or "")) --[[@as number]]

    if beg_row <= 0 or end_row <= 0 or beg_row >= end_row then
        return chunkHelper.CHUNK_RANGE_RET.NO_CHUNK, Scope(pos.bufnr, -1, -1)
    end

    return chunkHelper.CHUNK_RANGE_RET.OK, Scope(pos.bufnr, beg_row - 1, end_row - 1)
end

---@param pos HlChunk.Pos 0-index for row, 0-index for col, API-indexing
local function get_chunk_range_by_treesitter(pos)
    if not has_treesitter(pos.bufnr) then
        return chunkHelper.CHUNK_RANGE_RET.NO_TS, Scope(pos.bufnr, -1, -1)
    end

    local cursor_node = treesitter.get_node({
        ignore_injections = false,
        bufnr = pos.bufnr,
        pos = { pos.row, pos.col },
    })
    -- when cursor_node is comment content (source), we should find by tree
    if cursor_node and cursor_node:type() == "source" then
        cursor_node = treesitter.get_node({
            bufnr = pos.bufnr,
            pos = { pos.row, pos.col },
        })
    end
    while cursor_node do
        local node_type = cursor_node:type()
        local node_start, _, node_end, _ = cursor_node:range()
        if node_start ~= node_end and is_suit_type(node_type) then
            return cursor_node:has_error() and chunkHelper.CHUNK_RANGE_RET.CHUNK_ERR or chunkHelper.CHUNK_RANGE_RET.OK,
                Scope(pos.bufnr, node_start, node_end)
        end
        local parent_node = cursor_node:parent()
        if parent_node == cursor_node then
            break
        end
        cursor_node = parent_node
    end
    return chunkHelper.CHUNK_RANGE_RET.NO_CHUNK, Scope(pos.bufnr, -1, -1)
end

---@param opts? {pos: HlChunk.Pos, use_treesitter: boolean}
---@return CHUNK_RANGE_RETCODE enum
---@return HlChunk.Scope
function chunkHelper.get_chunk_range(opts)
    opts = opts or { use_treesitter = false }

    if opts.use_treesitter then
        return get_chunk_range_by_treesitter(opts.pos)
    else
        return get_chunk_range_by_context(opts.pos)
    end
end

function chunkHelper.calc(str, col, leftcol)
    local len = vim.api.nvim_strwidth(str)
    if col < leftcol then
        local byte_idx = math.min(leftcol - col, len)
        local utf_beg = vim.str_byteindex(str, byte_idx)
        str = str:sub(utf_beg + 1)
    end

    col = math.max(col - leftcol, 0)

    return str, col
end

function chunkHelper.utf8Split(inputstr)
    local list = {}
    for uchar in string.gmatch(inputstr, "[^\128-\191][\128-\191]*") do
        table.insert(list, uchar)
    end
    return list
end

---@param i number
---@param j number
---@return table
function chunkHelper.rangeFromTo(i, j, step)
    local t = {}
    step = step or 1
    for x = i, j, step do
        table.insert(t, x)
    end
    return t
end

function chunkHelper.shallowCmp(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    local flag = true
    for i, v in ipairs(t1) do
        if t2[i] ~= v then
            flag = false
            break
        end
    end
    return flag
end

return chunkHelper
