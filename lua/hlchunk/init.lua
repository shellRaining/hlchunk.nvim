local hlchunk = {}

local function enable_all_mods()
    for mod, _ in pairs(PLUG_CONF) do
        require("hlchunk.mods." .. mod):enable()
    end
end

local function disable_all_mods()
    for mod, _ in pairs(PLUG_CONF) do
        require("hlchunk.mods." .. mod):disable()
    end
end

hlchunk.setup = function(params)
    require("hlchunk.global")
    PLUG_CONF = vim.tbl_deep_extend("force", PLUG_CONF, params)
    require("hlchunk.highlight")

    for mod_name, mod_conf in pairs(PLUG_CONF) do
        if mod_conf.enable then
            local ok, mod = pcall(require, "hlchunk.mods." .. mod_name)
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

    for key, _ in pairs(PLUG_CONF) do
        local ok, mod = pcall(require, "hlchunk.mods." .. key)
        if ok then
            mod:create_mod_usercmd()
        end
    end
    API.nvim_create_user_command("EnableHL", enable_all_mods, {})
    API.nvim_create_user_command("DisableHL", disable_all_mods, {})
end

return hlchunk
