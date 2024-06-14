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
---@field pre_leftcol number
---@field cache Cache

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "indent",
        augroup_name = "hlchunk_indent",
        hl_base_name = "HLIndent",
        ns_id = api.nvim_create_namespace("indent"),
        shiftwidth = fn.shiftwidth(),
        pre_leftcol = 0,
        leftcol = fn.winsaveview().leftcol,
        cache = Cache("bufnr", "line"),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = IndentConf(conf)
end

---@class IndentMod : BaseMod
---@field conf IndentConf
---@field meta IndentMetaInfo
---@field render fun(self: IndentMod, range: Scope, opts: {lazy: boolean})
---@field narrowRange fun(self: IndentMod, range: Scope): Scope
---@field calcRenderInfo fun(self: IndentMod, range: Scope): table<number, string>
---@field setmark function
---@overload fun(conf?: UserIndentConf, meta?: MetaInfo): IndentMod
local IndentMod = class(BaseMod, constructor)

local pos2info = Cache("bufnr", "line", "col")
local pos2id = Cache("bufnr", "line", "col")

function IndentMod:disable()
    pos2info:clear()
    pos2id:clear()
    BaseMod.disable(self)
end

function IndentMod:narrowRange(range)
    local start = range.start
    local finish = range.finish
    for i = range.start, range.finish do
        if not self.meta.cache:has(range.bufnr, i) then
            start = i
            break
        end
    end
    for i = range.finish, range.start, -1 do
        if not self.meta.cache:has(range.bufnr, i) then
            finish = i
            break
        end
    end
    return Scope(range.bufnr, start, finish)
end

function IndentMod:calcRenderInfo(range)
    -- calc render info
    local char_num = #self.conf.chars
    local style_num = #self.meta.hl_name_list
    local leftcol = self.meta.leftcol
    local sw = self.meta.shiftwidth
    local render_info = {}
    for lnum = range.start, range.finish do
        local blankLen = self.meta.cache:get(range.bufnr, lnum) --[[@as string]]
        local render_char_num, offset, shadow_char_num = indentHelper.calc(blankLen, leftcol, sw)
        for i = 1, render_char_num do
            local win_col = offset  + (i - 1) * sw
            local char = self.conf.chars[(i - 1 + shadow_char_num) % char_num + 1]
            local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % style_num + 1]
            table.insert(render_info, {
                lnum = lnum,
                virt_text_win_col = win_col,
                virt_text = { { char, style } },
            })
            pos2info:set(range.bufnr, lnum, win_col, { char, style })
        end
    end

    return render_info
end

function IndentMod:setmark(bufnr, render_info)
    -- render
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    for _, v in pairs(render_info) do
        row_opts.virt_text = v.virt_text
        row_opts.virt_text_win_col = v.virt_text_win_col
        if not pos2id:get(bufnr, v.lnum, v.virt_text_win_col) then
            local id = api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, v.lnum, 0, row_opts)
            pos2id:set(bufnr, v.lnum, v.virt_text_win_col, id)
        end
    end
end

function IndentMod:render(range, opts)
    opts = opts or { lazy = false }
    if not opts.lazy then
        self:clear(Scope(range.bufnr, 0, api.nvim_buf_line_count(range.bufnr)))
        self.meta.cache:clear(range.bufnr)
        pos2id:clear(range.bufnr)
        pos2info:clear(range.bufnr)
    end

    local narrowed_range = self:narrowRange(range)
    -- calculate indent
    local retcode, rows_indent = indentHelper.get_rows_indent(narrowed_range, {
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
    local render_info = self:calcRenderInfo(narrowed_range)
    self:setmark(range.bufnr, render_info)
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local render_cb = function(event, opts)
        opts = opts or { lazy = false }
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
                self.meta.pre_leftcol = self.meta.leftcol
                self.meta.leftcol = fn.winsaveview().leftcol
                if self.meta.pre_leftcol ~= self.meta.leftcol then
                    opts.lazy = false
                end
                self:render(range, opts)
            end)
        end
    end
    local throttle_render_cb = throttle(render_cb, self.conf.delay)
    local throttle_render_cb_with_pre_hook = function(event, opts)
        opts = opts or { lazy = false }
        local bufnr = event.buf
        if not (api.nvim_buf_is_valid(bufnr) and self:shouldRender(bufnr)) then
            return
        end
        throttle_render_cb(event, opts)
    end

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = self.meta.augroup_name,
        callback = function(e)
            throttle_render_cb_with_pre_hook(e, { lazy = true })
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = self.meta.augroup_name,
        callback = function(e)
            throttle_render_cb_with_pre_hook(e, { lazy = false })
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
