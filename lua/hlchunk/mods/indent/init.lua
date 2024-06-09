local BaseMod = require("hlchunk.mods.base_mod")
local IndentConf = require("hlchunk.mods.indent.indent_conf")
local class = require("hlchunk.utils.class")
local indentHelper = require("hlchunk.utils.indentHelper")
local Scope = require("hlchunk.utils.scope")
local Cache = require("hlchunk.utils.cache")
local throttle = require("hlchunk.utils.timer").throttle
local cFunc = require("hlchunk.utils.cFunc")

local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = indentHelper.ROWS_INDENT_RETCODE

---@class IndentMetaInfo : MetaInfo
---@field cache Cache

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "indent",
        augroup_name = "hlchunk_indent",
        hl_base_name = "HLIndent",
        ns_id = api.nvim_create_namespace("indent"),
        shiftwidth = fn.shiftwidth(),
        leftcol = fn.winsaveview().leftcol,
        cache = Cache(),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = IndentConf(conf)
end

---@class IndentMod : BaseMod
---@field conf IndentConf
---@field meta IndentMetaInfo
---@field render fun(self: IndentMod, range: Scope)
---@field renderLine function
---@overload fun(conf?: UserIndentConf, meta?: MetaInfo): IndentMod
local IndentMod = class(BaseMod, constructor)

function IndentMod:render(range)
    self:clear(range)

    -- narrow the range that should get indent
    local non_cached_start = range.start
    local non_cached_finish = range.finish
    for i = range.start, range.finish do
        if not self.meta.cache:has(range.bufnr, i) then
            non_cached_start = i
            break
        end
    end
    for i = non_cached_start, range.finish do
        if self.meta.cache:has(range.bufnr, i) then
            non_cached_finish = i - 1
            break
        end
    end

    -- calculate indent
    local retcode, rows_indent = indentHelper.get_rows_indent(Scope(range.bufnr, non_cached_start, non_cached_finish), {
        use_treesitter = self.conf.use_treesitter,
        virt_indent = true,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS and self.conf.use_treesitter then
        if self.conf.notify then
            self:notify("[hlchunk.indent]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
        return
    end

    -- update cache
    for lnum, indent in pairs(rows_indent) do
        self.meta.cache:set(range.bufnr, lnum, indent)
    end

    -- calc render info
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    local char_num = #self.conf.chars
    local style_num = #self.meta.hl_name_list
    local render_info = {}
    for lnum = range.start, range.finish do
        local blankLen = self.meta.cache:get(range.bufnr, lnum)
        local render_char_num, offset, shadow_char_num =
            indentHelper.calc(blankLen, self.meta.leftcol, self.meta.shiftwidth)
        for i = 1, render_char_num do
            local char = self.conf.chars[(i - 1 + shadow_char_num) % char_num + 1]
            local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % style_num + 1]
            table.insert(render_info, {
                lnum = lnum,
                virt_text_win_col = offset + self.meta.leftcol + (i - 1) * self.meta.shiftwidth,
                virt_text = { { char, style } },
            })
        end
    end

    -- render
    for _, v in pairs(render_info) do
        row_opts.virt_text = v.virt_text
        row_opts.virt_text_win_col = v.virt_text_win_col
        api.nvim_buf_set_extmark(range.bufnr, self.meta.ns_id, v.lnum, 0, row_opts)
    end
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local render_cb = function(event)
        local bufnr = event.buf
        if not (api.nvim_buf_is_valid(bufnr) and self:shouldRender(bufnr)) then
            return
        end
        local wins = fn.win_findbuf(bufnr) or {}
        for _, winid in ipairs(wins) do
            local range = Scope(api.nvim_win_get_buf(winid), fn.line("w0", winid) - 1, fn.line("w$", winid) - 1)
            local ahead_lines = self.conf.ahead_lines
            range.start = math.max(0, range.start - ahead_lines)
            range.finish = math.min(api.nvim_buf_line_count(bufnr) - 1, range.finish + ahead_lines)
            api.nvim_win_call(winid, function()
                self.meta.shiftwidth = cFunc.get_sw(bufnr)
                self.meta.leftcol = fn.winsaveview().leftcol
                self:render(range)
            end)
        end
    end
    local throttle_render_cb = throttle(render_cb, self.conf.delay)
    local throttle_render_cb_with_pre_hook = function(event)
        local bufnr = event.buf
        if not (api.nvim_buf_is_valid(bufnr) and self:shouldRender(bufnr)) then
            return
        end
        throttle_render_cb(event)
    end

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = self.meta.augroup_name,
        callback = throttle_render_cb_with_pre_hook,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = self.meta.augroup_name,
        callback = function(e)
            self.meta.cache:clear(e.buf)
            throttle_render_cb_with_pre_hook(e)
        end,
    })
    api.nvim_create_autocmd({ "BufWinEnter" }, {
        group = self.meta.augroup_name,
        callback = throttle_render_cb_with_pre_hook,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.meta.augroup_name,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = throttle_render_cb_with_pre_hook,
    })
end

return IndentMod
