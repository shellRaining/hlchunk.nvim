-- this file contains some global variables will be used when rendering

-- options

-- the tab that represents by using blank
-- TODO: need move to another autocmd, because this will cost to much CPU time
SPACE_TAB = (" "):rep(vim.o.shiftwidth)

-- runtime value
-- the line number that cursor stay
CUR_LINE_NUM = -1

-- the line num range of chunk that cursor stay
CUR_CHUNK_RANGE = { -1, -1 }
