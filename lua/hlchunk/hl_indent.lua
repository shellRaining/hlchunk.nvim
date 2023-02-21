local utils = require("hlchunk.utils")
local opts = require("hlchunk.options")
local api = vim.api

local M = {}

local ns_id = -1

local function get_indent_virt_text(line)
    local blank_width = vim.o.shiftwidth
    local char_num = math.ceil(line / blank_width)
    local blank = (" "):rep(blank_width - 1)
    local virt_char = opts.config.hl_chars.vertical_line
    local res = ""

    for _ = 1, char_num do
        res = res .. virt_char .. blank
    end

    return res
end

local function render_indent(rows_blank_list)
    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = 0,
        hl_mode = "combine",
    }

    -- NOTE: you can't replace pairs to ipairs, beacuse the index is not 1 in table
    for index, value in pairs(rows_blank_list) do
        local indent_virt_text = get_indent_virt_text(value)
        row_opts.virt_text = { { indent_virt_text, "HLChunkStyle" } }
        vim.api.nvim_buf_set_extmark(0, ns_id, index - 1, 0, row_opts)
    end
end

function M.hl_indent()
    M.clear_hl_indent()
    ns_id = api.nvim_create_namespace("hl_indent")

    local rows_blank_list = utils.get_rows_blank()
    render_indent(rows_blank_list)
end

function M.clear_hl_indent()
    if ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.enable_hl_indent()
    M.hl_indent()
end

function M.disable_hl_indent()
    M.clear_hl_indent()
end

return M
