local opts = require("hlchunk.options")

local hlchunk = {}

hlchunk.setup = function(params)
    opts.config = vim.tbl_extend("force", {}, opts.config, params or {})

    if not opts.config.enabled then
        return
    end

    vim.fn.sign_define("LineNumberInterval", {
        numhl = "HLChunkStyle1",
    })

    require("hlchunk.usercmd")
    require("hlchunk.highlight").set_hls()
    require("hlchunk.autocmd").enable_autocmds()
end

return hlchunk
