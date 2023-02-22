local opts = require("hlchunk.options")

vim.api.nvim_set_hl(0, "HLChunkStyle", {
    fg = opts.config.hlchunk_style.chunk_style.hibiscus,
})

vim.api.nvim_set_hl(0, "HLIndentStyle", {
    fg = opts.config.hlchunk_style.indent_style.primrose,
})
