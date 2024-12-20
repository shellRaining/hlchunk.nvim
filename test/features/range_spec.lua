local assert = require("luassert")
local Range = require("hlchunk.utils.range")
local RangeSet = require("hlchunk.utils.range_set")

describe("Range", function()
    it("创建新的Range实例", function()
        local range = Range.new(1, 5, 10)
        assert.equals(range.bufnr, 1)
        assert.equals(range.start, 5)
        assert.equals(range.finish, 10)

        local range2 = Range.new(1, 10, 10)
        assert.equals(range2.bufnr, 1)
        assert.equals(range2.start, 10)
        assert.equals(range2.finish, 10)
    end)

    it("创建无效的Range实例", function()
        local range = Range.new(1, 5, 10)
        assert.is_true(range:isValid())
        local range2 = Range.new(0, 5, 10)
        assert.is_false(range2:isValid())
        local range3 = Range.new(1, -1, 10)
        assert.is_false(range3:isValid())
        local range4 = Range.new(1, 10, 5)
        assert.is_false(range4:isValid())
        local range5 = Range.new(1, 5, 5)
        assert.is_true(range5:isValid())
    end)

    it("检查行是否在范围内", function()
        local range = Range.new(1, 5, 10)
        assert.is_true(range:contains(5))
        assert.is_true(range:contains(7))
        assert.is_true(range:contains(10))
        assert.is_false(range:contains(4))
        assert.is_false(range:contains(11))
    end)

    it("检查范围重叠", function()
        local range1 = Range.new(1, 5, 10)
        local range2 = Range.new(1, 8, 15)
        local range3 = Range.new(1, 20, 25)
        local range4 = Range.new(2, 5, 10) -- 不同缓冲区

        assert.is_true(range1:overlaps(range2))
        assert.is_true(range2:overlaps(range1))
        assert.is_false(range1:overlaps(range3))
        assert.is_false(range1:overlaps(range4))
    end)
end)

describe("RangeSet", function()
    it("创建新的RangeSet实例", function()
        local set = RangeSet.new(1)
        assert.equals(set.bufnr, 1)
        assert.equals(#set.ranges, 0)
    end)

    it("添加和合并范围", function()
        local set = RangeSet.new(1)

        set:addRange(5, 10)
        assert.equals(#set.ranges, 1)

        -- 添加不重叠的范围
        set:addRange(20, 25)
        assert.equals(#set.ranges, 2)

        -- 添加重叠的范围
        set:addRange(8, 15)
        assert.equals(#set.ranges, 2)
        assert.equals(set.ranges[1].start, 5)
        assert.equals(set.ranges[1].finish, 15)

        -- 添加连接的范围
        set:addRange(15, 18)
        assert.equals(#set.ranges, 2)
        assert.equals(set.ranges[1].finish, 18)
    end)

    it("检查行是否在范围集合内", function()
        local set = RangeSet.new(1)
        set:addRange(5, 10)
        set:addRange(20, 25)

        assert.is_true(set:contains(5))
        assert.is_true(set:contains(7))
        assert.is_true(set:contains(10))
        assert.is_true(set:contains(20))
        assert.is_true(set:contains(23))
        assert.is_true(set:contains(25))

        assert.is_false(set:contains(4))
        assert.is_false(set:contains(11))
        assert.is_false(set:contains(15))
        assert.is_false(set:contains(26))
    end)
end)
