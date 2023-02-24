local utils = require("hlchunk.utils")
local opts = require("hlchunk.options")
local api = vim.api

local M = {}

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
        local indent_style_kinds = #opts.config.hl_indent.style
        local style = "HLIndentStyle" .. tostring((i - 1) % indent_style_kinds + 1)
        row_opts.virt_text = { { opts.config.hl_indent.chars.vertical_line, style } }
        row_opts.virt_text_win_col = (i - 1) * vim.o.shiftwidth
        api.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
    end
end

function M.hl_indent()
    if opts.config.hl_indent.exclude_filetype[vim.bo.filetype] then
        return
    end

    M.clear_hl_indent()
    ns_id = api.nvim_create_namespace("hl_indent")

    rows_blank_list = utils.get_rows_blank()
    -- NOTE: you can't replace pairs to ipairs, beacuse the index is not begin with 1 in table
    for index, _ in pairs(rows_blank_list) do
        indent_render_line(index)
    end
end

function M.clear_hl_indent()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.enable_hl_indent()
    opts.config.hl_indent.enable = true
    M.hl_indent()
    require("hlchunk.autocmd").enable_hl_indent_autocmds()
end

function M.disable_hl_indent()
    opts.config.hl_indent.enable = false
    M.clear_hl_indent()
    require("hlchunk.autocmd").disable_hl_indent_autocmds()
end

return M
