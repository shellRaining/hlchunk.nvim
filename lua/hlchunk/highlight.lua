local opts = require("hlchunk.options")

local chunk_hl_group = opts.config.hl_chunk.style
local indent_hl_group = opts.config.hl_indent.style
local line_num_hl_group = opts.config.hl_chunk.hl_line_num_style

local M = {}

local function set_hl(hl_base_name, style_table)
    local count = 1

    return function()
        for _, value in pairs(style_table) do
            local hl_name = hl_base_name .. tostring(count)
            vim.api.nvim_set_hl(0, hl_name, {
                fg = value,
            })
            count = count + 1
        end
    end
end

function M.set_hls()
    set_hl("HLChunkStyle", chunk_hl_group)()
    set_hl("HLIndentStyle", indent_hl_group)()
    set_hl("HLIndentStyle", line_num_hl_group)()

    -- TODO: this need to refactor
    vim.fn.sign_define("LineNumberInterval", {
        numhl = "HLChunkStyle1",
    })
end

return M
