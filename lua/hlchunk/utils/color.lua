local M = {}

-- return the HEX presentation of rgb code, such as red RGB(255, 0, 0), it will return #ff0000
-- r, g, b default values is 0
function M.RGB2HEX(r, g, b)
    r = r or 0
    g = g or 0
    b = b or 0
    return string.format("#%02X%02X%02X", r, g, b)
end

return M
