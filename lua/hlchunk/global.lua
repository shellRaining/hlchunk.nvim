-- this file contains some global variables will be used when rendering

local tablex = require("hlchunk.lib.table")
local opts = require("hlchunk.options")

-- options global value

-- the tab that represents by using blank
-- TODO: need move to another autocmd, because this will cost to much CPU time
SPACE_TAB = (" "):rep(vim.o.shiftwidth)
INDENT_CHARS_NUM = tablex.size(opts.config.hl_indent.chars)
INDENT_STYLE_NUM = tablex.size(opts.config.hl_indent.style)
LINE_NUM_STYLE_NUM = tablex.size(opts.config.hl_line_num.style)

-- runtime value
-- the line number that cursor stay
CUR_LINE_NUM = -1

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }
