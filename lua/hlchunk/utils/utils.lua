local ft = require("hlchunk.utils.filetype")
local fn = vim.fn
local treesitter = vim.treesitter
local ts_utils = require("nvim-treesitter.ts_utils")

-- these are helper function for utils

---@param bufnr number check the bufnr has treesitter parser
local function has_treesitter(bufnr)
    local ok = pcall(require, "nvim-treesitter")
    if not ok then
        return false
    end

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

---@param line? number
local function is_comment(line)
    line = line or fn.line(".")

    local str = fn.getline(line)
    str:trim()
    return str:match("^%-%-[^\r\n]*$") ~= nil
        or string.match(str, "^%s*/%*.-%*/%s*$") ~= nil
        or string.match(str, "^%s*//.*$") ~= nil
end

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

-- this is utils module for hlchunk every mod
-- every method in this module should pass arguments as follow
-- 1. mod: BaseMod, for utils function to get mod options
-- 2. normal arguments
-- 3. opts: for utils function to get options specific for this function
local M = {}

---@param mod BaseMod
---@param line? number the line number we want to get the chunk range
---@param opts? {use_treesitter: boolean}
---@return table<number, number> | nil
function M.get_chunk_range(mod, line, opts)
    opts = opts or { use_treesitter = false }
    line = line or fn.line(".")

    local beg_row, end_row

    if opts.use_treesitter then
        if not has_treesitter(0) and mod.options.notify then
            vim.notify_once("[hlchunk]: not have parser for " .. vim.bo.filetype)
            return nil
        end

        local cursor_node = ts_utils.get_node_at_cursor()
        -- TODO: refact this statement
        while cursor_node do
            local node_type = cursor_node:type()
            local node_start, _, node_end, _ = cursor_node:range()
            if node_start ~= node_end then
                if vim.bo.ft == "cpp" then
                    if ft.cpp_pattern[node_type] then
                        return { node_start + 1, node_end + 1 }
                    end
                elseif vim.bo.ft == "lua" then
                    if ft.lua_pattern[node_type] then
                        return { node_start + 1, node_end + 1 }
                    end
                end
                for _, rgx in ipairs(ft.type_patterns) do
                    if node_type:find(rgx) then
                        return { node_start + 1, node_end + 1 }
                    end
                end
            end
            cursor_node = cursor_node:parent()
        end
        return nil
    else
        local base_flag = "nWz"
        local cur_row_val = fn.getline(line)
        local cur_col = fn.col(".")
        local cur_char = string.sub(cur_row_val, cur_col, cur_col)

        beg_row = fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
        end_row = fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

        if beg_row <= 0 or end_row <= 0 then
            return nil
        end

        if is_comment(beg_row) or is_comment(end_row) then
            return nil
        end

        return { beg_row, end_row }
    end
end

---@param mod BaseMod
---@param line? number the line number we want to get the indent range
---@param opts? {use_treesitter: boolean}
---@return table<number, number> | nil not include end point
function M.get_indent_range(mod, line, opts)
    line = line or fn.line(".")
    opts = opts or { use_treesitter = false }

    local rows_indent_list = M.get_rows_indent(mod, nil, nil, {
        use_treesitter = opts.use_treesitter,
        virt_indent = true,
    })
    if not rows_indent_list or rows_indent_list[line] < 0 then
        return nil
    end

    local shiftwidth = fn.shiftwidth()
    if rows_indent_list[line + 1] and rows_indent_list[line + 1] == rows_indent_list[line] + shiftwidth then
        line = line + 1
    elseif rows_indent_list[line - 1] and rows_indent_list[line - 1] == rows_indent_list[line] + shiftwidth then
        line = line - 1
    end

    if rows_indent_list[line] <= 0 then
        return nil
    end

    local up = line
    local down = line
    local wbegin = fn.line("w0")
    local wend = fn.line("w$")

    while up >= wbegin and rows_indent_list[up] >= rows_indent_list[line] do
        up = up - 1
    end
    while down <= wend and rows_indent_list[down] >= rows_indent_list[line] do
        down = down + 1
    end
    up = math.max(up, wbegin)
    down = math.min(down, wend)

    return { up + 1, down - 1 }
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
---@param mod BaseMod
---@param begRow? number
---@param endRow? number
---@param opts? {use_treesitter: boolean, virt_indent: boolean}
---@return table<number, number> | nil
function M.get_rows_indent(mod, begRow, endRow, opts)
    begRow = begRow or fn.line("w0")
    endRow = endRow or fn.line("w$")
    opts = opts or { use_treesitter = false, virt_indent = false }

    local rows_indent = {}
    local get_indent = fn.indent
    if opts.use_treesitter then
        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status and mod.options.notify then
            vim.notify_once("[hlchunk.indent]: nvim-treesitter loaded fail")
            return nil
        end
        get_indent = function(row)
            return ts_indent.get_indent(row) or 0
        end
    end

    for i = endRow, begRow, -1 do
        rows_indent[i] = get_indent(i)
        if (not opts.use_treesitter) and rows_indent[i] == 0 and #fn.getline(i) == 0 then
            rows_indent[i] = opts.virt_indent and get_virt_indent(rows_indent, i) or -1
        end
    end

    return rows_indent
end

function M.col_in_screen(col)
    local leftcol = vim.fn.winsaveview().leftcol
    return col >= leftcol
end

return M
