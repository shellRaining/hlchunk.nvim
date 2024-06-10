local class = require("hlchunk.utils.class")
local cFunc = require("hlchunk.utils.cFunc")

---@class Pos
---@field bufnr number
---@field row number 0-index API-indexing
---@field col number 0-index API-indexing
---0-indexing API-indexing, notice when use with nvim_win_get_cursor

---@overload fun(bufnr: number, row: number, col: number): Pos
local Pos = class(function(self, bufnr, row, col)
    self.bufnr = bufnr
    self.row = row
    self.col = col
end)

---@param pos Pos
---@param expand_tab_width? number when the field is given, the tab will be expand to blank with the width, like "\t\t" -> "    " when the width is 2
---@return string
function Pos.get_char_at_pos(pos, expand_tab_width)
    local line = cFunc.get_line(pos.bufnr, pos.row)
    if expand_tab_width then
        local expanded_tab = string.rep(" ", expand_tab_width)
        line = line:gsub("\t", expanded_tab)
    end
    return line:sub(pos.col + 1, pos.col + 1)
end

return Pos
