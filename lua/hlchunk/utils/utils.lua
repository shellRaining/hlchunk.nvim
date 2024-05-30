local ft = require("hlchunk.utils.ts_node_type")
local Scope = require("hlchunk.utils.scope")
local fn = vim.fn
local treesitter = vim.treesitter

-- these are helper function for utils

-- get the virtual indent of the given line
---@param rows_indent table<number, number>
---@param line number
---@return number
local function get_virt_indent(rows_indent, line)
    local cur = line + 1
    while rows_indent[cur] do
        if rows_indent[cur] == 0 then
            break
        elseif rows_indent[cur] > 0 then
            return rows_indent[cur]
        end
        cur = cur + 1
    end
    return -1
end

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

-- this is utils module for hlchunk every mod
-- every method in this module should return as follow
-- 1. return ret code, a enum value
-- 2. return ret value, a table or other something
local M = {}

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

---@enum CHUNK_RANGE_RETCODE
M.CHUNK_RANGE_RET = {
    OK = 0,
    CHUNK_ERR = 1,
    NO_CHUNK = 2,
    NO_TS = 3,
}

---@param pos Pos 0-index (row, col)
local function get_chunk_range_by_context(pos)
    local base_flag = "nWz"
    local cur_row_val = vim.api.nvim_buf_get_lines(pos.bufnr, pos.row, pos.row + 1, false)[1]
    local cur_char = string.sub(cur_row_val, pos.col, pos.col)

    local beg_row = fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or "")) --[[@as number]]
    local end_row = fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or "")) --[[@as number]]

    if beg_row <= 0 or end_row <= 0 or beg_row >= end_row then
        return M.CHUNK_RANGE_RET.NO_CHUNK, Scope(pos.bufnr, -1, -1)
    end

    -- TODO: fix this is_comment
    -- if is_comment(beg_row) or is_comment(end_row) then
    --     return M.CHUNK_RANGE_RET.NO_CHUNK, Scope(0, -1, -1)
    -- end

    return M.CHUNK_RANGE_RET.OK, Scope(pos.bufnr, beg_row - 1, end_row - 1)
end

---@param pos Pos 0-index for row, 0-index for col, API-indexing
local function get_chunk_range_by_treesitter(pos)
    if not has_treesitter(pos.bufnr) then
        return M.CHUNK_RANGE_RET.NO_TS, Scope(pos.bufnr, -1, -1)
    end

    local cursor_node = treesitter.get_node({
        ignore_injections = false,
        bufnr = pos.bufnr,
        pos = { pos.row, pos.col },
    })
    while cursor_node do
        local node_type = cursor_node:type()
        local node_start, _, node_end, _ = cursor_node:range()
        if node_start ~= node_end and is_suit_type(node_type) then
            return cursor_node:has_error() and M.CHUNK_RANGE_RET.CHUNK_ERR or M.CHUNK_RANGE_RET.OK,
                Scope(pos.bufnr, node_start, node_end)
        end
        cursor_node = cursor_node:parent()
    end
    return M.CHUNK_RANGE_RET.NO_CHUNK, Scope(pos.bufnr, -1, -1)
end

---@param opts? {pos: Pos, use_treesitter: boolean}
---@return CHUNK_RANGE_RETCODE enum
---@return Scope
function M.get_chunk_range(opts)
    opts = opts or { use_treesitter = false }

    if opts.use_treesitter then
        return get_chunk_range_by_treesitter(opts.pos)
    else
        return get_chunk_range_by_context(opts.pos)
    end
end

---@enum ROWS_INDENT_RETCODE
M.ROWS_INDENT_RETCODE = {
    OK = 0,
    NO_TS = 1,
}

function M.get_rows_indent_by_context(range)
    local begRow = range.start + 1
    local endRow = range.finish + 1

    local rows_indent = {}

    for i = endRow, begRow, -1 do
        rows_indent[i] = M.get_indent(range.bufnr, i - 1)
        if rows_indent[i] == 0 and #fn.getline(i) == 0 then
            rows_indent[i] = get_virt_indent(rows_indent, i) or -1
        end
    end

    return M.ROWS_INDENT_RETCODE.OK, rows_indent
end

function M.get_rows_indent_by_treesitter(range)
    local begRow = range.start + 1
    local endRow = range.finish + 1

    local rows_indent = {}
    local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
    if not ts_indent_status then
        return M.ROWS_INDENT_RETCODE.NO_TS, {}
    end

    for i = endRow, begRow, -1 do
        rows_indent[i] = vim.api.nvim_buf_call(range.bufnr, function()
            return ts_indent.get_indent(i)
        end)
    end

    return M.ROWS_INDENT_RETCODE.OK, rows_indent
end

-- when virt_indent is false, there are three cases:
-- 1. the row has nothing, we set the value to -1
-- 2. the row has char however not have indent, we set the indent to 0
-- 3. the row has indent, we set its indent
--------------------------------------------------------------------------------
-- when virt_indent is true, the only difference is:
-- when the len of line val is 0, we set its indent by its context, example
-- 1. hello world
-- 2.    this is shellRaining
-- 3.
-- 4.    this is shellRaining
-- 5.
-- 6. this is shellRaining
-- the virtual indent of line 3 is 4, and the virtual indent of line 5 is 0
---@param range Scope
---@param opts? {use_treesitter: boolean, virt_indent: boolean}
---@return ROWS_INDENT_RETCODE enum
---@return table<number, number>
function M.get_rows_indent(range, opts)
    opts = opts or { use_treesitter = false, virt_indent = false }

    if opts.use_treesitter then
        return M.get_rows_indent_by_treesitter(range)
    else
        return M.get_rows_indent_by_context(range)
    end
end

---@param bufnr number
---@param row number 0-index
function M.get_indent(bufnr, row)
    return vim.api.nvim_buf_call(bufnr, function()
        return fn.indent(row + 1)
    end)
end

return M
