local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local tablex = require("hlchunk.utils.table")
local stringx = require("hlchunk.utils.string")
local api = vim.api
local fn = vim.fn

local Blank_chars_num = tablex.size(PLUG_CONF.blank.chars)
local Blank_style_num = tablex.size(PLUG_CONF.blank.style)

local blank_mod = BaseMod:new({
    name = "blank",
})

local ns_id = -1

function blank_mod:render()
    if (not PLUG_CONF.blank.enable) or PLUG_CONF.blank.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()
    ns_id = api.nvim_create_namespace("hl_blank_augroup")

    local rows_indent = utils.get_rows_indent(nil, nil, {
        use_treesitter = PLUG_CONF.blank.use_treesitter,
        virt_indent = false,
    })
    if not rows_indent then
        return
    end
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 1,
    }
    for index, _ in pairs(rows_indent) do
        local render_char_num = rows_indent[index] / vim.o.shiftwidth
        local win_info = fn.winsaveview()
        local text = ""
        for _ = 1, render_char_num do
            text = text .. "." .. (" "):rep(vim.o.shiftwidth - 1)
        end
        text = text:sub(win_info.leftcol + 1)

        local count = 0
        for i = 1, #text do
            local c = stringx.at(text, i)
            if not c:match("%s") then
                count = count + 1
                local char = PLUG_CONF.blank.chars[(i - 1) % Blank_chars_num + 1]:rep(vim.o.shiftwidth)
                local style = "HLBlankStyle" .. tostring((count - 1) % Blank_style_num + 1)
                row_opts.virt_text = { { char, style } }
                row_opts.virt_text_win_col = i - 1
                api.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
            end
        end
    end
end

function blank_mod:clear()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function blank_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_blank_augroup", { clear = true })

    api.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_blank_augroup",
        pattern = "*",
        callback = function()
            blank_mod:render()
        end,
    })
end

function blank_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_blank_augroup")
end

function blank_mod:create_mod_usercmd()
    api.nvim_create_user_command("EnableHLBlank", function()
        blank_mod:enable()
    end, {})
    api.nvim_create_user_command("DisableHLBlank", function()
        blank_mod:disable()
    end, {})
end

function blank_mod:enable()
    local ok, _ = pcall(function()
        PLUG_CONF.blank.enable = true
        self:render()
        self:enable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have enable this plugin")
    end
end

function blank_mod:disable()
    local ok, _ = pcall(function()
        PLUG_CONF.blank.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable this plugin")
    end
end

return blank_mod
