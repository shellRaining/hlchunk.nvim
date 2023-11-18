package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")
local IndentConf = require("hlchunk.mods.indent.IndentConf")
local ft = require("hlchunk.utils.filetype")

TestConf = {}

function TestConf:testBaseConf()
    local conf

    -- test default conf
    local default = {
        enable = false,
        style = {},
        notify = false,
        priority = 0,
        exclude_filetypes = ft.exclude_filetypes,
    }
    conf = BaseConf()
    luaunit.assertEquals(conf, default)

    -- test custom conf not include exclude_filetypes
    local template = {
        enable = true,
        style = { "#000000" },
        notify = true,
        priority = 10,
        exclude_filetypes = ft.exclude_filetypes,
    }
    conf = BaseConf(template)
    luaunit.assertEquals(conf.enable, template.enable)

    -- test pass a empty table
    conf = BaseConf({})
    luaunit.assertEquals(conf, default)

    -- -- test pass a exclude_filetypes
    conf = BaseConf({
        exclude_filetypes = { a = true, b = true },
    })
    luaunit.assertEquals(
        conf.exclude_filetypes,
        vim.tbl_deep_extend("force", ft.exclude_filetypes, { a = true, b = true })
    )
    luaunit.assertEquals(conf.enable, default.enable)
end

function TestConf:testIndentConf()
    local conf

    -- test default conf
    local default = {
        enable = false,
        style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
        notify = false,
        priority = 10,
        exclude_filetypes = ft.exclude_filetypes,
        use_treesitter = false,
        chars = { "│" },
    }
    conf = IndentConf()
    luaunit.assertEquals(conf.enable, default.enable)
    luaunit.assertEquals(conf.style, default.style)
    luaunit.assertEquals(conf.notify, default.notify)
    luaunit.assertEquals(conf.priority, default.priority)
    luaunit.assertEquals(conf.exclude_filetypes, default.exclude_filetypes)
    luaunit.assertEquals(conf.use_treesitter, default.use_treesitter)
    luaunit.assertEquals(conf.chars, default.chars)

    -- test custom conf not include exclude_filetypes
    local template = {
        enable = true,
        style = { "#000000" },
        notify = true,
        priority = 15,
        exclude_filetypes = ft.exclude_filetypes,
        use_treesitter = true,
        chars = { "│", "┆" },
    }
    conf = IndentConf(template)
    luaunit.assertEquals(conf.enable, template.enable)

    -- test pass a empty table
    conf = IndentConf({})
    luaunit.assertEquals(conf.enable, default.enable)
    luaunit.assertEquals(conf.style, default.style)
    luaunit.assertEquals(conf.notify, default.notify)
    luaunit.assertEquals(conf.priority, default.priority)
    luaunit.assertEquals(conf.exclude_filetypes, default.exclude_filetypes)
    luaunit.assertEquals(conf.use_treesitter, default.use_treesitter)
    luaunit.assertEquals(conf.chars, default.chars)

    -- -- test pass a exclude_filetypes
    conf = IndentConf({
        exclude_filetypes = { a = true, b = true },
    })
    luaunit.assertEquals(
        conf.exclude_filetypes,
        vim.tbl_deep_extend("force", ft.exclude_filetypes, { a = true, b = true })
    )
    luaunit.assertEquals(conf.enable, default.enable)
end

luaunit.LuaUnit.run()
