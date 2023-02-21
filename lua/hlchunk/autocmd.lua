local config = require("hlchunk.options").config
local api = vim.api

local M = {}

local hlchunk_autocmds_handler = -1

function M.enable_hlchunk_autocmds()
    if hlchunk_autocmds_handler ~= -1 then
        return
    end

    hlchunk_autocmds_handler = api.nvim_create_augroup("hlchunk_autocmds", { clear = true })

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hlchunk_autocmds",
        pattern = config.hlchunk_supported_files,
        desc = "QUES: why just only CursorMoved is ok",
        callback = require("hlchunk.hl_chunk").hl_cur_chunk,
    })

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = "hlchunk_autocmds",
        pattern = "*",
        desc = "when windows scrolled refresh indent mark, can set filetype",
        callback = require("hlchunk.hl_indent").hl_indent,
    })
end

function M.disable_hlchunk_autocmds()
    if hlchunk_autocmds_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hlchunk_autocmds")
    hlchunk_autocmds_handler = -1
end

return M
