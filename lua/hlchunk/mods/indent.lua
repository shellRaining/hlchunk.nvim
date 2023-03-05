local BaseMod = require("hlchunk.base_mod")
local hl_indent_augroup_handler = -1

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

local function indent_render_line(index)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = 1,
    }

    local render_char_num = get_indent_virt_text_num(index)
    for i = 1, render_char_num do
        local style = "HLIndentStyle" .. tostring((i - 1) % INDENT_STYLE_NUM + 1)
        local char = PLUG_CONF.hl_indent.chars[(i - 1) % INDENT_CHARS_NUM + 1]
        row_opts.virt_text = { { char, style } }
        row_opts.virt_text_win_col = (i - 1) * vim.o.shiftwidth
        API.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
    end
end

function indent_mod:render()
    if (not PLUG_CONF.hl_indent.enable) or PLUG_CONF.hl_indent.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()
    ns_id = API.nvim_create_namespace("hl_indent")

    rows_blank_list = UTILS.get_rows_blank()
    for index, _ in pairs(rows_blank_list) do
        indent_render_line(index)
    end
end

function indent_mod:clear()
    if ns_id ~= -1 then
        API.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function indent_mod:enable_mod_autocmd()
    if hl_indent_augroup_handler ~= -1 then
        return
    end

    hl_indent_augroup_handler = API.nvim_create_augroup("hl_indent_augroup", { clear = true })

    API.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_indent_augroup",
        pattern = "*",
        callback = function()
            indent_mod:render()
        end,
    })
end

function indent_mod:disable_mod_autocmd()
    if hl_indent_augroup_handler == -1 then
        return
    end

    API.nvim_del_augroup_by_name("hl_indent_augroup")
    hl_indent_augroup_handler = -1
end

function indent_mod:enable()
    PLUG_CONF.hl_indent.enable = true
    self:render()
    self:enable_mod_autocmd()
end

function indent_mod:disable()
    PLUG_CONF.hl_indent.enable = false
    self:clear()
    self:disable_mod_autocmd()
end

return indent_mod
