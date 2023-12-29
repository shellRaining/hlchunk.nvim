local BaseMod = require("hlchunk.mods.BaseMod")
local ChunkConf = require("hlchunk.mods.Chunk.ChunkConf")

local class = require("hlchunk.utils.class")
local utils = require("hlchunk.utils.utils")

local api = vim.api
local fn = vim.fn
local CHUNK_RANGE_RET = utils.CHUNK_RANGE_RET

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "chunk",
        augroup_name = "hlchunk_chunk",
        hl_base_name = "HLChunk",
        ns_id = api.nvim_create_namespace("chunk"),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = ChunkConf(conf)
end

---@class ChunkMod : BaseMod
---@field conf ChunkConf
---@field render fun(self: ChunkMod, range: Scope, opts?: {error: boolean})
---@overload fun(conf?: UserChunkConf, meta?: MetaInfo): ChunkMod
local ChunkMod = class(BaseMod, constructor)

-- chunk_mod can use text object, so add a new function extra to handle it
function ChunkMod:enable()
    BaseMod.enable(self)
    self:extra()
end

function ChunkMod:render(range, opts)
    if not self:shouldRender() then
        return
    end
    opts = opts or { error = false }
    self:clear()

    local text_hl = opts.error and "HLChunk2" or "HLChunk1"
    local beg_row = range.start + 1
    local end_row = range.finish + 1
    local beg_blank_len = fn.indent(beg_row) --[[@as number]]
    local end_blank_len = fn.indent(end_row) --[[@as number]]
    local shiftwidth = fn.shiftwidth() --[[@as number]]
    local start_col = math.max(math.min(beg_blank_len, end_blank_len) - shiftwidth, 0)
    local offset = fn.winsaveview().leftcol
    local get_width = api.nvim_strwidth
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 100,
    }

    -- render beg_row
    if beg_blank_len > 0 then
        local virt_text_len = beg_blank_len - start_col
        local beg_virt_text = self.conf.chars.left_top .. self.conf.chars.horizontal_line:rep(virt_text_len - 1)

        -- because the char is utf-8, so we need to get the utf-8 byte index
        if not utils.col_in_screen(start_col) then
            local byte_idx = math.min(offset - start_col, virt_text_len)
            if byte_idx > get_width(beg_virt_text) then
                byte_idx = get_width(beg_virt_text)
            end
            local utfBeg = vim.str_byteindex(beg_virt_text, byte_idx)
            beg_virt_text = beg_virt_text:sub(utfBeg + 1)
        end

        row_opts.virt_text = { { beg_virt_text, text_hl } }
        row_opts.virt_text_win_col = math.max(start_col - offset, 0)
        api.nvim_buf_set_extmark(0, self.meta.ns_id, beg_row - 1, 0, row_opts)
    end

    -- render end_row
    if end_blank_len > 0 then
        local virt_text_len = end_blank_len - start_col
        local end_virt_text = self.conf.chars.left_bottom
            .. self.conf.chars.horizontal_line:rep(end_blank_len - start_col - 2)
            .. self.conf.chars.right_arrow

        if not utils.col_in_screen(start_col) then
            local byte_idx = math.min(offset - start_col, virt_text_len)
            if byte_idx > get_width(end_virt_text) then
                byte_idx = get_width(end_virt_text)
            end
            local utfBeg = vim.str_byteindex(end_virt_text, byte_idx)
            end_virt_text = end_virt_text:sub(utfBeg + 1)
        end
        row_opts.virt_text = { { end_virt_text, text_hl } }
        row_opts.virt_text_win_col = math.max(start_col - offset, 0)
        api.nvim_buf_set_extmark(0, self.meta.ns_id, end_row - 1, 0, row_opts)
    end

    -- render middle section
    for i = beg_row + 1, end_row - 1 do
        row_opts.virt_text = { { self.conf.chars.vertical_line, text_hl } }
        row_opts.virt_text_win_col = start_col - offset
        local space_tab = (" "):rep(shiftwidth)
        local line_val = fn.getline(i):gsub("\t", space_tab)
        if #line_val <= start_col or fn.indent(i) > start_col then
            if utils.col_in_screen(start_col) then
                api.nvim_buf_set_extmark(0, self.meta.ns_id, i - 1, 0, row_opts)
            end
        end
    end
end

function ChunkMod:createAutocmd()
    BaseMod.createAutocmd(self)

    local render_cb = function(info)
        local ft = vim.filetype.match({ buf = info.buf })
        -- TODO: need refactoro
        if not ft or #ft == 0 then
            return
        end

        local ret_code, range = utils.get_chunk_range(self, fn.line("."), {
            use_treesitter = self.conf.use_treesitter,
        })
        if ret_code == CHUNK_RANGE_RET.OK then
            self:render(range, { error = false })
        elseif ret_code == CHUNK_RANGE_RET.NO_CHUNK then
            self:clear()
        elseif ret_code == CHUNK_RANGE_RET.CHUNK_ERR then
            self:render(range, { error = true })
        elseif ret_code == CHUNK_RANGE_RET.NO_TS then
            self:notify("[hlchunk.chunk]: no parser for " .. vim.bo.filetype, nil, { once = true })
        end
    end
    api.nvim_create_autocmd({ "CursorMovedI", "CursorMoved" }, {
        group = self.meta.augroup_name,
        callback = render_cb,
    })
    api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        group = self.meta.augroup_name,
        callback = render_cb,
    })
    api.nvim_create_autocmd({ "UIEnter", "BufWinEnter" }, {
        group = self.meta.augroup_name,
        callback = function()
            -- get the file size of the current buffer
            local ok, status = pcall(fn.getfsize, fn.expand("%"))
            if ok and status >= self.conf.max_file_size then
                self:notify("File is too large, chunk.nvim will not be loaded")
                ChunkMod:disable()
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
        local retcode, cur_chunk_range = utils.get_chunk_range(self, nil, {
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
