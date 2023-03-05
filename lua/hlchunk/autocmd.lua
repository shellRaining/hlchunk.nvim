local M = {}

local global_var_autocmd = -1

function M.enable_specific_autocmd(mod)
    require("hlchunk.mods." .. mod).enable_mod_autocmd()
end

function M.disable_specific_autocmd(mod)
    require("hlchunk.mods." .. mod).disable_mod_autocmd()
end

function M.enable_registered_autocmds()
    global_var_autocmd = API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        pattern = PLUG_CONF.hlchunk_supported_files,
        callback = function()
            if PLUG_CONF.hl_chunk.enable or PLUG_CONF.hl_line_num.enable then
                CUR_LINE_NUM = FN.line(".")
                CUR_CHUNK_RANGE = UTILS.get_pair_rows()
            end
        end,
    })

    for _, mod in pairs(REGISTED_MODS) do
        M.enable_specific_autocmd(mod)
    end
end

function M.disable_registered_autocmds()
    API.nvim_del_autocmd(global_var_autocmd)
    for _, mod in pairs(REGISTED_MODS) do
        M.disable_specific_autocmd(mod)
    end
end

return M
