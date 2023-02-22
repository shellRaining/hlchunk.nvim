local opts = require("hlchunk.options")

local hlchunk = {}

hlchunk.setup = function(params)
    opts.config = vim.tbl_extend("force", {}, opts.config, params or {})

    if not opts.config.enabled then
        return
    end

    require("hlchunk.usercmd")
    require("hlchunk.highlight")
    require("hlchunk.autocmd").enable_autocmds()
end

return hlchunk
