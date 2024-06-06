local class = require("hlchunk.utils.class")

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
---@return string
function Pos.get_char_at_pos(pos)
    local row = pos.row
    local col = pos.col
    local char = vim.api.nvim_buf_get_text(pos.bufnr, row, col, row, col + 1, {})[1]
    return char
end

return Pos
