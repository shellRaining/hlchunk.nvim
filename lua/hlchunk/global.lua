-- this file contains some global variables will be used when rendering

local tablex = require("hlchunk.lib.table")

-- options global value

-- the tab that represents by using blank
API = vim.api
FN = vim.fn
PLUG_CONF = require("hlchunk.options").config
SPACE_TAB = (" "):rep(vim.o.shiftwidth)
INDENT_CHARS_NUM = tablex.size(PLUG_CONF.hl_indent.chars)
INDENT_STYLE_NUM = tablex.size(PLUG_CONF.hl_indent.style)
LINE_NUM_STYLE_NUM = tablex.size(PLUG_CONF.hl_line_num.style)
REGISTED_MODS = {
    "hl_chunk",
    "hl_indent",
    "hl_line_num",
}

-- runtime value
-- the line number that cursor stay
CUR_LINE_NUM = -1

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }
