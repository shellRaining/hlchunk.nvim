---@class HlChunk.Scope
---@field bufnr number
---@field start number
---@field finish number
---@field node_type? string treesitter node type (e.g., "function", "if_statement", "for_loop")
---@overload fun(bufnr: number, start: number, finish: number, node_type?: string): HlChunk.Scope
---0-indexing, include start and finish
-- local Scope = class(constructor)
local function Scope(bufnr, start, finish, node_type)
    return {
        bufnr = bufnr,
        start = start,
        finish = finish,
        node_type = node_type,
    }
end

return Scope
