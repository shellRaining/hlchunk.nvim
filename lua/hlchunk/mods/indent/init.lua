local BaseMod = require("hlchunk.mods.BaseMod")
local IndentConf = require("hlchunk.mods.indent.IndentConf")
local class = require("hlchunk.utils.class")

local utils = require("hlchunk.utils.utils")
local Array = require("hlchunk.utils.array")
local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = utils.ROWS_INDENT_RETCODE

---@type IndentMod
local IndentMod = class(BaseMod, function(self, meta_info, conf)
    meta_info = meta_info
        or {
            name = "indent",
            augroupName = "hlchunk_indent",
            hlBaseName = "HLIndent",
        }
    conf = conf or (IndentConf())
    BaseMod.init(self, meta_info, conf)
end)

function IndentMod:renderLine(ns_id, index, indent)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 12,
    }
    local shiftwidth = fn.shiftwidth()
    local render_char_num = math.floor(indent / shiftwidth)
    local win_info = fn.winsaveview()
    local text = ""
    for _ = 1, render_char_num do
        text = text .. "|" .. (" "):rep(shiftwidth - 1)
    end
    text = text:sub(win_info.leftcol + 1)

    local count = 0
    for i = 1, #text do
        local c = text:at(i)
        if not c:match("%s") then
            count = count + 1
            local Indent_chars_num = Array:from(self.conf.chars):size()
            local Indent_style_num = Array:from(self.conf.style):size()
            local char = self.conf.chars[(count - 1) % Indent_chars_num + 1]
            -- local style = "HLIndent" .. tostring((count - 1) % Indent_style_num + 1)
            local style = "HLIndent1"
            row_opts.virt_text = { { char, style } }
            row_opts.virt_text_win_col = i - 1
            api.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
        end
    end
end

function IndentMod:render(ns_id, range)
    if (not self.conf.enable) or self.conf.excludeFiletypes[vim.bo.filetype] or fn.shiftwidth() == 0 then
        return
    end

    self:clear(ns_id)

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
        self:renderLine(ns_id, index, rows_indent[index])
    end
end

function IndentMod:createAutocmd(ns_id)
    BaseMod.createAutocmd(self)

    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "WinScrolled" }, {
        group = self.meta.augroupName,
        pattern = "*",
        callback = function()
            self:render(ns_id)
        end,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.meta.augroupName,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = function()
            self:render(ns_id)
        end,
    })
end

function IndentMod:disable()
    BaseMod.disable(self)
end

return IndentMod
