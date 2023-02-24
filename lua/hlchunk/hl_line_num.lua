local opts = require("hlchunk.options")
local fn = vim.fn

local M = {}

function M.hl_line_num()
    if not opts.config.hl_line_num.enable then
        return
    end

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

function M.disable_hl_line()
    opts.config.hl_line_num.enable = false
    M.clear_line_num()
    require("hlchunk.autocmd").disable_hl_line_autocmds()
end

function M.enable_hl_line()
    opts.config.hl_line_num.enable = true
    M.hl_line_num()
    require("hlchunk.autocmd").enable_hl_line_num_autocms()
end

return M
