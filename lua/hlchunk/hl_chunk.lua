local opts = require("hlchunk.options")
local api = vim.api
local fn = vim.fn

local M = {}

local ns_id = -1

local function render_cur_chunk()
    local beg_row, end_row = unpack(CUR_CHUNK_RANGE)
    local beg_blank_len = fn.indent(beg_row)
    local end_blank_len = fn.indent(end_row)
    local start_col = math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth

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
        start_col = math.max(0, start_col)
        row_opts.virt_text = { { opts.config.hl_chunk.chars.vertical_line, "HLChunkStyle1" } }
        row_opts.virt_text_win_col = start_col
        local line_val = fn.getline(i):gsub('\t', SPACE_TAB)
        ---@diagnostic disable-next-line: undefined-field
        if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
            api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
        end
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
    if CUR_CHUNK_RANGE[1] < CUR_CHUNK_RANGE[2] then
        render_cur_chunk()
    end
end

-- clear the virtual text marked before
function M.clear_hl_chunk()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.disable_hl_cur_chunk()
    opts.config.hl_chunk.enable = false
    M.clear_hl_chunk()
    require("hlchunk.autocmd").disable_hl_chunk_autocmds()
end

function M.enable_hl_cur_chunk()
    opts.config.hl_chunk.enable = true
    M.hl_cur_chunk()
    require("hlchunk.autocmd").enable_hl_chunk_autocmds()
end

return M
