local indentHelper = {}

---@param blankLine string a string that contains only spaces
---@param leftcol number the shadowed cols number
---@param sw number shiftwidth
---@return number, number the render char number and the start index of the first render char
function indentHelper.calc(blankLine, leftcol, sw)
    local blankLen = #blankLine
    if blankLen - leftcol <= 0 then
        return 0, 0
    end
    local render_char_num = math.ceil(blankLen / sw)
    local shadow_char_num = math.ceil(leftcol / sw)
    local offset = math.min(shadow_char_num * sw, blankLen) - leftcol
    return render_char_num - shadow_char_num, offset
end

return indentHelper
