---@diagnostic disable: param-type-mismatch
local M = {}

function M.get_chunk_range()
    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = vim.fn.getline(".")
    local cur_col = FN.col('.')
    local cur_char = string.sub(cur_row_val, cur_col, cur_col)

    beg_row = vim.fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
    end_row = vim.fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

    if beg_row <= 0 or end_row <= 0 then
        return { 0, 0 }
    end

    return { beg_row, end_row }
end

function M.get_rows_blank()
    local rows_blank = {}
    local beg_row = vim.fn.line("w0")
    local end_row = vim.fn.line("w$")

    if PLUG_CONF.indent.use_treesitter then
        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status then
            return {}
        end

        for i = beg_row, end_row do
            if #vim.fn.getline(i) == 0 then
                rows_blank[i] = -1
            else
                rows_blank[i] = math.min(ts_indent.get_indent(i) or 0, vim.fn.indent(i))
            end
        end
    else
        for i = beg_row, end_row do
            local row_str = vim.fn.getline(i)
            if #row_str == 0 then
                rows_blank[i] = -1
            else
                rows_blank[i] = vim.fn.indent(i)
            end
        end
    end

    return rows_blank
end

function M.get_indent_virt_text_num(line)
    -- if the given line is blank, we need set the virt_text by context
    if ROWS_BLANK_LIST[line] == -1 then
        local line_below = line + 1
        while ROWS_BLANK_LIST[line_below] do
            if ROWS_BLANK_LIST[line_below] == 0 then
                break
            elseif ROWS_BLANK_LIST[line_below] > 0 then
                ROWS_BLANK_LIST[line] = ROWS_BLANK_LIST[line_below]
                break
            end
            line_below = line_below + 1
        end
    end

    return math.floor(ROWS_BLANK_LIST[line] / vim.o.shiftwidth)
end

return M
