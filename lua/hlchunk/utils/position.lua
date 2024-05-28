---@class Pos
---@field bufnr number
---@field row number 0-index API-indexing
---@field col number 0-index API-indexing
---@overload fun(bufnr: number, row: number, col: number): Pos
---0-indexing API-indexing, notice when use with nvim_win_get_cursor
local function Pos(bufnr, row, col)
    return {
        bufnr = bufnr,
        row = row,
        col = col,
    }
end

return Pos
