---@diagnostic disable: param-type-mismatch
local opts = require("hlchunk.options")
local M = {}

function M.get_pair_rows()
    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = vim.fn.getline(".")
    local cur_col = vim.fn.col(".")
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

    if opts.config.hl_indent.use_treesitter then
        local ts_query_status, ts_query = pcall(require, "nvim-treesitter.query")
        if not ts_query_status then
            vim.notify_once("ts_query not load")
            return {}
        end
        if not ts_query.has_indents(vim.bo.filetype) then
            return {}
        end

        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status then
            return {}
        end

        for i = beg_row, end_row do
            rows_blank[i] = ts_indent.get_indent(i) or 0
        end
    else
        for i = beg_row, end_row do
            local row_str = vim.fn.getline(i)
            if #row_str == 0 then
                rows_blank[i] = -1
                goto continue
            end
            ---@diagnostic disable-next-line: undefined-field
            rows_blank[i] = vim.fn.indent(i)
            ::continue::
        end
    end

    return rows_blank
end

return M
