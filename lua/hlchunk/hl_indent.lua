local utils = require("hlchunk.utils")

local M = {}

local ns_id = -1

local function render_indent()
    vim.notify("need implement")
end

function M.hl_indent()
    local rows_blank_list = utils.get_rows_blank()
    render_indent(utils.get_render_indent_params(rows_blank_list))
end

function M.clear_hl_indent()
    if ns_id ~= -1 then
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function M.enable_hl_indent()
    vim.notify("need implement")
end

function M.disable_hl_indent()
    vim.notify("need implement")
end

return M
