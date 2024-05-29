local BaseMod = require("hlchunk.mods.base_mod")
local IndentConf = require("hlchunk.mods.indent.indent_conf")
local class = require("hlchunk.utils.class")
local utils = require("hlchunk.utils.utils")
local indentHelper = require("hlchunk.utils.indentHelper")
local Scope = require("hlchunk.utils.scope")
local debounce = require("hlchunk.utils.debounce").debounce

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

function IndentMod:renderLine(bufnr, index, blankLen, leftcol, sw)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    local render_char_num, offset, shadow_char_num = indentHelper.calc(blankLen, leftcol, sw)

    for i = 1, render_char_num do
        local char = self.conf.chars[(i - 1 + shadow_char_num) % #self.conf.chars + 1]
        local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % #self.meta.hl_name_list + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = offset + (i - 1) * sw

        -- when use treesitter, without this judge, when paste code will over render
        if row_opts.virt_text_win_col < 0 or row_opts.virt_text_win_col >= fn.indent(index) then
            -- if the len of the line is 0, and have leftcol, we should draw it indent by context
            if api.nvim_buf_get_lines(bufnr, index - 1, index, false)[1] ~= "" then
                return
            end
        end
        api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, index - 1, 0, row_opts)
    end
end

function IndentMod:render(range)
    if not self:shouldRender() then
        return
    end

    range = range or Scope(0, fn.line("w0") - 1, fn.line("w$") - 1)
    self:clear(range)

    local retcode, rows_indent = utils.get_rows_indent({
        use_treesitter = self.conf.use_treesitter,
        virt_indent = true,
        range = range,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS and self.conf.use_treesitter then
        if self.conf.notify then
            self:notify("[hlchunk.indent]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
        return
    end

    local leftcol = fn.winsaveview().leftcol
    local sw = api.nvim_buf_call(range.bufnr, function()
        return fn.shiftwidth()
    end)
    for index, _ in pairs(rows_indent) do
        self:renderLine(range.bufnr, index, rows_indent[index], leftcol, sw)
    end
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local debounce_render = debounce(function(range)
        self:render(range)
    end, 50)
    local render_cb = function(event)
        if not api.nvim_buf_is_valid(event.buf) then
            return
        end
        local ft = vim.filetype.match({ buf = event.buf })
        if indentHelper.is_blank_filetype(ft) then
            return
        end
        local changedWins = indentHelper.get_active_wins(event)

        -- get them showed topline and botline, then make a scope to render
        for _, winnr in ipairs(changedWins) do
            local range = indentHelper.get_win_range(winnr)
            local ahead_lines = self.conf.ahead_lines
            range.start = math.max(0, range.start - ahead_lines)
            range.finish = math.min(api.nvim_buf_line_count(range.bufnr) - 1, range.finish + ahead_lines)
            if range.bufnr == event.buf then
                api.nvim_win_call(winnr, function()
                    debounce_render(range)
                end)
            end
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
