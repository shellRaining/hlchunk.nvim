local assert = require("luassert")
local iterator = require("hlchunk.utils.iterator")
local mock = require("luassert.mock")

describe("iterator", function()
    ---@type number[]
    local arr1
    ---@type number[]
    local arr2
    local arr3

    before_each(function()
        arr1 = { 1, 2, 3, 4, 5 }
        arr2 = { 1 }
        arr3 = {}
    end)

    it("array2iter happy path (not cycle)", function()
        local iter1 = iterator.array2iter(arr1)
        local iter2 = iterator.array2iter(arr2)
        local iter3 = iterator.array2iter(arr3)

        for i, v in iter1 do
            assert.equals(i, v)
        end
        local i, v
        i, v = iter2()
        assert.equals(i, 1)
        assert.equals(v, 1)
        i, v = iter2()
        assert.equals(i, nil)
        assert.equals(v, nil)
        i, v = iter3()
        assert.equals(i, nil)
        assert.equals(v, nil)
    end)

    it("array2iter cycle", function()
        local iter1 = iterator.array2iter(arr1, 20, true)
        local iter2 = iterator.array2iter(arr2, 5, true)
        local iter3 = iterator.array2iter(arr3, 2, true)

        for i, v in iter1 do
            assert.equals(i, v)
        end
        for i, v in iter2 do
            assert.equals(i, v)
        end
        local i, v
        i, v = iter3()
        assert.equals(i, nil)
        assert.equals(v, nil)
    end)

    it("array2iter limit", function()
        local iter1 = mock(iterator.array2iter(arr1, 3))
        local iter2 = mock(iterator.array2iter(arr2, 1))
        local iter3 = iterator.array2iter(arr3, 0)

        for i, v in iter1 do
            assert.equals(i, v)
        end
        assert.spy(iter1).was.called(4)

        local i, v
        i, v = iter2()
        assert.equals(i, 1)
        assert.equals(v, 1)
        i, v = iter2()
        assert.equals(i, nil)
        assert.equals(v, nil)
        i, v = iter3()
        assert.equals(i, nil)
        assert.equals(v, nil)
    end)
end)
