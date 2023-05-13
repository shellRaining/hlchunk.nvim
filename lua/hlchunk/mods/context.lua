local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

local context_mod = require("hlchunk.base_mod"):new({
    name = "context",
    options = {
        enable = false,
        use_treesitter = false,
        chars = {
            "┃", -- Box Drawings Heavy Vertical
        },
        style = {
            "#806d9c",
        },
        exclude_filetype = ft.exclude_filetype,
    },
})

function context_mod:render()
    if (not self.options.enable) or self.options.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()
    self.ns_id = api.nvim_create_namespace("hl_context")

    local indent_range = utils.get_indent_range()
    if not indent_range then
        return
    end
    local beg_row, end_row = unpack(indent_range)

    local start_col = math.max(math.min(fn.indent(beg_row), fn.indent(end_row)) - vim.o.shiftwidth, 0)
    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
        hl_mode = "combine",
        priority = 99,
    }

    -- render middle section
    local offset = fn.winsaveview().leftcol
    for i = beg_row, end_row do
        -- TODO: dont use HLContextStyle1, but use varible defined in base_mod
        row_opts.virt_text = { { self.options.chars[1], "HLContext1" } }
        row_opts.virt_text_win_col = start_col - offset
        local space_tab = (" "):rep(vim.o.shiftwidth)
        local line_val = fn.getline(i):gsub("\t", space_tab)
        if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
            if utils.col_in_screen(start_col) then
                api.nvim_buf_set_extmark(0, self.ns_id, i - 1, 0, row_opts)
            end
        end
    end
end

function context_mod:enable_mod_autocmd()
    api.nvim_create_augroup(self.augroup_name, { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_context_augroup",
        pattern = "*",
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = context_mod.old_win_info

            if cur_win_info.lnum ~= old_win_info.lnum or cur_win_info.leftcol ~= old_win_info.leftcol then
                context_mod.old_win_info = cur_win_info
                context_mod:render()
            end
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = "hl_context_augroup",
        pattern = "*",
        callback = function()
            context_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = "hl_context_augroup",
        pattern = "*",
        callback = function()
            context_mod:enable()
        end,
    })
end

return context_mod
