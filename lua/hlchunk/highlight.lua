local opts = require("hlchunk.options")

local chunk_hl_group = opts.config.hl_chunk.style
local indent_hl_group = opts.config.hl_indent.style
local line_num_hl_group = opts.config.hl_line_num.style

local M = {}

local function set_hl(hl_base_name, args)
    local count = 1

    return function()
        if type(args) == "string" then
            vim.api.nvim_set_hl(0, hl_base_name .. "1", {
                fg = args,
            })
        elseif type(args) == "table" then
            for _, value in pairs(args) do
                local hl_name = hl_base_name .. tostring(count)
                vim.api.nvim_set_hl(0, hl_name, {
                    fg = value,
                })
                count = count + 1
            end
        end
    end
end

local function set_signs()
    if type(opts.config.hl_line_num.style) == "table" then
        local tbl = {}
        for i = 1, LINE_NUM_STYLE_NUM do
            local sign_name = "sign" .. tostring(i)
            local hl_name = "HLLineNumStyle" .. tostring(i)
            tbl[#tbl + 1] = { name = sign_name, numhl = hl_name }
        end
        vim.fn.sign_define(tbl)
    else
        vim.fn.sign_define("sign1", {
            numhl = "HLLineNumStyle1",
        })
    end
end

function M.set_hls()
    set_hl("HLChunkStyle", chunk_hl_group)()
    set_hl("HLIndentStyle", indent_hl_group)()
    set_hl("HLLineNumStyle", line_num_hl_group)()

    set_signs()
end

return M
