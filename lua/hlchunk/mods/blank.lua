local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local Array = require("hlchunk.utils.array")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

---@class BlankOpts: BaseModOpts
---@field use_treesitter boolean
---@field chars table<string, string>

---@class BlankMod: BaseMod
---@field options BlankOpts
local blank_mod = BaseMod:new({
    name = "blank",
    options = {
        enable = true,
        notify = true,
        chars = {
            "․",
        },
        style = {
            api.nvim_get_hl(0, { name = "Whitespace" }),
        },
        exclude_filetypes = ft.exclude_filetypes,
    },
})

function blank_mod:render_line(index, indent)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 1,
    }
    local shiftwidth = fn.shiftwidth()
    local render_char_num = math.floor(indent / shiftwidth)
    local win_info = fn.winsaveview()
    local text = ""
    for _ = 1, render_char_num do
        text = text .. "." .. (" "):rep(shiftwidth - 1)
    end
    text = text:sub(win_info.leftcol + 1)

    local count = 0
    for i = 1, #text do
        local c = text:at(i)
        if not c:match("%s") then
            count = count + 1
            local Blank_chars_num = Array:from(self.options.chars):size()
            local Blank_style_num = Array:from(self.options.style):size()
            local char = self.options.chars[(count - 1) % Blank_chars_num + 1]:rep(shiftwidth)
            local style = "HLBlank" .. tostring((count - 1) % Blank_style_num + 1)
            row_opts.virt_text = { { char, style } }
            row_opts.virt_text_win_col = i - 1
            api.nvim_buf_set_extmark(0, self.ns_id, index - 1, 0, row_opts)
        end
    end
end

function blank_mod:render()
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

function blank_mod:enable_mod_autocmd()
    BaseMod.enable_mod_autocmd(self)

    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "WinScrolled" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            blank_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = self.augroup_name,
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = function()
            blank_mod:render()
        end,
    })
end

function blank_mod:disable()
    BaseMod.disable(self)
end

return blank_mod
