-- this file contains some global variables will be used when rendering

-- global var that represents utils and built-in functions
API = vim.api
FN = vim.fn
PLUG_CONF = require("hlchunk.options").config
UTILS = require("hlchunk.utils.utils")
TABLEX = require("hlchunk.utils.table")
STRINGX = require("hlchunk.utils.string")

----------------------------------------------------------------------------------------------------
-- static global variables
SPACE_TAB = (" "):rep(vim.o.shiftwidth)

----------------------------------------------------------------------------------------------------
-- dynamic global variables
WIN_INFO = FN.winsaveview() -- the line number that cursor stay
ROWS_BLANK_LIST = {} -- this table contains the num of blank of each row in current window(from w0 to w$)
API.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
    pattern = "*",
    callback = function()
        if PLUG_CONF.indent.enable or PLUG_CONF.blank.enable then
            WIN_INFO = FN.winsaveview()
        end
    end,
})

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }
CUR_INDENT_RANGE = { -1, -1 }
API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = PLUG_CONF.chunk.support_filetypes,
    callback = function()
        if PLUG_CONF.chunk.enable or PLUG_CONF.line_num.enable or PLUG_CONF.context.enable then
            CUR_CHUNK_RANGE = UTILS.get_chunk_range()
        end
    end,
})
