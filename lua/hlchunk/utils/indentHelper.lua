local indentHelper = {}

---@param blank string|number a string that contains only spaces
---@param leftcol number the shadowed cols number
---@param sw number shiftwidth
---@return number rendered, number offset, number shadowed return the render char number and the start index of the
-- first render char, the last is shadowed char number
function indentHelper.calc(blank, leftcol, sw)
    local blankLen = type(blank) == "string" and #blank or blank --[[@as number]]
    if blankLen - leftcol <= 0 or sw <= 0 then
        return 0, 0, 0
    end
    local render_char_num = math.ceil(blankLen / sw)
    local shadow_char_num = math.ceil(leftcol / sw)
    local offset = math.min(shadow_char_num * sw, blankLen) - leftcol
    return render_char_num - shadow_char_num, offset, shadow_char_num
end

return indentHelper
