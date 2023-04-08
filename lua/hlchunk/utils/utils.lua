---@diagnostic disable: param-type-mismatch
local M = {}

function M.get_chunk_range()
    local beg_row, end_row
    local base_flag = "nWz"
    local cur_row_val = FN.getline(".")
    local cur_col = FN.col(".")
    local cur_char = string.sub(cur_row_val, cur_col, cur_col)

    beg_row = FN.searchpair("{", "", "}", base_flag .. "b" .. (cur_char == "{" and "c" or ""))
    end_row = FN.searchpair("{", "", "}", base_flag .. (cur_char == "}" and "c" or ""))

    if beg_row <= 0 or end_row <= 0 then
        return { 0, 0 }
    end

    return { beg_row, end_row }
end

function M.get_indent_range()
    ROWS_BLANK_LIST = M.get_rows_blank()
    local cur_row = FN.line(".")
    for line, blank_num in pairs(ROWS_BLANK_LIST) do
        if blank_num == -1 then
            local cur = line + 1
            while ROWS_BLANK_LIST[cur] do
                if ROWS_BLANK_LIST[cur] == 0 then
                    break
                elseif ROWS_BLANK_LIST[cur] > 0 then
                    ROWS_BLANK_LIST[line] = ROWS_BLANK_LIST[cur]
                    break
                end
                cur = cur + 1
            end
        end
    end
    local cur_row_blank_num = ROWS_BLANK_LIST[cur_row]

    if cur_row_blank_num <= 0 then
        return { -1, -1 }
    end

    local up = cur_row
    local down = cur_row
    local wbegin = FN.line("w0")
    local wend = FN.line("w$")

    while up >= wbegin and ROWS_BLANK_LIST[up] >= cur_row_blank_num do
        up = up - 1
    end
    while down <= wend and ROWS_BLANK_LIST[down] >= cur_row_blank_num do
        down = down + 1
    end

    return { up, down }
end

-- get the indent of each row in the current window
-- there are three cases:
-- 1. the row is blank, we set the indent to -1
-- 2. the row is not blank, however it has no indent, we set the indent to 0
-- 3. the row is not blank and has indent, we set the indent to the indent of the row
function M.get_rows_blank()
    local rows_blank = {}
    local beg_row = FN.line("w0")
    local end_row = FN.line("w$")

    if PLUG_CONF.indent.use_treesitter then
        local ts_indent_status, ts_indent = pcall(require, "nvim-treesitter.indent")
        if not ts_indent_status then
            return {}
        end

        for i = beg_row, end_row do
            if #FN.getline(i) == 0 then
                rows_blank[i] = -1
            else
                rows_blank[i] = math.min(ts_indent.get_indent(i) or 0, FN.indent(i))
            end
        end
    else
        for i = beg_row, end_row do
            local row_str = FN.getline(i)
            if #row_str == 0 then
                rows_blank[i] = -1
            else
                rows_blank[i] = FN.indent(i)
            end
        end
    end

    return rows_blank
end

function M.get_indent_virt_text_num(line)
    -- if the given line is blank, we need set the virt_text by context
    if ROWS_BLANK_LIST[line] == -1 then
        local cur = line + 1
        while ROWS_BLANK_LIST[cur] do
            if ROWS_BLANK_LIST[cur] == 0 then
                break
            elseif ROWS_BLANK_LIST[cur] > 0 then
                ROWS_BLANK_LIST[line] = ROWS_BLANK_LIST[cur]
                break
            end
            cur = cur + 1
        end
    end

    return math.floor(ROWS_BLANK_LIST[line] / vim.o.shiftwidth)
end

return M
