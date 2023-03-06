local function enable_registered_mods()
    for _, mod in pairs(REGISTED_MODS) do
        require("hlchunk.mods." .. mod):enable()
    end
end

local function disable_registered_mods()
    for _, mod in pairs(REGISTED_MODS) do
        require("hlchunk.mods." .. mod):disable()
    end
end

API.nvim_create_user_command("EnableHL", enable_registered_mods, {})
API.nvim_create_user_command("DisableHL", disable_registered_mods, {})

for key, _ in pairs(PLUG_CONF) do
    local ok, mod = pcall(require, "hlchunk.mods." .. key)
    if ok then
        mod:create_mod_usercmd()
    end
end
