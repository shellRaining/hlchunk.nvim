-- this file contains some global variables will be used when rendering

-- global var that represents utils and built-in functions
API = vim.api
FN = vim.fn
PLUG_CONF = require("hlchunk.options").config
UTILS = require("hlchunk.utils.utils")

-- the tab that represents by using blank
SPACE_TAB = (" "):rep(vim.o.shiftwidth)

-- runtime value
-- the line number that cursor stay
CUR_LINE_NUM = -1

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }

-- this table contains the num of blank of each row in current window(from w0 to w$)
ROWS_BLANK_LIST = {}

-- this autocmd is defined first, so it will execute the first, don't worry about execute order
API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = "*",
    callback = function()
        if PLUG_CONF.chunk.enable or PLUG_CONF.line_num.enable then
            CUR_LINE_NUM = FN.line(".")
            CUR_CHUNK_RANGE = UTILS.get_pair_rows()
            ROWS_BLANK_LIST = UTILS.get_rows_blank()
        end
    end,
})
