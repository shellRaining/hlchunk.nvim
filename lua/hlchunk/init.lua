-- TODO: add package annotations
local hlchunk = {}
local api = vim.api

-- get the status(whether enabled) of mods, return a table
-- the first key is the mod name, the second key is a bool variables to represent whether enabled
---@param plugin_config PlugConfig
---@return table<string, boolean>
local function get_mods_status(plugin_config)
    plugin_config = plugin_config or {}
    local mods_status = {
        chunk = true,
        line_num = true,
        indent = true,
        blank = true,
        context = false,
    }

    for mod_name, mod_conf in pairs(plugin_config) do
        if mod_conf and mod_conf.enable ~= nil then
            mods_status[mod_name] = mod_conf.enable
        end
    end

    return mods_status
end

-- set user commands to enable/disable all mods for those which has been enabled in config file or default config
---@param mods_status table<string, boolean>
local function set_usercmds(mods_status)
    api.nvim_create_user_command("EnableHL", function()
        for mod_name, enabled in pairs(mods_status) do
            if enabled then
                require("hlchunk.mods." .. mod_name):enable()
            end
        end
    end, {})
    api.nvim_create_user_command("DisableHL", function()
        for mod_name, enabled in pairs(mods_status) do
            if enabled then
                require("hlchunk.mods." .. mod_name):disable()
            end
        end
    end, {})
end

---@param params PlugConfig
hlchunk.setup = function(params)
    require("hlchunk.utils.string")
    local mods_status = get_mods_status(params)
    set_usercmds(mods_status)
    for mod_name, enabled in pairs(mods_status) do
        if enabled then
            local mod = require("hlchunk.mods." .. mod_name)
            mod:set_options(params[mod_name])
            mod:enable()
        end
    end
end

return hlchunk
