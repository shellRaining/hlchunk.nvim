local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local Array = require("hlchunk.utils.array")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn

---@class IndentMod: BaseMod
---@field cached_lines table<number, number>
local indent_mod = BaseMod:new({
    name = "indent",
    cached_lines = {},
    options = {
        enable = true,
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
    local render_char_num = math.floor(indent / vim.o.shiftwidth)
    local win_info = fn.winsaveview()
    local text = ""
    for _ = 1, render_char_num do
        text = text .. "|" .. (" "):rep(vim.o.shiftwidth - 1)
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

function indent_mod:render(scrolled)
    scrolled = scrolled or false

    if (not self.options.enable) or self.options.exclude_filetypes[vim.bo.filetype] or vim.o.shiftwidth == 0 then
        return
    end

    if not scrolled then
        -- nvim api is 0-base index, but most of vim.fn is 1-base index
        local wbegin = fn.line("w0") - 1
        local wend = fn.line("w$") - 1

        -- when window height is less than buffer height, clear all
        -- an example:
        -- a buffer is 10 lines, the window is 20 lines, whne format code, the buffer is 7 lines,
        -- if not clear all, the last 3 lines will not be cleared
        if wend - wbegin + 1 < fn.winheight(fn.winnr()) then
            self:clear()
        else
            self:clear(fn.line("w0") - 1, fn.line("w$") - 1)
        end
    end
    self.ns_id = api.nvim_create_namespace(self.name)

    local rows_indent = utils.get_rows_indent(nil, nil, {
        use_treesitter = self.options.use_treesitter,
        virt_indent = true,
    })
    if not rows_indent then
        return
    end

    for index, _ in pairs(rows_indent) do
        if not (scrolled and self.cached_lines[index] and self.cached_lines[index] > 0) then
            self:render_line(index, rows_indent[index])
            self.cached_lines[index] = rows_indent[index]
        end
    end
end

function indent_mod:enable_mod_autocmd()
    api.nvim_create_augroup(self.augroup_name, { clear = true })

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = indent_mod.old_win_info

            if cur_win_info.leftcol ~= old_win_info.leftcol then
                indent_mod:render(false)
            elseif cur_win_info.lnum ~= old_win_info.lnum then
                indent_mod:render(true)
            end

            indent_mod.old_win_info = cur_win_info
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            indent_mod.cached_lines = {}
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
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            indent_mod:enable()
        end,
    })
end

function indent_mod:disable()
    indent_mod.cached_lines = {}
    BaseMod.disable(self)
end

return indent_mod
