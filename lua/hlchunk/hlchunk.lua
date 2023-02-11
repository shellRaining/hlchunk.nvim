local utils = require("hlchunk.utils")

local M = {}

local ns_id = -1

-- set new virtual text to the right place
function M.hl_chunk()
    M.clear_hl_chunk()
    ns_id = vim.api.nvim_create_namespace("hlchunk")

    local pair_pos = utils.get_pair_rows()
    local beg_row = pair_pos[1]
    local end_row = pair_pos[2]
    if beg_row == end_row then
        return
    end

    local beg_row_opts = {
        virt_text = {
            { "beg_row", "HLChunkStyle" },
        },
    }
    local end_row_opts = {
        virt_text = {
            { "end_row", "HLChunkStyle" },
        },
    }

    vim.api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, beg_row_opts)
    vim.api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, end_row_opts)
end

-- clear the virtual text marked before
function M.clear_hl_chunk()
    if ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

return M
