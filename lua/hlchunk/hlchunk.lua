local utils = require("hlchunk.utils")
local opts = require("hlchunk.options")

local M = {}

local ns_id = -1

local function render_cur_chunk(render_params)
    local beg_row, end_row, start_col, beg_blank_len, end_blank_len = unpack(render_params)

    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
        hl_mode = "combine",
    }
    -- render beg_row and end_row
    if start_col >= 0 then
        local beg_virt_text = opts.config.hl_chars.left_top
            .. opts.config.hl_chars.horizontal_line:rep(beg_blank_len - start_col - 1)
        local end_virt_text = opts.config.hl_chars.left_bottom
            .. opts.config.hl_chars.horizontal_line:rep(end_blank_len - start_col - 2)
            .. opts.config.hl_chars.right_arrow

        row_opts.virt_text = { { beg_virt_text, "HLChunkStyle" } }
        vim.api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, row_opts)
        row_opts.virt_text = { { end_virt_text, "HLChunkStyle" } }
        vim.api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, row_opts)
    end

    -- render middle section
    for i = beg_row + 1, end_row - 1 do
        row_opts.virt_text = { { opts.config.hl_chars.vertical_line, "HLChunkStyle" } }
        row_opts.virt_text_win_col = math.max(0, start_col)
        vim.api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
    end
end

-- set new virtual text to the right place
function M.hl_cur_chunk()
    if not opts.config.enabled then
        return
    end

    M.clear_hl_chunk()
    ns_id = vim.api.nvim_create_namespace("hlchunk")

    -- determined the row where parentheses are
    local beg_row, end_row = unpack(utils.get_pair_rows())
    if beg_row == end_row then
        return
    end

    render_cur_chunk(utils.get_render_params(beg_row, end_row))
end

-- clear the virtual text marked before
function M.clear_hl_chunk()
    if ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.disable_hlchunk(args)
    opts.config.enabled = false
    M.clear_hl_chunk()
    require("hlchunk.autocmd").disable_hlchunk_autocmds()
end

function M.enable_hlchunk(args)
    opts.config.enabled = true
    M.hl_cur_chunk()
    require("hlchunk.autocmd").enable_hlchunk_autocmds()
end

return M
