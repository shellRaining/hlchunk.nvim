---@class Scope
---@field bufnr number
---@field start number
---@field finish number
---@overload fun(bufnr: number, start: number, finish: number): Scope
---0-indexing, include start and finish
-- local Scope = class(constructor)
local function Scope(bufnr, start, finish)
    return {
        bufnr = bufnr,
        start = start,
        finish = finish,
    }
end

return Scope
