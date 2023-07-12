local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local Array = require("hlchunk.utils.array")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

---@class IndentOpts: BaseModOpts
---@field use_treesitter boolean
---@field chars table<string, string>

---@class IndentMod: BaseMod
---@field options IndentOpts
local indent_mod = BaseMod:new({
    name = "indent",
    options = {
        enable = true,
        notify = true,
        use_treesitter = false,
        chars = {
            "│",
        },
        style = {
            api.nvim_get_hl(0, { name = "Whitespace" }),
        },
        exclude_filetypes = ft.exclude_filetypes,
    },
})

function indent_mod:render_line(index, indent)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 2,
    }
    local shiftwidth = fn.shiftwidth()
    local render_char_num = math.floor(indent / shiftwidth)
    local win_info = fn.winsaveview()
    local text = ""
    for _ = 1, render_char_num do
        text = text .. "|" .. (" "):rep(shiftwidth - 1)
    end
    text = text:sub(win_info.leftcol + 1)

    local count = 0
    for i = 1, #text do
        local c = text:at(i)
        if not c:match("%s") then
            count = count + 1
            local Indent_chars_num = Array:from(self.options.chars):size()
            local Indent_style_num = Array:from(self.options.style):size()
            local char = self.options.chars[(count - 1) % Indent_chars_num + 1]
            local style = "HLIndent" .. tostring((count - 1) % Indent_style_num + 1)
            row_opts.virt_text = { { char, style } }
            row_opts.virt_text_win_col = i - 1
            api.nvim_buf_set_extmark(0, self.ns_id, index - 1, 0, row_opts)
        end
    end
end

function indent_mod:render()
    if (not self.options.enable) or self.options.exclude_filetypes[vim.bo.filetype] or fn.shiftwidth() == 0 then
        return
    end

    self:clear()
    self.ns_id = api.nvim_create_namespace(self.name)

    local rows_indent = utils.get_rows_indent(self, nil, nil, {
        use_treesitter = self.options.use_treesitter,
        virt_indent = true,
    })
    if not rows_indent then
        return
    end

    for index, _ in pairs(rows_indent) do
        self:render_line(index, rows_indent[index])
    end
end

function indent_mod:enable_mod_autocmd()
    BaseMod.enable_mod_autocmd(self)

    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "WinScrolled" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            indent_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.augroup_name,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = function()
            indent_mod:render()
        end,
    })
end

function indent_mod:disable()
    BaseMod.disable(self)
end

return indent_mod
