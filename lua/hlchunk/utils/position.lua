local class = require("hlchunk.utils.class")

local constructor = function(self, bufnr, row, col)
    self.bufnr = bufnr
    self.row = row
    self.col = col
end

---@class Pos
---@field bufnr number
---@field row number 0-index API-indexing
---@field col number 0-index API-indexing
---@overload fun(bufnr: number, start: number, finish: number): Scope
local Pos = class(constructor)

return Pos
