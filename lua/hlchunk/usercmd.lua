local M = {}

function M.enable_registered_mods()
    for _, mod in pairs(REGISTED_MODS) do
        require("hlchunk.mods." .. mod):enable()
    end
end

function M.disable_registered_mods()
    for _, mod in pairs(REGISTED_MODS) do
        require("hlchunk.mods." .. mod):disable()
    end
end

API.nvim_create_user_command("EnableHL", M.enable_registered_mods, {})
API.nvim_create_user_command("DisableHL", M.disable_registered_mods, {})

return M
