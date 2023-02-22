local config = require("hlchunk.options").config
local api = vim.api

local M = {}

local hl_chunk_autocmd_handler = -1
local hl_indent_autocmd_handler = -1

function M.enable_autocmds()
    M.enable_hl_chunk_autocmds()
    M.enable_hl_indent_autocmds()
end

function M.disable_autocmds()
    M.disable_hl_chunk_autocmds()
    M.disable_hl_indent_autocmds()
end

function M.enable_hl_chunk_autocmds()
    if hl_chunk_autocmd_handler ~= -1 then
        return
    end

    hl_chunk_autocmd_handler = api.nvim_create_augroup("hl_chunk_autocmds", { clear = true })

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_chunk_autocmds",
        pattern = config.hlchunk_supported_files,
        desc = "QUES: why just only CursorMoved is ok",
        callback = require("hlchunk.hl_chunk").hl_cur_chunk,
    })
end

function M.disable_hl_chunk_autocmds()
    if hl_chunk_autocmd_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hl_chunk_autocmds")
    hl_chunk_autocmd_handler = -1
end

function M.enable_hl_indent_autocmds()
    if hl_indent_autocmd_handler ~= -1 then
        return
    end

    hl_indent_autocmd_handler = api.nvim_create_augroup("hl_indent_autocmds", { clear = true })

    api.nvim_create_autocmd({ "WinScrolled" }, {
        group = "hl_indent_autocmds",
        pattern = "*",
        desc = "when windows scrolled refresh indent mark, can set filetype",
        callback = require("hlchunk.hl_indent").hl_indent,
    })
end

function M.disable_hl_indent_autocmds()
    if hl_indent_autocmd_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hl_indent_autocmds")
    hl_indent_autocmd_handler = -1
end

return M
