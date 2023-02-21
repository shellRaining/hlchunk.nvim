local opts = require("hlchunk.options")

vim.api.nvim_set_hl(0, "HLChunkStyle", {
    fg = opts.config.hlchunk_hl_style,
})
