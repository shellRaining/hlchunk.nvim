local BaseMod = require("hlchunk.base_mod")
local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

---@class ChunkOpts: BaseModOpts
---@field use_treesitter boolean
---@field chars table<string, string>
---@field textobject string
---@field max_file_size number

---@class ChunkMod: BaseMod
---@field old_chunk_range table<number, number>
---@field options ChunkOpts
local chunk_mod = BaseMod:new({
    name = "chunk",
    old_chunk_range = { 1, 1 },
    options = {
        enable = true,
        notify = true,
        use_treesitter = true,
        support_filetypes = ft.support_filetypes,
        exclude_filetypes = ft.exclude_filetypes,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = {
            { fg = "#806d9c" },
        },
        textobject = "",
        max_file_size = 1024 * 1024,
    },
})

-- chunk_mod can use text object, so add a new function extra to handle it
function chunk_mod:enable()
    BaseMod.enable(self)
    self:extra()
end

-- set new virtual text to the right place
function chunk_mod:render(opts)
    if not self.options.enable or self.options.exclude_filetypes[vim.bo.ft] then
        return
    end

    opts = opts or { lazy = false }

    local cur_chunk_range = utils.get_chunk_range(self, nil, {
        use_treesitter = self.options.use_treesitter,
    })
    local old_chunk_range = self.old_chunk_range

    -- due to cur_chunk_range maybe nil, which means their is no chunk in this postion
    if not cur_chunk_range then
        self:clear()
        self.old_chunk_range = { 1, 1 }
        return
    end

    if opts.lazy and cur_chunk_range[1] == old_chunk_range[1] and cur_chunk_range[2] == old_chunk_range[2] then
        return
    end

    self.old_chunk_range = cur_chunk_range
    self:clear()
    self.ns_id = api.nvim_create_namespace(self.name)

    if cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local beg_blank_len = fn.indent(beg_row)
        local end_blank_len = fn.indent(end_row)
        local shiftwidth = fn.shiftwidth()
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
            local beg_virt_text = self.options.chars.left_top
                .. self.options.chars.horizontal_line:rep(virt_text_len - 1)

            -- because the char is utf-8, so we need to get the utf-8 byte index
            if not utils.col_in_screen(start_col) then
                local byte_idx = math.min(offset - start_col, virt_text_len)
                if byte_idx > get_width(beg_virt_text) then
                    byte_idx = get_width(beg_virt_text)
                end
                local utfBeg = vim.str_byteindex(beg_virt_text, byte_idx)
                beg_virt_text = beg_virt_text:sub(utfBeg + 1)
            end

            row_opts.virt_text = { { beg_virt_text, "HLChunk1" } }
            row_opts.virt_text_win_col = math.max(start_col - offset, 0)
            api.nvim_buf_set_extmark(0, self.ns_id, beg_row - 1, 0, row_opts)
        end

        -- render end_row
        if end_blank_len > 0 then
            local virt_text_len = end_blank_len - start_col
            local end_virt_text = self.options.chars.left_bottom
                .. self.options.chars.horizontal_line:rep(end_blank_len - start_col - 2)
                .. self.options.chars.right_arrow

            if not utils.col_in_screen(start_col) then
                local byte_idx = math.min(offset - start_col, virt_text_len)
                if byte_idx > get_width(end_virt_text) then
                    byte_idx = get_width(end_virt_text)
                end
                local utfBeg = vim.str_byteindex(end_virt_text, byte_idx)
                end_virt_text = end_virt_text:sub(utfBeg + 1)
            end
            row_opts.virt_text = { { end_virt_text, "HLChunk1" } }
            row_opts.virt_text_win_col = math.max(start_col - offset, 0)
            api.nvim_buf_set_extmark(0, self.ns_id, end_row - 1, 0, row_opts)
        end

        -- render middle section
        for i = beg_row + 1, end_row - 1 do
            row_opts.virt_text = { { self.options.chars.vertical_line, "HLChunk1" } }
            row_opts.virt_text_win_col = start_col - offset
            local space_tab = (" "):rep(shiftwidth)
            local line_val = fn.getline(i):gsub("\t", space_tab)
            if #line_val <= start_col or fn.indent(i) > start_col then
                if utils.col_in_screen(start_col) then
                    api.nvim_buf_set_extmark(0, self.ns_id, i - 1, 0, row_opts)
                end
            end
        end
    end
end

function chunk_mod:enable_mod_autocmd()
    BaseMod.enable_mod_autocmd(self)

    api.nvim_create_autocmd({ "CursorMovedI", "CursorMoved" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = chunk_mod.old_win_info

            if cur_win_info.leftcol ~= old_win_info.leftcol then
                chunk_mod:render({ lazy = false })
            elseif cur_win_info.lnum ~= old_win_info.lnum then
                chunk_mod:render({ lazy = true })
            end

            chunk_mod.old_win_info = cur_win_info
        end,
    })
    api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render({ lazy = false })
        end,
    })
    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = chunk_mod.old_win_info

            if cur_win_info.leftcol ~= old_win_info.leftcol then
                chunk_mod:render({ lazy = false })
            elseif cur_win_info.lnum ~= old_win_info.lnum then
                chunk_mod:render({ lazy = true })
            end

            chunk_mod.old_win_info = cur_win_info
        end,
    })
    api.nvim_create_autocmd({ "UIEnter", "BufWinEnter" }, {
        group = self.augroup_name,
        callback = function()
            -- get the file size of the current buffer
            local ok, status = pcall(fn.getfsize, fn.expand("%"))
            if ok and status >= chunk_mod.options.max_file_size then
                self:notify("File is too large, chunk.nvim will not be loaded")
                chunk_mod:disable()
            end
        end,
    })
end

function chunk_mod:extra()
    local textobject = self.options.textobject
    if #textobject == 0 then
        return
    end
    vim.keymap.set({ "x", "o" }, textobject, function()
        local cur_chunk_range = utils.get_chunk_range(self, nil, {
            use_treesitter = self.options.use_treesitter,
        })
        if not cur_chunk_range then
            return
        end

        local s_row, e_row = unpack(cur_chunk_range)
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

return chunk_mod
