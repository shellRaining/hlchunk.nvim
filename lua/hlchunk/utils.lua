local M = {}

function M.get_pair_rows()
    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = vim.fn.getline(".")
    local cur_col = vim.fn.col(".")
    local cur_char = string.sub(cur_row_val, cur_col, cur_col)

    beg_row = vim.fn.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
    end_row = vim.fn.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

    return { beg_row, end_row }
end

function M.get_render_chunk_params(beg_row, end_row)
    local shift_width = vim.o.shiftwidth
    local space_tab = (" "):rep(shift_width)
    local beg_blank_val = tostring(vim.fn.getline(beg_row)):match("%s*"):gsub("\t", space_tab)
    local end_blank_val = tostring(vim.fn.getline(end_row)):match("%s*"):gsub("\t", space_tab)
    local beg_blank_len = #beg_blank_val
    local end_blank_len = #end_blank_val
    local start_col = math.min(beg_blank_len, end_blank_len) - shift_width

    return {
        beg_row,
        end_row,
        start_col,
        beg_blank_len,
        end_blank_len,
    }
end

function M.get_rows_blank()
    local rows_blank = {}
    local beg_row = vim.fn.line("w0")
    local end_row = vim.fn.line("w$")
    for i = beg_row, end_row do
        local row_str = vim.fn.getline(i)
        if #row_str == 0 then
            rows_blank[i] = -1
            goto continue
        end
        rows_blank[i] = #(row_str:match("^%s+") or "")
        ::continue::
    end
    return rows_blank
end

return M
