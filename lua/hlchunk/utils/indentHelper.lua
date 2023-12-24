local api = vim.api
local fn = vim.fn
local Scope = require("hlchunk.utils.Scope")

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

---@param info table the event info, is param of autocmd callback function
---@return table changedWins a table contains the changed window number
function indentHelper.getActiveWins(info)
    local changedWins = {}
    if info.event == "WinScrolled" then
        for win, _ in pairs(vim.v.event) do
            if win ~= "all" then
                table.insert(changedWins, tonumber(win))
            end
        end
    else
        local cur_win = api.nvim_get_current_win()
        changedWins = { cur_win }
    end

    return changedWins
end

---@param ft string filetype
---@return boolean
function indentHelper.isBlankFiletype(ft)
    if ft == nil then
        return true
    end
    return #ft == 0
end

---@param winnr number
---@return Scope range the range contains the window's topline and botline
function indentHelper.getWinRange(winnr)
    local wininfo = fn.getwininfo(winnr) --[[@as table]]
    local topline = wininfo[1].topline
    local botline = wininfo[1].botline
    local bufnr = api.nvim_win_get_buf(winnr)
    return Scope(bufnr, topline - 1, botline - 1)
end

return indentHelper
