local assert = require("luassert")
local indentHelper = require("hlchunk.utils.indentHelper")

describe("indentHelper", function()
    it("calc function happy path", function()
        local testCaseList = {
            { blankLine = (" "):rep(12), leftcol = 5, sw = 4, render_char_num = 1, offset = 3 },
            { blankLine = (" "):rep(12), leftcol = 4, sw = 4, render_char_num = 2, offset = 0 },
            { blankLine = (" "):rep(12), leftcol = 9, sw = 4, render_char_num = 0, offset = 3 },
            { blankLine = (" "):rep(4), leftcol = 0, sw = 4, render_char_num = 1, offset = 0 },
            { blankLine = (" "):rep(4), leftcol = 1, sw = 4, render_char_num = 0, offset = 3 },
            { blankLine = (" "):rep(7), leftcol = 2, sw = 4, render_char_num = 1, offset = 2 },
            { blankLine = (" "):rep(7), leftcol = 4, sw = 4, render_char_num = 1, offset = 0 },
            { blankLine = (" "):rep(7), leftcol = 5, sw = 4, render_char_num = 0, offset = 2 },
            { blankLine = (" "):rep(4), leftcol = 4, sw = 4, render_char_num = 0, offset = 0 },
            { blankLine = (" "):rep(4), leftcol = 5, sw = 4, render_char_num = 0, offset = 0 },
            { blankLine = 12, leftcol = 5, sw = 4, render_char_num = 1, offset = 3 },
            { blankLine = 12, leftcol = 5, sw = 0, render_char_num = 0, offset = 0 },
        }
        local blankLine, leftcol, sw
        local render_char_num, offset

        for _, testCase in ipairs(testCaseList) do
            blankLine = testCase.blankLine
            leftcol = testCase.leftcol
            sw = testCase.sw
            render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
            assert.equals(render_char_num, testCase.render_char_num)
            assert.equals(offset, testCase.offset)
        end
    end)
end)
