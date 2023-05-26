local BaseMod = require("hlchunk.base_mod")
local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local timer = require("hlchunk.utils.timer")
local ctx_manager = require("hlchunk.utils.context_manager")
local ani_manager = require("hlchunk.utils.animation_manager")
local api = vim.api
local fn = vim.fn

local chunk_mod = BaseMod:new({
    name = "chunk",
    options = {
        enable = true,
        use_treesitter = true,
        support_filetypes = ft.support_filetypes,
        exclude_filetypes = ft.exclude_filetypes,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            left_arrow = "<",
            bottom_arrow = "V",
            right_arrow = ">",
        },
        interval = 8,
        style = {
            { fg = "#806d9c" },
        },
        textobject = "",
    },
})

-- set new virtual text to the right place
function chunk_mod:render()
    if not self.options.enable or self.options.exclude_filetypes[vim.bo.ft] then
        return
    end

    self.ns_id = api.nvim_create_namespace("hlchunk")

    local cur_chunk_range = utils.get_chunk_range(nil, { use_treesitter = self.options.use_treesitter })
    if cur_chunk_range and cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local same = ctx_manager.is_same_context(beg_row, end_row)

        if (not ani_manager.get_running() and not same) or not same then
            local beg_blank_len, end_blank_len = fn.indent(beg_row), fn.indent(end_row)
            local start_col = math.max(math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth, 0)

            ani_manager.set_running(true)
            self:clear()

            local opts = { virt_text = {}, offset = {}, line_num = {} }
            local start_range = beg_row - beg_blank_len + start_col
            local end_range = end_row + end_blank_len - start_col

            for i = start_range + 1, end_range - 1, 1 do
                local virt_text = self.options.chars["vertical_line"]
                local line_num = i
                local offset = start_col - fn.winsaveview().leftcol

                if beg_row > i then
                    virt_text = self.options.chars["horizontal_line"]
                    offset, line_num = offset - (i - beg_row), beg_row
                elseif end_row < i then
                    virt_text = self.options.chars["horizontal_line"]
                    offset, line_num = offset + (i - end_row), end_row
                elseif beg_row == i then
                    virt_text = self.options.chars["left_top"]
                elseif end_row == i then
                    virt_text = self.options.chars["left_bottom"]
                end

                opts.virt_text[i - start_range] = virt_text
                opts.offset[i - start_range] = offset
                opts.line_num[i - start_range] = line_num
            end

            timer.start_draw(self.ns_id, opts, end_range - start_range)
        end
    else
        self:clear()
        ctx_manager.clear_context()
    end
end

function chunk_mod:enable_mod_autocmd()
    api.nvim_create_augroup(self.augroup_name, { clear = true })
    api.nvim_create_autocmd({ "TextChanged" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "BufLeave" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
          self:clear()
          timer.stop_draw()
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            chunk_mod:enable()
        end,
    })
end

function chunk_mod:extra()
    local textobject = self.options.textobject
    if #textobject == 0 then
        return
    end
    vim.keymap.set({ "x", "o" }, textobject, function()
        local cur_chunk_range = utils.get_chunk_range(nil, { use_treesitter = self.options.use_treesitter })
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
