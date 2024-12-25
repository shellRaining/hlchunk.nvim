---@class HlChunk.Range
---@field bufnr number buffer number, can't be 0 or negative, because 0 is current buffer, not a specific buffer
---@field start number a natural number (0-based), inclusive
---@field finish number a natural number (0-based), inclusive, must be greater than start
---@field isValid boolean true if the range is valid, false otherwise
---A class representing a range of lines in a specific buffer
local Range = {}

---Represents an invalid range
Range.INVALID = setmetatable({
    bufnr = -1,
    start = -1,
    finish = -1,
}, {
    __index = {
        isValid = function()
            return false
        end,
        contains = function()
            return false
        end,
        overlaps = function()
            return false
        end,
    },
    __newindex = function()
        error("Cannot modify INVALID Range")
    end,
})

---Create a new Range instance
---@param bufnr number buffer number, can't be 0, because 0 is current buffer, not a specific buffer
---@param start number a natural number (0-based)
---@param finish number a natural number (0-based), must be greater or equal to start
---@return HlChunk.Range
---
---Invalid cases:
---1. bufnr is 0, nil, negative or not a number
---2. start or finish is nil, not a number, or not a natural number
---3. finish is less than start
---
---if the parameters are invalid, the function will return Range.INVALID,
---and please note this function won't check the actual buffer,
---if you want to check the buffer, you should use `vim.api.nvim_buf_get_lines` to judge whether the range is valid
---
---Example usage:
---```lua
---local range = Range.new(1, 0, 10) -- valid range from line 0 to 10 in buffer 1
---```
function Range.new(bufnr, start, finish)
    -- Parameter validation
    if
        type(bufnr) ~= "number"
        or type(start) ~= "number"
        or type(finish) ~= "number"
        or bufnr <= 0
        or start < 0
        or finish < 0
        or finish < start
    then
        return Range.INVALID
    end

    local range = {
        bufnr = bufnr,
        start = start,
        finish = finish,
    }

    return setmetatable(range, {
        __index = {
            isValid = function()
                return true
            end,
            contains = Range.contains,
            overlaps = Range.overlaps,
        },
        __newindex = function()
            error("Cannot modify Range after creation")
        end,
    })
end

---Check if a line is within the range
---@param line number a natural number (0-based)
---@return boolean contains true if the line is within the range, false otherwise
---@throws string Error if line is nil or not a number
function Range:contains(line)
    if type(line) ~= "number" then
        error("line must be a number")
    end
    return line >= self.start and line <= self.finish
end

---Check if this range overlaps with another range
---@param other HlChunk.Range another range instance to check against
---@return boolean overlaps true if the ranges overlap (share any lines and are in the same buffer)
function Range:overlaps(other)
    if not other or not other.isValid or not other.bufnr then
        error("other must be a valid Range instance")
    end
    return self.bufnr == other.bufnr and self.start <= other.finish and other.start <= self.finish
end

return Range
