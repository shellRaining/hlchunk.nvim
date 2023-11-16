package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local indentHelper = require("hlchunk.utils.indentHelper")

TestIndentHelper = {}

function TestIndentHelper:testCalc()
    local blankLine, leftcol
    local sw = 4
    local render_char_num, offset

    blankLine = (" "):rep(12)
    leftcol = 5
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 1)
    luaunit.assertEquals(offset, 3)

    leftcol = 4
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 2)
    luaunit.assertEquals(offset, 0)

    leftcol = 9
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 0)
    luaunit.assertEquals(offset, 3)

    blankLine = (" "):rep(4)
    leftcol = 0
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 1)
    luaunit.assertEquals(offset, 0)

    leftcol = 1
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 0)
    luaunit.assertEquals(offset, 3)

    blankLine = (" "):rep(7)
    leftcol = 2
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 1)
    luaunit.assertEquals(offset, 2)

    leftcol = 4
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 1)
    luaunit.assertEquals(offset, 0)

    leftcol = 5
    render_char_num, offset = indentHelper.calc(blankLine, leftcol, sw)
    luaunit.assertEquals(render_char_num, 0)
    luaunit.assertEquals(offset, 2)
end

os.exit(luaunit.LuaUnit.run())
