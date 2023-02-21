local config = require("hlchunk.options").config

if config.enabled then
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        pattern = config.hlchunk_supported_files,
        desc = "QUES: why just only CursorMoved is ok",
        callback = require("hlchunk.hlchunk").hl_chunk,
    })
end
