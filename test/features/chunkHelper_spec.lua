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
end)
