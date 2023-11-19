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

function TestTsUtils() end

luaunit.LuaUnit.run()
