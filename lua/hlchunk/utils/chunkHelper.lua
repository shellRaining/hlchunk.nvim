local chunkHelper = {}

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

function chunkHelper.get_virt_text_list(virt_text_list, chars)
    if beg_blank_len > 0 then
        local virt_text_len = beg_blank_len - start_col
        local beg_virt_text = self.conf.chars.left_top .. self.conf.chars.horizontal_line:rep(virt_text_len - 1)
        local virt_text, virt_text_win_col = chunkHelper.calc(beg_virt_text, start_col, leftcol)
        local char_list = fn.reverse(utf8_split(virt_text))
        vim.list_extend(virt_text_list, char_list)
        vim.list_extend(row_list, vim.fn["repeat"]({ beg_row - 1 }, virt_text_len))
        vim.list_extend(virt_text_win_col_list, rangeFromTo(virt_text_win_col + virt_text_len - 1, virt_text_win_col))
    end
end

return chunkHelper
