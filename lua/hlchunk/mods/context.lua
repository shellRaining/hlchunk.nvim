local BaseMod = require("hlchunk.base_mod")
local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

---@class ContextOpts: BaseModOpts
---@field use_treesitter boolean
---@field chars table<string, string>

---@class ContextMod: BaseMod
---@field options ContextOpts
local context_mod = BaseMod:new({
    name = "context",
    options = {
        enable = false,
        notify = true,
        use_treesitter = false,
        chars = {
            "┃", -- Box Drawings Heavy Vertical
        },
        style = {
            "#806d9c",
        },
        exclude_filetypes = ft.exclude_filetypes,
    },
})

function context_mod:render()
    if (not self.options.enable) or self.options.exclude_filetypes[vim.bo.filetype] then
        return
    end

    self:clear()
    self.ns_id = api.nvim_create_namespace(self.name)

    local indent_range = utils.get_indent_range(self)
    if not indent_range then
        return
    end
    local beg_row, end_row = unpack(indent_range)

    local shiftwidth = fn.shiftwidth()
    local start_col = math.max(math.min(fn.indent(beg_row), fn.indent(end_row)) - shiftwidth, 0)
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
        local space_tab = (" "):rep(shiftwidth)
        local line_val = fn.getline(i):gsub("\t", space_tab)
        if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
            if utils.col_in_screen(start_col) then
                api.nvim_buf_set_extmark(0, self.ns_id, i - 1, 0, row_opts)
            end
        end
    end
end

function context_mod:enable_mod_autocmd()
    BaseMod.enable_mod_autocmd(self)

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = self.augroup_name,
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
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            context_mod:render()
        end,
    })
end

return context_mod
