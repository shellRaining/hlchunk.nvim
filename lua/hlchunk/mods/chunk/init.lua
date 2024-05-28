local BaseMod = require("hlchunk.mods.base_mod")
local ChunkConf = require("hlchunk.mods.chunk.chunk_conf")
local chunkHelper = require("hlchunk.utils.chunkHelper")
local LoopTask = require("hlchunk.utils.loopTask")
local debounce = require("hlchunk.utils.debounce").debounce

local class = require("hlchunk.utils.class")
local utils = require("hlchunk.utils.utils")

local api = vim.api
local fn = vim.fn
local CHUNK_RANGE_RET = utils.CHUNK_RANGE_RET

---@class ChunkMetaInfo : MetaInfo

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "chunk",
        augroup_name = "hlchunk_chunk",
        hl_base_name = "HLChunk",
        ns_id = api.nvim_create_namespace("chunk"),
        task = nil,
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

local function utf8_split(inputstr)
    local list = {}
    for uchar in string.gmatch(inputstr, "[^\128-\191][\128-\191]*") do
        table.insert(list, uchar)
    end
    return list
end
---@param i number
---@param j number
---@return table
local function rangeFromTo(i, j)
    local t = {}
    local step = 1
    if i > j then
        step = -1
    end
    for x = i, j, step do
        table.insert(t, x)
    end
    return t
end

function ChunkMod:render(range, opts)
    if not self:shouldRender() or range == nil then
        return
    end
    opts = opts or { error = false }
    if self.meta.task then
        self.meta.task:stop()
        self.meta.task = nil
    end
    local text_hl = opts.error and "HLChunk2" or "HLChunk1"
    local beg_row = range.start + 1
    local end_row = range.finish + 1
    local beg_blank_len = fn.indent(beg_row) --[[@as number]]
    local end_blank_len = fn.indent(end_row) --[[@as number]]
    local shiftwidth = fn.shiftwidth() --[[@as number]]
    local start_col = math.max(math.min(beg_blank_len, end_blank_len) - shiftwidth, 0)
    local leftcol = fn.winsaveview().leftcol
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 100,
    }

    local virt_text_list = {}
    local row_list = {}
    local virt_text_win_col_list = {}

    if beg_blank_len > 0 then
        local virt_text_len = beg_blank_len - start_col
        local beg_virt_text = self.conf.chars.left_top .. self.conf.chars.horizontal_line:rep(virt_text_len - 1)
        local virt_text, virt_text_win_col = chunkHelper.calc(beg_virt_text, start_col, leftcol)
        local char_list = fn.reverse(utf8_split(virt_text))
        vim.list_extend(virt_text_list, char_list)
        vim.list_extend(row_list, vim.fn["repeat"]({ beg_row - 1 }, virt_text_len))
        vim.list_extend(virt_text_win_col_list, rangeFromTo(virt_text_win_col + virt_text_len - 1, virt_text_win_col))
    end
    local mid = self.conf.chars.vertical_line:rep(end_row - beg_row - 1)
    vim.list_extend(virt_text_list, utf8_split(mid))
    vim.list_extend(row_list, rangeFromTo(beg_row, end_row - 2)) -- beg_row and end_row are 1-based, so -2
    vim.list_extend(virt_text_win_col_list, vim.fn["repeat"]({ start_col - leftcol }, end_row - beg_row - 1))
    if end_blank_len > 0 then
        local virt_text_len = end_blank_len - start_col
        local end_virt_text = self.conf.chars.left_bottom
            .. self.conf.chars.horizontal_line:rep(virt_text_len - 2)
            .. self.conf.chars.right_arrow
        local virt_text, virt_text_win_col = chunkHelper.calc(end_virt_text, start_col, leftcol)
        local char_list = utf8_split(virt_text)
        vim.list_extend(virt_text_list, char_list)
        vim.list_extend(row_list, vim.fn["repeat"]({ end_row - 1 }, virt_text_len))
        vim.list_extend(virt_text_win_col_list, rangeFromTo(virt_text_win_col, virt_text_win_col + virt_text_len - 1))
    end

    self.meta.task = LoopTask(function(vt, row, vt_win_col)
        row_opts.virt_text = { { vt, text_hl } }
        row_opts.virt_text_win_col = vt_win_col
        api.nvim_buf_set_extmark(range.bufnr, self.meta.ns_id, row, 0, row_opts)
    end, "linear", self.conf.duration, virt_text_list, row_list, virt_text_win_col_list)
    self.meta.task:start()
end

function ChunkMod:createAutocmd()
    BaseMod.createAutocmd(self)
    local render_cb = function(event)
        local ft = vim.filetype.match({ buf = event.buf })
        if not ft or #ft == 0 then
            return
        end

        local bufnr = event.buf
        local winnr = api.nvim_get_current_win()
        local pos = api.nvim_win_get_cursor(winnr)

        local ret_code, range = utils.get_chunk_range({
            pos = { bufnr = bufnr, row = pos[1] - 1, col = pos[2] },
            use_treesitter = self.conf.use_treesitter,
        })

        self:clear({ bufnr = bufnr, start = 0, finish = -2 })
        if ret_code == CHUNK_RANGE_RET.OK then
            self:render(range, { error = false })
        elseif ret_code == CHUNK_RANGE_RET.NO_CHUNK then
            if self.meta.task then
                self.meta.task:stop()
                self.meta.task = nil
            end
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
