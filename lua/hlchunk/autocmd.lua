local config = require("hlchunk.options").config
local utils = require("hlchunk.utils.utils")
local api = vim.api
local fn = vim.fn

local M = {}

local global_var_autocmd = -1
local hl_chunk_augroup_handler = -1
local hl_indent_augroup_handler = -1
local hl_line_augroup_handler = -1

-- TODO: need to refactor these functions
function M.enable_autocmds()
    global_var_autocmd = api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        pattern = config.hlchunk_supported_files,
        callback = function()
            if config.hl_chunk.enable or config.hl_line_num.enable then
                CUR_LINE_NUM = fn.line(".")
                CUR_CHUNK_RANGE = utils.get_pair_rows()
            end
        end,
    })
    M.enable_hl_chunk_autocmds()
    M.enable_hl_indent_autocmds()
    M.enable_hl_line_num_autocms()
end

function M.disable_autocmds()
    api.nvim_del_autocmd(global_var_autocmd)
    M.disable_hl_chunk_autocmds()
    M.disable_hl_indent_autocmds()
    M.disable_hl_line_autocmds()
end

function M.enable_hl_chunk_autocmds()
    if hl_chunk_augroup_handler ~= -1 then
        return
    end

    hl_chunk_augroup_handler = api.nvim_create_augroup("hl_chunk_augroup", { clear = true })

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_chunk_augroup",
        pattern = config.hlchunk_supported_files,
        desc = "QUES: why just only CursorMoved is ok",
        callback = function()
            local ok, value = pcall(require("hlchunk.hl_chunk").hl_cur_chunk)
            if not ok then
                vim.notify_once(tostring(value), vim.log.levels.ERROR)
            end
        end,
    })
end

function M.disable_hl_chunk_autocmds()
    if hl_chunk_augroup_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hl_chunk_augroup")
    hl_chunk_augroup_handler = -1
end

function M.enable_hl_indent_autocmds()
    if hl_indent_augroup_handler ~= -1 then
        return
    end

    hl_indent_augroup_handler = api.nvim_create_augroup("hl_indent_augroup", { clear = true })

    api.nvim_create_autocmd({ "WinScrolled", "TextChanged", "TextChangedI", "BufWinEnter", "CompleteChanged" }, {
        group = "hl_indent_augroup",
        pattern = "*",
        desc = "when windows scrolled refresh indent mark, can set filetype",
        callback = function()
            local ok, value = pcall(require("hlchunk.hl_indent").hl_indent)
            if not ok then
                vim.notify_once(tostring(value), vim.log.levels.ERROR)
            end
        end,
    })
end

function M.disable_hl_indent_autocmds()
    if hl_indent_augroup_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hl_indent_augroup")
    hl_indent_augroup_handler = -1
end

function M.enable_hl_line_num_autocms()
    if hl_line_augroup_handler ~= -1 then
        return
    end

    hl_line_augroup_handler = api.nvim_create_augroup("hl_line_augroup", { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_line_augroup",
        pattern = config.hlchunk_supported_files,
        desc = "the autocmds about highlight line number",
        callback = function()
            local ok, value = pcall(require("hlchunk.hl_line_num").hl_line_num)
            if not ok then
                vim.notify_once(tostring(value), vim.log.levels.ERROR)
            end
        end,
    })
end

function M.disable_hl_line_autocmds()
    if hl_line_augroup_handler == -1 then
        return
    end

    api.nvim_del_augroup_by_name("hl_line_augroup")
    hl_line_augroup_handler = -1
end

return M
