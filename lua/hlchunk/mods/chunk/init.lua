local BaseMod = require("hlchunk.mods.base_mod")
local ChunkConf = require("hlchunk.mods.chunk.chunk_conf")
local chunkHelper = require("hlchunk.utils.chunkHelper")
local LoopTask = require("hlchunk.utils.loopTask")
local debounce = require("hlchunk.utils.debounce").debounce
local Pos = require("hlchunk.utils.position")
local Scope = require("hlchunk.utils.scope")

local class = require("hlchunk.utils.class")
local utils = require("hlchunk.utils.utils")

local api = vim.api
local fn = vim.fn
local CHUNK_RANGE_RET = utils.CHUNK_RANGE_RET
local rangeFromTo = chunkHelper.rangeFromTo
local utf8Split = chunkHelper.utf8Split
local shallowCmp = chunkHelper.shallowCmp

---@class ChunkMetaInfo : MetaInfo

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "chunk",
        augroup_name = "hlchunk_chunk",
        hl_base_name = "HLChunk",
        ns_id = api.nvim_create_namespace("chunk"),
        task = nil,
        pre_virt_text_list = {},
        pre_row_list = {},
        pre_virt_text_win_col_list = {},
        pre_is_error = false,
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = ChunkConf(conf)
end

---@class ChunkMod : BaseMod
---@field conf ChunkConf
---@field meta ChunkMetaInfo
---@field render fun(self: ChunkMod, range: Scope, opts?: {error: boolean})
---@overload fun(conf?: UserChunkConf, meta?: MetaInfo): ChunkMod
local ChunkMod = class(BaseMod, constructor)

-- chunk_mod can use text object, so add a new function extra to handle it
function ChunkMod:enable()
    BaseMod.enable(self)
    self:extra()
end

function ChunkMod:stopRender()
    if self.meta.task then
        self.meta.task:stop()
        self.meta.task = nil
    end
end

function ChunkMod:updatePreState(virt_text_list, row_list, virt_text_win_col_list, is_error)
    self.meta.pre_virt_text_list = virt_text_list
    self.meta.pre_row_list = row_list
    self.meta.pre_virt_text_win_col_list = virt_text_win_col_list
    self.meta.pre_is_error = is_error
end

function ChunkMod:render(range, opts)
    if not self:shouldRender() or range == nil then
        return
    end
    opts = opts or { error = false }
    self:stopRender()
    local text_hl = opts.error and "HLChunk2" or "HLChunk1"
    local beg_row = range.start + 1
    local end_row = range.finish + 1
    local beg_blank_len = fn.indent(beg_row) --[[@as number]]
    local end_blank_len = fn.indent(end_row) --[[@as number]]
    local shiftwidth = fn.shiftwidth() --[[@as number]]
    local start_col = math.max(math.min(beg_blank_len, end_blank_len) - shiftwidth, 0)
    local leftcol = fn.winsaveview().leftcol

    local virt_text_list = {}
    local row_list = {}
    local virt_text_win_col_list = {}

    if beg_blank_len > 0 then
        local virt_text_len = beg_blank_len - start_col
        local beg_virt_text = self.conf.chars.left_top .. self.conf.chars.horizontal_line:rep(virt_text_len - 1)
        local virt_text, virt_text_win_col = chunkHelper.calc(beg_virt_text, start_col, leftcol)
        local char_list = fn.reverse(utf8Split(virt_text))
        vim.list_extend(virt_text_list, char_list)
        vim.list_extend(row_list, vim.fn["repeat"]({ beg_row - 1 }, #char_list))
        vim.list_extend(virt_text_win_col_list, rangeFromTo(virt_text_win_col + #char_list - 1, virt_text_win_col, -1))
    end
    local mid_char_nums = end_row - beg_row - 1
    local mid = self.conf.chars.vertical_line:rep(mid_char_nums)
    local chars = (start_col - leftcol < 0) and vim.fn["repeat"]({ "" }, mid_char_nums) or utf8Split(mid)
    vim.list_extend(virt_text_list, chars)
    vim.list_extend(row_list, rangeFromTo(beg_row, end_row - 2)) -- beg_row and end_row are 1-based, so -2
    vim.list_extend(virt_text_win_col_list, vim.fn["repeat"]({ start_col - leftcol }, end_row - beg_row - 1))
    if end_blank_len > 0 then
        local virt_text_len = end_blank_len - start_col
        local end_virt_text = self.conf.chars.left_bottom
            .. self.conf.chars.horizontal_line:rep(virt_text_len - 2)
            .. self.conf.chars.right_arrow
        local virt_text, virt_text_win_col = chunkHelper.calc(end_virt_text, start_col, leftcol)
        local char_list = utf8Split(virt_text)
        vim.list_extend(virt_text_list, char_list)
        vim.list_extend(row_list, vim.fn["repeat"]({ end_row - 1 }, virt_text_len))
        vim.list_extend(virt_text_win_col_list, rangeFromTo(virt_text_win_col, virt_text_win_col + virt_text_len - 1))
    end

    if
        shallowCmp(virt_text_list, self.meta.pre_virt_text_list)
        and shallowCmp(row_list, self.meta.pre_row_list)
        and shallowCmp(virt_text_win_col_list, self.meta.pre_virt_text_win_col_list)
        and self.meta.pre_is_error == opts.error
    then
        return
    end

    self:updatePreState(virt_text_list, row_list, virt_text_win_col_list, opts.error)
    self:clear(Scope(range.bufnr, 0, api.nvim_buf_line_count(range.bufnr)))

    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 100,
    }
    if self.conf.delay == 0 then
        for i, vt in ipairs(virt_text_list) do
            row_opts.virt_text = { { vt, text_hl } }
            row_opts.virt_text_win_col = virt_text_win_col_list[i]
            api.nvim_buf_set_extmark(range.bufnr, self.meta.ns_id, row_list[i], 0, row_opts)
        end
    else
        self.meta.task = LoopTask(function(vt, row, vt_win_col)
            row_opts.virt_text = { { vt, text_hl } }
            row_opts.virt_text_win_col = vt_win_col
            api.nvim_buf_set_extmark(range.bufnr, self.meta.ns_id, row, 0, row_opts)
        end, "linear", self.conf.duration, virt_text_list, row_list, virt_text_win_col_list)
        self.meta.task:start()
    end
end

function ChunkMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local render_cb = function(event)
        if not api.nvim_buf_is_valid(event.buf) then
            return
        end
        local ft = vim.filetype.match({ buf = event.buf })
        if not ft or #ft == 0 then
            return
        end

        local bufnr = event.buf
        local winnr = api.nvim_get_current_win()
        local pos = api.nvim_win_get_cursor(winnr)

        local ret_code, range = utils.get_chunk_range({
            pos = Pos(bufnr, pos[1] - 1, pos[2]),
            use_treesitter = self.conf.use_treesitter,
        })

        if ret_code == CHUNK_RANGE_RET.OK then
            self:render(range, { error = false })
        elseif ret_code == CHUNK_RANGE_RET.NO_CHUNK then
            self:clear(Scope(bufnr, 0, api.nvim_buf_line_count(bufnr)))
            self:updatePreState({}, {}, {}, false)
        elseif ret_code == CHUNK_RANGE_RET.CHUNK_ERR then
            self:render(range, { error = true })
        elseif ret_code == CHUNK_RANGE_RET.NO_TS then
            self:notify("[hlchunk.chunk]: no parser for " .. ft, nil, { once = true })
        end
    end
    local debounce_render = debounce(render_cb, self.conf.delay)

    api.nvim_create_autocmd({ "CursorMovedI", "CursorMoved" }, {
        group = self.meta.augroup_name,
        callback = debounce_render,
    })
    api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        group = self.meta.augroup_name,
        callback = debounce_render,
    })
    api.nvim_create_autocmd({ "UIEnter", "BufWinEnter" }, {
        group = self.meta.augroup_name,
        callback = function()
            -- get the file size of the current buffer
            local ok, status = pcall(fn.getfsize, fn.expand("%"))
            if ok and status >= self.conf.max_file_size then
                self:notify("File is too large, chunk.nvim will not be loaded")
                self:disable()
            end
        end,
    })
end

function ChunkMod:extra()
    local textobject = self.conf.textobject
    if #textobject == 0 then
        return
    end
    vim.keymap.set({ "x", "o" }, textobject, function()
        local pos = api.nvim_win_get_cursor(0)
        local retcode, cur_chunk_range = utils.get_chunk_range({
            pos = { bufnr = 0, row = pos[1], col = pos[2] },
            use_treesitter = self.conf.use_treesitter,
        })
        if retcode ~= CHUNK_RANGE_RET.OK then
            return
        end
        local s_row = cur_chunk_range.start + 1
        local e_row = cur_chunk_range.finish + 1
        local ctrl_v = api.nvim_replace_termcodes("<C-v>", true, true, true)
        local cur_mode = vim.fn.mode()
        if cur_mode == "v" or cur_mode == "V" or cur_mode == ctrl_v then
            vim.cmd("normal! " .. cur_mode)
        end

        api.nvim_win_set_cursor(0, { s_row, 0 })
        vim.cmd("normal! V")
        api.nvim_win_set_cursor(0, { e_row, 0 })
    end)
end

return ChunkMod
