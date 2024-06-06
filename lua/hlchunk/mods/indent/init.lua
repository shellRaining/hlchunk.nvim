local BaseMod = require("hlchunk.mods.base_mod")
local IndentConf = require("hlchunk.mods.indent.indent_conf")
local class = require("hlchunk.utils.class")
local indentHelper = require("hlchunk.utils.indentHelper")
local Scope = require("hlchunk.utils.scope")
local throttle = require("hlchunk.utils.debounce").throttle

local api = vim.api
local fn = vim.fn
local ROWS_INDENT_RETCODE = indentHelper.ROWS_INDENT_RETCODE

---@class IndentMetaInfo : MetaInfo

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

---@class IndentMod : BaseMod
---@field conf IndentConf
---@field meta IndentMetaInfo
---@field render fun(self: IndentMod, range: Scope)
---@field renderLine function
---@overload fun(conf?: UserIndentConf, meta?: MetaInfo): IndentMod
local IndentMod = class(BaseMod, constructor)

function IndentMod:renderLine(bufnr, index, blankLen)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    local render_char_num, offset, shadow_char_num =
        indentHelper.calc(blankLen, self.meta.leftcol, self.meta.shiftwidth)

    for i = 1, render_char_num do
        local char = self.conf.chars[(i - 1 + shadow_char_num) % #self.conf.chars + 1]
        local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % #self.meta.hl_name_list + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = offset + (i - 1) * self.meta.shiftwidth

        -- when use treesitter, without this judge, when paste code will over render
        -- if row_opts.virt_text_win_col < 0 or row_opts.virt_text_win_col >= fn.indent(index) then
        --     vim.notify(tostring(index))
        --     -- if the len of the line is 0, and have leftcol, we should draw it indent by context
        --     if api.nvim_buf_get_lines(bufnr, index - 1, index, false)[1] ~= "" then
        --         return
        --     end
        -- end
        api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, index - 1, 0, row_opts)
    end
end

function IndentMod:render(range)
    if not self:shouldRender(range.bufnr) then
        return
    end
    self:clear(range)

    local retcode, rows_indent = indentHelper.get_rows_indent(range, {
        use_treesitter = self.conf.use_treesitter,
        virt_indent = true,
    })
    if retcode == ROWS_INDENT_RETCODE.NO_TS and self.conf.use_treesitter then
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
                self.meta.shiftwidth = api.nvim_get_option_value("shiftwidth", { buf = bufnr })
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
        callback = throttle_render_cb_with_pre_hook,
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
