package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local tsUtils = require("hlchunk.utils.tsUtils")

TestTsUtils = {}

function TestTsUtils:testGetLang()
    local lang

    local fts = {
        ["vim"] = "vim",
        ["lua"] = "lua",
        ["typescript"] = "typescript",
        ["typescript.tsx"] = "tsx",
        ["jest.typescript"] = "typescript",
        ["spec"] = nil,
        [""] = nil,
    }

    for ft, expected in pairs(fts) do
        lang = tsUtils.get_lang(ft)
        luaunit.assertEquals(lang, expected)
    end
end

function TestTsUtils:testBufLang()
    local lang

    -- test not pass param
    lang = tsUtils.get_buf_lang()
    luaunit.assertEquals(lang, "lua")
end

function TestTsUtils:testHasParser()
    local has_parser = tsUtils.has_parser
    -- no args passed
    luaunit.assertEquals(has_parser(), true)
    luaunit.assertEquals(has_parser("javascript"), true)
    luaunit.assertEquals(has_parser("typescript"), true)
    luaunit.assertEquals(has_parser("typescript.tsx"), true)
end

function TestTsUtils:testGetParser()
    local parser_tree

    -- no args passed
    parser_tree = tsUtils.get_parser()
    vim.notify(luaunit.prettystr(parser_tree))

    if not parser_tree then
        luaunit.fail("parser_tree is nil")
    end

    parser_tree:parse()
end

luaunit.LuaUnit.run()
