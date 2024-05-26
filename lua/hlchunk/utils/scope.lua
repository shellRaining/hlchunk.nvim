local class = require("hlchunk.utils.class")

local constructor = function(self, bufnr, start, finish)
    self.bufnr = bufnr
    self.start = start
    self.finish = finish
end

---@class Scope
---@field bufnr number
---@field start number
---@field finish number
---@overload fun(bufnr: number, start: number, finish: number): Scope
local Scope = class(constructor)

return Scope
