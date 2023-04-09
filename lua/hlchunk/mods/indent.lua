local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local tablex = require("hlchunk.utils.table")
local stringx = require("hlchunk.utils.string")
local api = vim.api
local fn = vim.fn

local Indent_chars_num = tablex.size(PLUG_CONF.indent.chars)
local Indent_style_num = tablex.size(PLUG_CONF.indent.style)

local indent_mod = BaseMod:new({
    name = "indent",
})

local ns_id = -1

function indent_mod:render()
    if (not PLUG_CONF.indent.enable) or PLUG_CONF.indent.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()
    ns_id = api.nvim_create_namespace("hl_indent")

    local rows_indent = utils.get_rows_indent(nil, nil, {
        use_treesitter = PLUG_CONF.indent.use_treesitter,
        virt_indent = true,
    })
    if not rows_indent then
        return
    end

    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 2,
    }
    for index, _ in pairs(rows_indent) do
        local render_char_num = math.floor(rows_indent[index] / vim.o.shiftwidth)
        local win_info = fn.winsaveview()
        local text = ""
        for _ = 1, render_char_num do
            text = text .. "|" .. (" "):rep(vim.o.shiftwidth - 1)
        end
        text = text:sub(win_info.leftcol + 1)

        -- WARNING: please note the indentline you used maybe Unicode char, so dont use stirngx.at directly
        -- it may case get wronged char
        local count = 0
        for i = 1, #text do
            local c = stringx.at(text, i)
            if not c:match("%s") then
                count = count + 1
                local char = PLUG_CONF.indent.chars[(i - 1) % Indent_chars_num + 1]
                local style = "HLIndentStyle" .. tostring((count - 1) % Indent_style_num + 1)
                row_opts.virt_text = { { char, style } }
                row_opts.virt_text_win_col = i - 1
                api.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
            end
        end
    end
end

function indent_mod:clear()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function indent_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_indent_augroup", { clear = true })

    api.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_indent_augroup",
        pattern = "*",
        callback = function()
            indent_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "OptionSet" }, {
        group = "hl_indent_augroup",
        pattern = "list,listchars,shiftwidth,tabstop,expandtab",
        callback = function()
            indent_mod:render()
        end,
    })
end

function indent_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_indent_augroup")
end

function indent_mod:create_mod_usercmd()
    api.nvim_create_user_command("EnableHLIndent", function()
        indent_mod:enable()
    end, {})
    api.nvim_create_user_command("DisableHLIndent", function()
        indent_mod:disable()
    end, {})
end

function indent_mod:enable()
    local ok, _ = pcall(function()
        PLUG_CONF.indent.enable = true
        self:render()
        self:enable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have enable this plugin")
    end
end

function indent_mod:disable()
    local ok, _ = pcall(function()
        PLUG_CONF.indent.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable this plugin")
    end
end

return indent_mod
