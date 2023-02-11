local hlchunk = require("hlchunk.hlchunk")

vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    pattern = "*",
    desc = "TODO: add description here",
    callback = hlchunk.hl_chunk,
})

-- vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "TextChangedP" }, {
--     pattern = hlchunk_supported_files,
--     desc = "TODO: add description here",
--     callback = hlchunk,
-- })
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TextChangedP" }, {
--     pattern = hlchunk_supported_files,
--     desc = "TODO: add description here",
--     callback = function()
--         local buf = vim.fn.bufnr()
--         vim.fn.setbufvar(buf, "enable_hlchunk", check())
--     end,
-- })
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "TextChanged", "TextChangedI", "TextChangedP" }, {
--     pattern = hlchunk_supported_files,
--     desc = "TODO: add description here",
--     callback = function()
--         local buf = vim.fn.bufnr()
--         local win_id = vim.fn.winnr()
--         vim.fn.setbufvar(buf, "hlchunk_textoff", vim.fn.getwininfo()[win_id].textoff)
--     end,
-- })
--
-- vim.api.nvim_create_autocmd({ "WinScrolled" }, {
--     pattern = "*",
--     desc = "TODO: add description here",
--     callback = hlchunk,
-- })
--
-- vim.api.nvim_set_hl(0, "HLIndentLine", hlchunk_hi_style)
