---@diagnostic disable: unused-local
local utils = require("hlchunk.utils")
local opts = require("hlchunk.options")
local fn = vim.fn
local api = vim.api

local M = {}

local ns_id = -1

local function render_cur_chunk(render_params)
    local beg_row, end_row, start_col, beg_blank_len, end_blank_len = unpack(render_params)

    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
        hl_mode = "combine",
        priority = 100,
    }
    -- render beg_row and end_row
    if start_col >= 0 then
        local beg_virt_text = opts.config.hl_chunk.chars.left_top
            .. opts.config.hl_chunk.chars.horizontal_line:rep(beg_blank_len - start_col - 1)
        local end_virt_text = opts.config.hl_chunk.chars.left_bottom
            .. opts.config.hl_chunk.chars.horizontal_line:rep(end_blank_len - start_col - 2)
            .. opts.config.hl_chunk.chars.right_arrow

        row_opts.virt_text = { { beg_virt_text, "HLChunkStyle1" } }
        api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, row_opts)
        row_opts.virt_text = { { end_virt_text, "HLChunkStyle1" } }
        api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, row_opts)
    end

    -- render middle section
    for i = beg_row + 1, end_row - 1 do
        row_opts.virt_text = { { opts.config.hl_chunk.chars.vertical_line, "HLChunkStyle1" } }
        row_opts.virt_text_win_col = math.max(0, start_col)
        api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
    end
end

-- set new virtual text to the right place
function M.hl_cur_chunk()
    if not opts.config.hl_chunk.enable then
        return
    end

    M.clear_hl_chunk()
    ns_id = api.nvim_create_namespace("hlchunk")

    -- determined the row where parentheses are
    local beg_row, end_row = unpack(utils.get_pair_rows())
    if beg_row < end_row then
        render_cur_chunk(utils.get_render_chunk_params(beg_row, end_row))
    end
    require("hlchunk.hl_line_num").hl_line_num(beg_row, end_row)
end

-- clear the virtual text marked before
function M.clear_hl_chunk()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.disable_hl_cur_chunk(args)
    opts.config.hl_chunk.enable = false
    M.clear_hl_chunk()
    require("hlchunk.autocmd").disable_hl_chunk_autocmds()
end

function M.enable_hl_cur_chunk(args)
    opts.config.hl_chunk.enable = true
    M.hl_cur_chunk()
    require("hlchunk.autocmd").enable_hl_chunk_autocmds()
end

return M
