local opts = require("hlchunk.options")

local hlchunk = {}

hlchunk.setup = function(params)
    opts.config = vim.tbl_deep_extend("force", opts.config, params)

    if not opts.config.enabled then
        return
    end
    if opts.config.hl_indent.use_treesitter then
        local ts_query_status, ts_query = pcall(require, "nvim-treesitter.query")
        if not ts_query_status then
            vim.notify_once("ts_query not load")
            return
        end
        local ft = vim.bo.filetype
        if not (ts_query.has_indents(ft) or opts.config.hl_indent.exclude_filetype[ft]) then
            vim.notify_once("treesitter not support indent for this filetype: " .. ft)
        end
    end

    require("hlchunk.global")
    require("hlchunk.usercmd")
    require("hlchunk.highlight").set_hls()
    require("hlchunk.autocmd").enable_registered_autocmds()
end

return hlchunk
