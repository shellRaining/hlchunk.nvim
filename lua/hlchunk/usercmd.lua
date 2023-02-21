local api = vim.api
local hl_chunk = require("hlchunk.hl_chunk")
local hl_indent = require("hlchunk.hl_indent")

local M = {}

api.nvim_create_user_command("DisableHLChunk", hl_chunk.disable_hl_cur_chunk, {})
api.nvim_create_user_command("EnableHLChunk", hl_chunk.enable_hl_cur_chunk, {})
api.nvim_create_user_command("DisableHLIndent", hl_indent.disable_hl_indent, {})
api.nvim_create_user_command("EnableHLIndent", hl_indent.enable_hl_indent, {})


return M
