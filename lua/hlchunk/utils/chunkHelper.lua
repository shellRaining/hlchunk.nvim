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

return chunkHelper
