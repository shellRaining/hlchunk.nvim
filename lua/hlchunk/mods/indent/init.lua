local BaseMod = require("hlchunk.mods.base_mod")
local IndentConf = require("hlchunk.mods.indent.indent_conf")
local class = require("hlchunk.utils.class")
local indentHelper = require("hlchunk.utils.indentHelper")
local Scope = require("hlchunk.utils.scope")
local Cache = require("hlchunk.utils.cache")
local throttle = require("hlchunk.utils.timer").debounce_throttle
local cFunc = require("hlchunk.utils.cFunc")

local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = indentHelper.ROWS_INDENT_RETCODE

---@class HlChunk.IndentMetaInfo : HlChunk.MetaInfo

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "indent",
        augroup_name = "hlchunk_indent",
        hl_base_name = "HLIndent",
        ns_id = api.nvim_create_namespace("indent"),
        shiftwidth = fn.shiftwidth(),
        leftcol = fn.winsaveview().leftcol,
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = IndentConf(conf)
end

---@class HlChunk.RenderInfo
---@field lnum number
---@field virt_text_win_col number
---@field virt_text table
---@field level number

---@class HlChunk.IndentMod : HlChunk.BaseMod
---@field conf HlChunk.IndentConf
---@field meta HlChunk.IndentMetaInfo
---@field render fun(self: HlChunk.IndentMod, range: HlChunk.Scope, opts: {lazy: boolean})
---@field calcRenderInfo fun(self: HlChunk.IndentMod, range: HlChunk.Scope): HlChunk.RenderInfo
---@field setmark function
---@overload fun(conf?: HlChunk.UserIndentConf, meta?: HlChunk.MetaInfo): HlChunk.IndentMod
local IndentMod = class(BaseMod, constructor)

local indent_cache = Cache("bufnr", "line")
local pos2info = Cache("bufnr", "line", "col")
local pos2id = Cache("bufnr", "line", "col")

function IndentMod:disable()
    pos2info:clear()
    pos2id:clear()
    BaseMod.disable(self)
end

local function narrowRange(range)
    local start = range.start
    local finish = range.finish
    for i = start, finish do
        if not indent_cache:has(range.bufnr, i) then
            start = i
            break
        end
    end
    for i = finish, start, -1 do
        if not indent_cache:has(range.bufnr, i) then
            finish = i
            break
        end
    end
    return Scope(range.bufnr, start, finish)
end

function IndentMod:calcRenderInfo(range)
    local conf = self.conf
    local meta = self.meta
    local char_num = #conf.chars
    local style_num = #meta.hl_name_list
    local leftcol = meta.leftcol
    local sw = meta.shiftwidth
    local render_info = {}
    for lnum = range.start, range.finish do
        local blankLen = indent_cache:get(range.bufnr, lnum) --[[@as string]]
        local render_char_num, offset, shadow_char_num = indentHelper.calc(blankLen, leftcol, sw)
        for i = 1, render_char_num do
            local win_col = offset + (i - 1) * sw
            local char = conf.chars[(i - 1 + shadow_char_num) % char_num + 1]
            local style = meta.hl_name_list[(i - 1 + shadow_char_num) % style_num + 1]
            table.insert(render_info, {
                lnum = lnum,
                virt_text_win_col = win_col,
                virt_text = { { char, style } },
                level = i,
            })
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
    local bufnr = range.bufnr
    local conf = self.conf

    if not opts.lazy then
        self:clear({ bufnr = bufnr, start = 0, finish = api.nvim_buf_line_count(bufnr) - 1 })
        indent_cache:clear(bufnr)
        pos2id:clear(bufnr)
        pos2info:clear(bufnr)
    end

    local narrowed_range = narrowRange(range)
    local retcode, rows_indent = indentHelper.get_rows_indent(narrowed_range, {
        use_treesitter = conf.use_treesitter,
        virt_indent = true,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS and conf.use_treesitter then
        if conf.notify then
            self:notify("[hlchunk.indent]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
        return
    end

    -- get render_info and process it
    for lnum, indent in pairs(rows_indent) do
        indent_cache:set(bufnr, lnum, indent)
    end
    local render_info = self:calcRenderInfo(narrowed_range)
    for _, v in pairs(render_info) do
        pos2info:set(range.bufnr, v.lnum, v.virt_text_win_col, v.virt_text)
    end
    for _, filter in ipairs(self.conf.filter_list) do
        render_info = vim.tbl_filter(filter, render_info)
    end

    -- render
    self:setmark(bufnr, render_info)
end

function IndentMod:createThrottledCallback(callback)
    local throttledCallback = throttle(callback, self.conf.delay)
    return function(event, opts)
        opts = opts or { lazy = false }
        local bufnr = event.buf
        if not (api.nvim_buf_is_valid(bufnr) and self:shouldRender(bufnr)) then
            return
        end
        throttledCallback(event, opts)
    end
end

function IndentMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local throttledCallback = self:createThrottledCallback(function(event, opts)
        opts = opts or { lazy = false }
        local bufnr = event.buf
        if not self:shouldRender(bufnr) then
            return
        end

        local wins = fn.win_findbuf(bufnr) or {}
        for _, winid in ipairs(wins) do
            local range = Scope(bufnr, fn.line("w0", winid) - 1, fn.line("w$", winid) - 1)
            local ahead_lines = self.conf.ahead_lines
            range.start = math.max(0, range.start - ahead_lines)
            range.finish = math.min(api.nvim_buf_line_count(bufnr) - 1, range.finish + ahead_lines)
            api.nvim_win_call(winid, function()
                self.meta.shiftwidth = cFunc.get_sw(bufnr)
                self.meta.leftcol = fn.winsaveview().leftcol
                self:render(range, opts)
            end)
        end
    end)

    local autocommands = {
        { events = { "User" }, pattern = "WinScrolledX", opts = { lazy = false } },
        { events = { "User" }, pattern = "WinScrolledY", opts = { lazy = true } },
        { events = { "TextChanged", "TextChangedI", "BufWinEnter" }, opts = { lazy = false } },
        { events = { "OptionSet" }, pattern = "list,shiftwidth,tabstop,expandtab", opts = { lazy = false } },
    }

    for _, cmd in ipairs(autocommands) do
        api.nvim_create_autocmd(cmd.events, {
            group = self.meta.augroup_name,
            pattern = cmd.pattern,
            callback = function(e)
                throttledCallback(e, cmd.opts)
            end,
        })
    end
end

return IndentMod
