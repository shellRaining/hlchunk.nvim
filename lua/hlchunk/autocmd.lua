local config = require("hlchunk.options").config
local utils = require("hlchunk.utils")
local api = vim.api

local M = {}

local hl_chunk_autocmd_handler = -1
local hl_indent_autocmd_handler = -1
local hl_line_autocmd_handler = -1

-- TODO: need to refactor these functions
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
        callback = function ()
            CUR_LINE_NUM = vim.fn.line('.')
            CUR_CHUNK_RANGE = utils.get_pair_rows()
            require("hlchunk.hl_chunk").hl_cur_chunk()
        end
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
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_indent_autocmds",
        pattern = "*",
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

function M.enable_hl_line_num()
    if hl_line_autocmd_handler ~= -1 then
        return
    end

    hl_line_autocmd_handler = api.nvim_create_augroup("hl_line_autocmds", { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_line_autocmds",
        pattern = config.hlchunk_supported_files,
        desc = "the autocmds about highlight line number",
        -- TODO:
        callback = require("hlchunk.hl_line_num").hl_line_num(),
    })
end

return M
