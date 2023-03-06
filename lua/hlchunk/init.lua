local opts = require("hlchunk.options")

local hlchunk = {}

hlchunk.setup = function(params)
    opts.config = vim.tbl_deep_extend("force", opts.config, params)

    if opts.config.indent.use_treesitter then
        local ts_query_status, ts_query = pcall(require, "nvim-treesitter.query")
        if not ts_query_status then
            vim.notify_once("ts_query not load")
            return
        end
        local ft = vim.bo.filetype
        if not (ts_query.has_indents(ft) or opts.config.indent.exclude_filetype[ft]) then
            vim.notify_once("treesitter not support indent for this filetype: " .. ft)
        end
    end

    require("hlchunk.global")
    require("hlchunk.highlight").set_hls()

    for key, value in pairs(opts.config) do
        if value.enable then
            local ok, mod = pcall(require, "hlchunk.mods." .. key)
            if not ok then
                vim.notify(
                    "you get this info because my mistake... \n"
                        .. "I refactor the structure of plugin,\n"
                        .. "you can go to https://github.com/shellRaining/hlchunk.nvim\n"
                        .. "to get the latest config info"
                )
                vim.notify(mod, vim.log.levels.ERROR)
                return
            end
            mod:enable()
        end
    end

    require("hlchunk.usercmd")
end

return hlchunk
