local BaseMod = require("hlchunk.mods.BaseMod")
local IndentConf = require("hlchunk.mods.indent.IndentConf")
local class = require("hlchunk.utils.class")

local utils = require("hlchunk.utils.utils")
local indentHelper = require("hlchunk.utils.indentHelper")

local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = utils.ROWS_INDENT_RETCODE

---@type IndentMod
local IndentMod = class(BaseMod, function(self, meta, conf)
    meta = meta
        or {
            name = "indent",
            augroupName = "hlchunk_indent",
            hlBaseName = "HLIndent",
            nsId = api.nvim_create_namespace("indent"),
        }
    conf = conf or (IndentConf())
    BaseMod.init(self, meta, conf)
end)

function IndentMod:renderLine(index, blankLen)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    local leftcol = fn.winsaveview().leftcol --[[@as number]]
    local sw = fn.shiftwidth() --[[@as number]]
    local render_char_num, offset, shadow_char_num = indentHelper.calc(blankLen, leftcol, sw)

    for i = 1, render_char_num do
        local char = self.conf.chars[(i - 1 + shadow_char_num) % #self.conf.chars + 1]
        local style = self.meta.hlNameList[(i - 1 + shadow_char_num) % #self.meta.hlNameList + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = offset + (i - 1) * sw
        api.nvim_buf_set_extmark(0, self.meta.nsId, index - 1, 0, row_opts)
    end
end

function IndentMod:render(range)
    if (not self.conf.enable) or self.conf.excludeFiletypes[vim.bo.filetype] or fn.shiftwidth() == 0 then
        return
    end

    self:clear()

    local retcode, rows_indent = utils.get_rows_indent(self, nil, nil, {
        use_treesitter = self.conf.useTreesitter,
        virt_indent = true,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS then
        if self.conf.notify then
            self:notify("[hlchunk.indent]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
        return
    end

    for index, _ in pairs(rows_indent) do
        self:renderLine(index, rows_indent[index])
    end
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)

    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "WinScrolled" }, {
        group = self.meta.augroupName,
        pattern = "*",
        callback = function()
            self:render()
        end,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.meta.augroupName,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = function()
            self:render()
        end,
    })
end

return IndentMod
