local opts = require("hlchunk.options")

local indent_hl_group = opts.config.hl_indent.style

vim.api.nvim_set_hl(0, "HLChunkStyle", {
    fg = opts.config.hl_chunk.style.hibiscus,
})

-- set highlighting group for indent
local base_hl_name = "HLIndentStyle"
for index, value in pairs(indent_hl_group) do
    local hl_name = base_hl_name .. tostring(index)
    vim.api.nvim_set_hl(0, hl_name, {
        fg = value,
    })
    index = index + 1
end
