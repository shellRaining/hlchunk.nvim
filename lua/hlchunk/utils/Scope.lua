local class = require("hlchunk.utils.class")

---@class Scope
---@field bufnr number
---@field start number
---@field finish number
local Scope = class(function (self, bufnr, start, finish)
    self.bufnr = bufnr
    self.start = start
    self.finish = finish
end)

return Scope
