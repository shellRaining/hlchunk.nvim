local fg_color = require("hlchunk.options").config.hlchunk_hl_style

vim.api.nvim_set_hl(0, "HLChunkStyle", { fg = fg_color})
