local Range = require("hlchunk.utils.range")

---@class HlChunk.RangeSet
---@field ranges HlChunk.Range[] range array
---@field bufnr number buffer number
local RangeSet = {}

---Create a new RangeSet instance
---@param bufnr number buffer number
---@return HlChunk.RangeSet
function RangeSet.new(bufnr)
    local set = {
        ranges = {},
        bufnr = bufnr,
    }
    setmetatable(set, { __index = RangeSet })
    return set
end

---Add a new range, and merge overlapping ranges
---@param start number
---@param finish number
---@overload fun(self: HlChunk.RangeSet, range: HlChunk.Range)
function RangeSet:addRange(start, finish)
    if type(start) == "table" then
        local new_range = Range.new(self.bufnr, start.start, start.finish)
        table.insert(self.ranges, new_range)
    else
        local new_range = Range.new(self.bufnr, start, finish)
        table.insert(self.ranges, new_range)
    end
    self:mergeOverlapping()
end

---@private
---Merge overlapping ranges
function RangeSet:mergeOverlapping()
    if #self.ranges <= 1 then
        return
    end

    table.sort(self.ranges, function(a, b)
        return a.start < b.start
    end)

    local merged = {}
    local current = self.ranges[1]

    for i = 2, #self.ranges do
        local range = self.ranges[i]
        if current.finish + 1 >= range.start then
            -- Merge overlapping ranges
            current.finish = math.max(current.finish, range.finish)
        else
            table.insert(merged, current)
            current = range
        end
    end
    table.insert(merged, current)

    self.ranges = merged
end

---Check if a line is within any range
---@param line number a natural number (0-based)
---@return boolean contains true if the line is within the range, false otherwise
function RangeSet:contains(line)
    for _, range in ipairs(self.ranges) do
        if range:contains(line) then
            return true
        end
    end
    return false
end

return RangeSet
