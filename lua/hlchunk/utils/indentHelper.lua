local cFunc = require("hlchunk.utils.cFunc")

-- get the virtual indent of the given line
---@param bufnr number
---@param lnum number 0-indexed
---@return number
local function get_virt_indent(bufnr, lnum)
    local line_cnt = vim.api.nvim_buf_line_count(bufnr)
    for i = lnum + 1, line_cnt do
        local line = cFunc.get_line(bufnr, i)
        if cFunc.skipwhite(line) ~= "" then
            return cFunc.get_indent(bufnr, i)
        end
    end
    return -1
end

local indentHelper = {}

---@param blank string|number a string that contains only spaces
---@param leftcol number the shadowed cols number
---@param sw number shiftwidth
---@return number render_num, number offset, number shadowed_num return the render char number and the start index of the
-- first render char, the last is shadowed char number
function indentHelper.calc(blank, leftcol, sw)
    blank = blank or ""
    local blankLen = type(blank) == "string" and #blank or blank --[[@as number]]
    if blankLen - leftcol <= 0 or sw <= 0 then
        return 0, 0, 0
    end
    local render_char_num = math.ceil(blankLen / sw)
    local shadow_char_num = math.ceil(leftcol / sw)
    local offset = math.min(shadow_char_num * sw, blankLen) - leftcol
    return render_char_num - shadow_char_num, offset, shadow_char_num
end

---@enum ROWS_INDENT_RETCODE
indentHelper.ROWS_INDENT_RETCODE = {
    OK = 0,
    NO_TS = 1,
}

---@param range HlChunk.Scope
---@return ROWS_INDENT_RETCODE
---@return table<number, number>
local function get_rows_indent_by_context(range)
    local rows_indent = {}
    local bufnr = range.bufnr

    for i = range.finish, range.start, -1 do
        rows_indent[i] = cFunc.get_indent(bufnr, i)
        if rows_indent[i] == 0 and cFunc.get_line_len(bufnr, i) == 0 then
            rows_indent[i] = get_virt_indent(bufnr, i)
        end
    end

    return indentHelper.ROWS_INDENT_RETCODE.OK, rows_indent
end

---@param range HlChunk.Scope
---@return ROWS_INDENT_RETCODE
---@return table<number, number>
local function get_rows_indent_by_treesitter(range)
    local rows_indent = {}
    local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
    if not ts_indent_status then
        return indentHelper.ROWS_INDENT_RETCODE.NO_TS, {}
    end

    local bufnr = range.bufnr
    for i = range.start, range.finish, 1 do
        local t1 = vim.api.nvim_buf_call(bufnr, function()
            return ts_indent.get_indent(i + 1)
        end)
        local t2 = cFunc.get_indent(bufnr, i)
        local line_len = cFunc.get_line_len(bufnr, i)
        local indent = math.min(t1, t2)
        if indent == 0 and line_len == 0 then
            indent = get_virt_indent(bufnr, i)
        end
        rows_indent[i] = indent
    end

    return indentHelper.ROWS_INDENT_RETCODE.OK, rows_indent
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
---@param range HlChunk.Scope
---@param opts? {use_treesitter: boolean, virt_indent: boolean}
---@return ROWS_INDENT_RETCODE enum
---@return table<number, number>
function indentHelper.get_rows_indent(range, opts)
    opts = opts or { use_treesitter = false, virt_indent = false }

    if opts.use_treesitter then
        return get_rows_indent_by_treesitter(range)
    else
        return get_rows_indent_by_context(range)
    end
end

return indentHelper
