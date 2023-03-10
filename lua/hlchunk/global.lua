-- this file contains some global variables will be used when rendering

-- global var that represents utils and built-in functions
API = vim.api
FN = vim.fn
PLUG_CONF = require("hlchunk.options").config
UTILS = require("hlchunk.utils.utils")
TABLEX = require("hlchunk.utils.table")
STRINGX = require("hlchunk.utils.string")

-- the tab that represents by using blank
SPACE_TAB = (" "):rep(vim.o.shiftwidth)

-- runtime value
-- the line number that cursor stay
WIN_INFO = vim.fn.winsaveview()

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }

-- this table contains the num of blank of each row in current window(from w0 to w$)
ROWS_BLANK_LIST = {}

-- this autocmd is defined first, so it will execute the first, don't worry about execute order
API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = PLUG_CONF.chunk.support_filetypes,
    callback = function()
        if PLUG_CONF.chunk.enable or PLUG_CONF.line_num.enable then
            CUR_CHUNK_RANGE = UTILS.get_pair_rows()
        end
    end,
})

API.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
    pattern = "*",
    callback = function()
        WIN_INFO = vim.fn.winsaveview()
        ROWS_BLANK_LIST = UTILS.get_rows_blank()
    end,
})
