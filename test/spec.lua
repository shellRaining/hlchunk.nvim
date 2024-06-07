vim.api.nvim_command([[set rtp+=.]])

local cwd = vim.fn.getcwd()

vim.api.nvim_command(string.format([[set rtp+=%s,%s/test]], cwd, cwd))
vim.api.nvim_command(string.format([[set packpath=%s/.ci/vendor]], cwd))
vim.api.nvim_command([[packloadall]])
