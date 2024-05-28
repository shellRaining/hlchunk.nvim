local assert = require("luassert")
local chunkHelper = require("hlchunk.utils.chunkHelper")

describe("indentHelper", function()
    it("calc function happy path", function()
        local str, col, leftcol, expect_res, expect_offset
        local testCaseList = {
            { str = "----", col = 0, leftcol = 0, render_res = "----", offset = 0 },
            { str = "----", col = 1, leftcol = 0, render_res = "----", offset = 1 },
            { str = "────", col = 1, leftcol = 0, render_res = "────", offset = 1 },
            { str = "────", col = 0, leftcol = 2, render_res = "──", offset = 0 },
            { str = "────", col = 0, leftcol = 3, render_res = "─", offset = 0 },
            { str = "────", col = 0, leftcol = 4, render_res = "", offset = 0 },
            { str = "────", col = 4, leftcol = 4, render_res = "────", offset = 0 },
            { str = "────", col = 4, leftcol = 5, render_res = "───", offset = 0 },
            { str = "────", col = 8, leftcol = 4, render_res = "────", offset = 4 },
        }

        for _, testCase in ipairs(testCaseList) do
            str = testCase.str
            col = testCase.col
            leftcol = testCase.leftcol
            expect_res = testCase.render_res
            expect_offset = testCase.offset

            local render_res, render_offset = chunkHelper.calc(str, col, leftcol)
            assert.equals(render_res, expect_res)
            assert.equals(render_offset, expect_offset)
        end
    end)

    it("utf8Split happy path", function()
        local inputList = {
            { input = "a", res = { "a" } },
            { input = "ab", res = { "a", "b" } },
            { input = "你好", res = { "你", "好" } },
            { input = "你好a", res = { "你", "好", "a" } },
            { input = "你好a你", res = { "你", "好", "a", "你" } },
            { input = "a好a你", res = { "a", "好", "a", "你" } },
            { input = "────", res = { "─", "─", "─", "─" } },
        }

        for _, testCase in ipairs(inputList) do
            local res = chunkHelper.utf8Split(testCase.input)
            assert.same(res, testCase.res)
        end
    end)

    it("rangeFromTo happy path", function()
        local inputList = {
            { from = 1, to = 3, res = { 1, 2, 3 } },
            { from = 1, to = 3, step = 1, res = { 1, 2, 3 } },
            { from = 1, to = 3, step = 2, res = { 1, 3 } },
            { from = 1, to = 4, step = 2, res = { 1, 3 } },
            { from = 1, to = 3, step = -1, res = {} },
            { from = 3, to = 1, step = -1, res = { 3, 2, 1 } },
        }

        for _, testCase in ipairs(inputList) do
            local res = chunkHelper.rangeFromTo(testCase.from, testCase.to, testCase.step)
            assert.same(res, testCase.res)
        end
    end)

    it("shallowCmp happy path", function()
        local inputList = {
            { t1 = { 1, 2, 3 }, t2 = { 1, 2, 3 }, res = true },
            { t1 = { 1, 2, 3 }, t2 = { 1, 2, 4 }, res = false },
            { t1 = { 1, 2, 3 }, t2 = { 1, 2 }, res = false },
            { t1 = { "a", "b", "c" }, t2 = { "a", "b", "c" }, res = true },
            { t1 = { "a", "b", "c" }, t2 = { "a", "b", "d" }, res = false },
            { t1 = { "a", "b", "c" }, t2 = { "a", "b" }, res = false },
            { t1 = { "你好", "你好" }, t2 = { "你好", "你好" }, res = true },
            { t1 = { "你好", "你好" }, t2 = { "你好", "你好1" }, res = false },
            { t1 = { true, false }, t2 = { 1, false }, res = false },
            { t1 = { { 1, 2 }, 3 }, t2 = { { 1, 2 }, 3 }, res = false },
        }

        for _, testCase in ipairs(inputList) do
            local res = chunkHelper.shallowCmp(testCase.t1, testCase.t2)
            assert.equals(res, testCase.res)
        end
    end)
end)
