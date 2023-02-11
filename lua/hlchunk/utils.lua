local M = {}

function M.get_pair_rows()
    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = vim.fn.getline('.')
    local cur_col = vim.fn.col('.')
    local cur_char = string.sub(cur_row_val, cur_col, cur_col)

    beg_row = vim.fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
    end_row = vim.fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

    return { beg_row, end_row }
end

return M
