local BaseMod = require("hlchunk.base_mod")
local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

local chunk_mod = BaseMod:new({
    name = "chunk",
    options = {
        enable = true,
        use_treesitter = true,
        support_filetypes = ft.support_filetype,
        exclude_filetype = ft.exclude_filetype,
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
    },
})

local draw = function(self)
    local cur_chunk_range = utils.get_chunk_range(nil, { use_treesitter = self.options.use_treesitter })
    if cur_chunk_range and cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local beg_blank_len = fn.indent(beg_row)
        local end_blank_len = fn.indent(end_row)
        local start_col = math.max(math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth, 0)

        if self.beg_row == beg_row and self.end_row == end_row then
            return
        else
            self.beg_row = beg_row
            self.end_row = end_row
        end

        self:clear()

        local row_opts = {
            virt_text_pos = "overlay",
            hl_mode = "combine",
            priority = 100,
        }


        for i = beg_row - beg_blank_len + start_col + 1, end_row + end_blank_len - start_col - 1, 1 do
            local virt_text = self.options.chars["vertical_line"]
            local line_num = i
            local offset = start_col - fn.winsaveview().leftcol

            if beg_row >= i then
                self:clear()
                local left_top = self.options.chars["left_top"]:rep(i - beg_row + 1)
                virt_text = left_top .. self.options.chars["horizontal_line"]:rep(i - (beg_row - beg_blank_len + start_col) - string.len(left_top)/3)
                offset = offset - (i - (beg_row - beg_blank_len + start_col)) + beg_blank_len - start_col
                line_num = beg_row
            elseif end_row <= i then
                line_num = end_row
                virt_text = self.options.chars["left_bottom"] .. self.options.chars["horizontal_line"]:rep(i - end_row)
            end

            row_opts.virt_text = { { virt_text, "HLChunk1" } }
            row_opts.virt_text_win_col = offset

            api.nvim_buf_set_extmark(0, self.ns_id, line_num - 1, 0, row_opts)
            utils.pause(12)
        end
    end
end

-- set new virtual text to the right place
function chunk_mod:render()
    if not self.options.enable or self.options.exclude_filetype[vim.bo.ft] then
        return
    end

    self.ns_id = api.nvim_create_namespace("hlchunk")
    -- create a coroutine
    coroutine.wrap(draw)(self)
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

return chunk_mod
