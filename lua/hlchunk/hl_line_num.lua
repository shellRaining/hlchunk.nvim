local opts = require("hlchunk.options")
local fn = vim.fn
local api = vim.api

local M = {}

function M.hl_line_num()
    M.clear_line_num()

    local beg_row, end_row = unpack(CUR_CHUNK_RANGE)
    if beg_row < end_row then
        for i = beg_row, end_row do
            ---@diagnostic disable-next-line: param-type-mismatch
            fn.sign_place("", "LineNumberGroup", "LineNumberInterval", fn.bufname("%"), {
                lnum = i,
            })
        end
    end
end

function M.clear_line_num()
    fn.sign_unplace("LineNumberGroup", {
        ---@diagnostic disable-next-line: param-type-mismatch
        buffer = fn.bufname("%"),
    })
end

return M
