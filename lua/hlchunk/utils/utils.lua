---@diagnostic disable: param-type-mismatch
local M = {}

local fn = vim.fn

---@param line? number the line number we want to get the chunk range
---@return table<number, number> | nil
function M.get_chunk_range(line)
    line = line or fn.line(".")

    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = fn.getline(line)
    local cur_col = fn.col(".")
    local cur_char = string.sub(cur_row_val, cur_col, cur_col)

    beg_row = fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
    end_row = fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

    if beg_row <= 0 or end_row <= 0 then
        return nil
    end

    return { beg_row, end_row }
end

---@param line? number the line number we want to get the indent range
---@return table<number, number> | nil
function M.get_indent_range(line)
    line = line or fn.line(".")

    local rows_indent_list = M.get_rows_indent(nil, nil, { use_treesitter = false, virt_indent = true })
    if not rows_indent_list then
        return nil
    end
    if rows_indent_list[line] < 0 then
        return nil
    end

    if rows_indent_list[line + 1] and rows_indent_list[line + 1] > rows_indent_list[line] then
        line = line + 1
    elseif rows_indent_list[line - 1] and rows_indent_list[line - 1] > rows_indent_list[line] then
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

    return { up, down }
end

-- when virt_indent is false, there are three cases:
-- 1. the row is blank, we set the value to -1
-- 2. the row is not blank, however it has no blank, we set the indent to 0
-- 3. the row is not blank and has indent, we set the indent to the indent of the row
-- when virt_indent is true, the only difference is:
-- when the len of line val is 0, we set its indent by its context, example
-- 1. hello world
-- 2.    this is shellRaining
-- 3.
-- 4.    this is shellRaining
-- 5.
-- 6. this is shellRaining
-- the virtual indent of line 3 is 4, and the virtual indent of line 5 is 0
---@param begRow? number
---@param endRow? number
---@param options? {use_treesitter: boolean, virt_indent: boolean}
---@return table<number, number> | nil
function M.get_rows_indent(begRow, endRow, options)
    begRow = begRow or fn.line("w0")
    endRow = endRow or fn.line("w$")
    options = options or { use_treesitter = false, virt_indent = false }

    local rows_indent = {}
    local get_indent = fn.indent
    if options.use_treesitter then
        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status then
            vim.notify_once("hl_indent: treesitter not loaded")
            return nil
        end
        get_indent = function(i)
            return math.min(ts_indent.get_indent(i) or 0, fn.indent(i))
        end
    end

    for i = endRow, begRow, -1 do
        rows_indent[i] = get_indent(i)
        if rows_indent[i] == 0 and #fn.getline(i) == 0 then
            rows_indent[i] = options.virt_indent and M.get_virt_indent(rows_indent, i) or -1
        end
    end

    return rows_indent
end

-- get the virtual indent of the given line
---@param rows_indent table<number, number>
---@param line number
---@return number
function M.get_virt_indent(rows_indent, line)
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

return M
