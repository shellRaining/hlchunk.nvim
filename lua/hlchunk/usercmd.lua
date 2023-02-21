local api = vim.api
local hlchunk = require("hlchunk.hlchunk")

local M = {}

api.nvim_create_user_command("DisableHLChunk", hlchunk.disable_hlchunk, {})
api.nvim_create_user_command("EnableHLChunk", hlchunk.enable_hlchunk, {})

return M
