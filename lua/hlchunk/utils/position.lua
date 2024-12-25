local cFunc = require("hlchunk.utils.cFunc")

---@class HlChunk.Pos
---@field bufnr number buffer number, can't be 0 or negative, because 0 is current buffer
---@field row number 0-based line number (API-indexing)
---@field col number 0-based column number (API-indexing), the column number is the number of bytes from the start of the line, so can't handle CJK characters well
---@field is_valid boolean true if the position is valid, false otherwise
---A class representing a position (cursor location) in a specific buffer
local Pos = {}

---Represents an invalid position
Pos.INVALID = setmetatable({
    bufnr = -1,
    row = -1,
    col = -1,
}, {
    __index = {
        is_valid = function()
            return false
        end,
        get_char = function()
            return ""
        end,
    },
    __newindex = function()
        error("Cannot modify INVALID Position")
    end,
})

---Create a new Position instance
---@param bufnr number buffer number, can't be 0 or negative
---@param row number 0-based line number
---@param col number 0-based column number
---@return HlChunk.Pos
---
---Invalid cases:
---1. bufnr is 0, nil, negative or not a number
---2. row or col is nil, negative or not a number
---
---Example usage:
---```lua
---local pos = Pos.new(1, 0, 0) -- valid position at first line, first column in buffer 1
---```
function Pos.new(bufnr, row, col)
    -- Parameter validation
    if
        type(bufnr) ~= "number"
        or type(row) ~= "number"
        or type(col) ~= "number"
        or bufnr <= 0
        or row < 0
        or col < 0
    then
        return Pos.INVALID
    end

    local pos = {
        bufnr = bufnr,
        row = row,
        col = col,
    }

    return setmetatable(pos, {
        __index = {
            is_valid = function()
                return true
            end,
            get_char = Pos.get_char,
        },
        __newindex = function()
            error("Cannot modify Position after creation")
        end,
    })
end

---Get the character at this position
---@param expand_tab_width? number when given, tabs will be expanded to spaces with this width, if expand_tab_width is not a positive number, it will be throw an error
---@return string character at the position, or empty string if position is invalid
function Pos:get_char(expand_tab_width)
    if expand_tab_width and (type(expand_tab_width) ~= "number" or expand_tab_width <= 0) then
        error("expand_tab_width must be a positive number")
    end

    local line = cFunc.get_line(self.bufnr, self.row)
    if not line then
        return ""
    end

    if expand_tab_width then
        local expanded_tab = string.rep(" ", expand_tab_width)
        line = line:gsub("\t", expanded_tab)
    end

    return line:sub(self.col + 1, self.col + 1)
end

return Pos
