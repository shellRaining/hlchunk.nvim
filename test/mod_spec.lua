package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local BaseMod = require("hlchunk.mods.BaseMod")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")
local IndentMod = require("hlchunk.mods.indent")
local exclude_filetypes = require("hlchunk.utils.filetype").exclude_filetypes

TestMod = {}

function TestMod:testBaseConf()
    local base

    -- not pass conf and meta
    base = BaseMod()
    local default_conf = BaseConf()
    local default_meta = {
        name = "",
        augroup_name = "",
        hl_base_name = "",
        ns_id = -1,
        hl_name_list = {},
    }
    luaunit.assertEquals(base.conf, default_conf)
    luaunit.assertEquals(base.meta, default_meta)
    luaunit.assertIsFunction(base.init)
    luaunit.assertIsFunction(base.enable)
    luaunit.assertIsFunction(base.disable)
    luaunit.assertIsFunction(base.render)
    luaunit.assertIsFunction(base.clear)
    luaunit.assertIsFunction(base.createUsercmd)
    luaunit.assertIsFunction(base.createAutocmd)
    luaunit.assertIsFunction(base.clearAutocmd)
    luaunit.assertIsFunction(base.setHl)
    luaunit.assertIsFunction(base.clearHl)
    luaunit.assertIsFunction(base.notify)

    -- pass user conf
    local user_conf = {
        enable = true,
        style = { "#000000" },
        notify = true,
        priority = 10,
        exclude_filetypes = { a = true, b = true },
    }
    base = BaseMod(user_conf)
    luaunit.assertEquals(base.conf, vim.tbl_deep_extend("force", default_conf, user_conf))
    luaunit.assertEquals(base.meta, default_meta)

    -- pass empty conf
    base = BaseMod({})
    luaunit.assertEquals(base.conf, default_conf)
    luaunit.assertEquals(base.meta, default_meta)

    -- pass part of conf
    base = BaseMod({ enable = true })
    luaunit.assertEquals(base.conf, vim.tbl_deep_extend("force", default_conf, { enable = true }))
end

function TestMod:testIndentConf()
    local indentMod
    local default_conf = {
        enable = false,
        style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
        notify = false,
        priority = 10,
        exclude_filetypes = exclude_filetypes,
        use_treesitter = false,
        chars = { "│" },
    }

    -- not pass conf
    indentMod = IndentMod()
    luaunit.assertEquals(indentMod.conf, default_conf)

    -- pass user conf
    local user_conf = {
        enable = true,
        style = { "#000000" },
        notify = true,
        priority = 10,
        exclude_filetypes = { a = true, b = true },
        use_treesitter = true,
        chars = { "┆" },
    }
    indentMod = IndentMod(user_conf)
    luaunit.assertEquals(indentMod.conf, vim.tbl_deep_extend("force", default_conf, user_conf))

    -- pass empty conf
    indentMod = IndentMod({})
    luaunit.assertEquals(indentMod.conf, default_conf)

    -- pass part of conf
    indentMod = IndentMod({ enable = true })
    luaunit.assertEquals(indentMod.conf, vim.tbl_deep_extend("force", default_conf, { enable = true }))

    -- TODO: test about meta have not been implemented
end

luaunit.LuaUnit.run()
