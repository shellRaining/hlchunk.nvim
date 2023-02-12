local utils = require("hlchunk.utils")
local hl_chars = require("hlchunk.options").config.hl_chars

local M = {}

local ns_id = -1

-- set new virtual text to the right place
function M.hl_chunk()
    M.clear_hl_chunk()
    ns_id = vim.api.nvim_create_namespace("hlchunk")

    -- determined the row where parentheses are
    local beg_row, end_row
    local pair_pos = utils.get_pair_rows()
    beg_row = pair_pos[1]
    end_row = pair_pos[2]
    if beg_row == end_row then
        return
    end

    -- determined the start_col to draw virt_text
    -- QUES: if \t can be ignored
    local shift_width = vim.o.shiftwidth
    local space_tab = (" "):rep(shift_width)
    local beg_blank_val = tostring(vim.fn.getline(beg_row)):match("%s*"):gsub("\t", space_tab)
    local end_blank_val = tostring(vim.fn.getline(end_row)):match("%s*"):gsub("\t", space_tab)
    local beg_blank_len = #beg_blank_val
    local end_blank_len = #end_blank_val
    local start_col = math.min(beg_blank_len, end_blank_len) - shift_width

    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
    }
    -- render beg_row and end_row
    if start_col >= 0 then
        local beg_virt_text = hl_chars.left_top .. hl_chars.horizontal_line:rep(beg_blank_len - start_col - 1)
        local end_virt_text = hl_chars.left_bottom
            .. hl_chars.horizontal_line:rep(end_blank_len - start_col - 2)
            .. hl_chars.right_arrow

        row_opts.virt_text = { { beg_virt_text, "HLChunkStyle" } }
        vim.api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, row_opts)
        row_opts.virt_text = { { end_virt_text, "HLChunkStyle" } }
        vim.api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, row_opts)
    end

    -- render middle section
    for i = beg_row + 1, end_row - 1 do
        local mid_virt_text = hl_chars.vertical_line
        row_opts.virt_text = { { mid_virt_text, "HLChunkStyle" } }
        row_opts.virt_text_win_col = math.max(0, start_col)
        vim.api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
    end
end

-- clear the virtual text marked before
function M.clear_hl_chunk()
    if ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

return M
