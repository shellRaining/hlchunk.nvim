local BaseMod = require("hlchunk.mods.BaseMod")
local IndentConf = require("hlchunk.mods.indent.IndentConf")
local class = require("hlchunk.utils.class")

local utils = require("hlchunk.utils.utils")
local indentHelper = require("hlchunk.utils.indentHelper")
local Scope = require("hlchunk.utils.Scope")

local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = utils.ROWS_INDENT_RETCODE

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "indent",
        augroup_name = "hlchunk_indent",
        hl_base_name = "HLIndent",
        ns_id = api.nvim_create_namespace("indent"),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = IndentConf(conf)
end

---@class IndentMod : BaseMod
---@field conf IndentConf
---@field render fun(self: IndentMod, range?: Scope)
---@field renderLine function
---@overload fun(conf?: UserIndentConf, meta?: MetaInfo): IndentMod
local IndentMod = class(BaseMod, constructor)

function IndentMod:renderLine(bufnr, index, blankLen)
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
        local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % #self.meta.hl_name_list + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = offset + (i - 1) * sw

        -- when use treesitter, without this judge, when paste code will over render
        if row_opts.virt_text_win_col < 0 or row_opts.virt_text_win_col >= fn.indent(index) then
            -- if the len of the line is 0, so we should render the indent by its context
            if api.nvim_buf_get_lines(bufnr, index - 1, index, false)[1] ~= "" then
                return
            end
        end
        api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, index - 1, 0, row_opts)
    end
end

function IndentMod:render(range)
    if (not self.conf.enable) or self.conf.exclude_filetypes[vim.bo.filetype] or fn.shiftwidth() == 0 then
        return
    end

    self:clear(range)

    local retcode, rows_indent = utils.get_rows_indent(self, range, {
        use_treesitter = self.conf.use_treesitter,
        virt_indent = true,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS then
        if self.conf.notify then
            self:notify("[hlchunk.indent]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
        return
    end

    for index, _ in pairs(rows_indent) do
        self:renderLine(range.bufnr, index, rows_indent[index])
    end
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local render_cb = function(info)
        local ft = vim.filetype.match({ buf = info.buf })
        if not ft or #ft == 0 then
            return
        end

        -- get all changed wins except all item
        local changedWins = {}
        if info.event == "WinScrolled" then
            for win, _ in pairs(vim.v.event) do
                if win ~= "all" then
                    table.insert(changedWins, tonumber(win))
                end
            end
        else
            local cur_win = api.nvim_get_current_win()
            changedWins = { cur_win }
        end

        -- get them showed topline and botline, then make a scope to render
        for _, winnr in ipairs(changedWins) do
            local wininfo = fn.getwininfo(winnr) --[[@as table]]
            local topline = wininfo[1].topline
            local botline = wininfo[1].botline
            local scope = Scope(info.buf, topline - 1, botline - 1)
            api.nvim_win_call(winnr, function()
                self:render(scope)
            end)
        end
    end

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = self.meta.augroup_name,
        callback = render_cb,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter" }, {
        group = self.meta.augroup_name,
        callback = render_cb,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.meta.augroup_name,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = render_cb,
    })
end

return IndentMod
