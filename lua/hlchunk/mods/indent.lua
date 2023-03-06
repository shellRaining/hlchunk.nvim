local BaseMod = require("hlchunk.base_mod")

local indent_mod = BaseMod:new({
    name = "indent",
})

local ns_id = -1
local rows_blank_list = {}

local function get_indent_virt_text_num(line)
    -- if the given line is blank, we need set the virt_text by context
    if rows_blank_list[line] == -1 then
        local line_below = line + 1
        while rows_blank_list[line_below] do
            if rows_blank_list[line_below] == 0 then
                break
            elseif rows_blank_list[line_below] > 0 then
                rows_blank_list[line] = rows_blank_list[line_below]
                break
            end
            line_below = line_below + 1
        end
    end

    return math.floor(rows_blank_list[line] / vim.o.shiftwidth)
end

local function render_line(index)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 1,
    }

    local render_char_num = get_indent_virt_text_num(index)
    for i = 1, render_char_num do
        local style = "HLIndentStyle" .. tostring((i - 1) % INDENT_STYLE_NUM + 1)
        local char = PLUG_CONF.indent.chars[(i - 1) % INDENT_CHARS_NUM + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = (i - 1) * vim.o.shiftwidth
        API.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
    end
end

function indent_mod:render()
    if (not PLUG_CONF.indent.enable) or PLUG_CONF.indent.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()
    ns_id = API.nvim_create_namespace("hl_indent")

    rows_blank_list = UTILS.get_rows_blank()
    for index, _ in pairs(rows_blank_list) do
        render_line(index)
    end
end

function indent_mod:clear()
    if ns_id ~= -1 then
        API.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function indent_mod:enable_mod_autocmd()
    API.nvim_create_augroup("hl_indent_augroup", { clear = true })

    API.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_indent_augroup",
        pattern = "*",
        callback = function()
            indent_mod:render()
        end,
    })
end

function indent_mod:disable_mod_autocmd()
    API.nvim_del_augroup_by_name("hl_indent_augroup")
end

function indent_mod:create_mod_usercmd()
    API.nvim_create_user_command("EnableHLIndent", function()
        indent_mod:enable()
    end, {})
    API.nvim_create_user_command("DisableHLIndent", function()
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
