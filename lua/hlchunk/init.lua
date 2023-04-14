local hlchunk = {}

-- global var that represents utils and built-in functions
local api = vim.api


-- get the status(whether enabled) of mods, return a table, the first key is the mod name, the second key is a bool variables to represent whether enabled
---@param params table
---@return table<string, boolean>
local function get_mods_status(params)
    local mods_status = {
        chunk = true,
        line_num = true,
        indent = true,
        blank = true,
        context = false,
    }

    for mod_name, mod_conf in pairs(params) do
        if mod_conf and mod_conf.enable ~= nil then
            mods_status[mod_name] = mod_conf.enable
        end
    end

    return mods_status
end

local function set_usercmds(mods_status)
    api.nvim_create_user_command("EnableHL", function ()
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

---@class PlugConfig
---@field chunk? table
---@field line_num? table
---@field indent? table
---@field blank? table
---@field context? table
---@param params PlugConfig
hlchunk.setup = function(params)
    local mods_status = get_mods_status(params)
    set_usercmds(mods_status)
    for mod_name, enabled in pairs(mods_status) do
        if enabled then
            local _, mod = pcall(require, "hlchunk.mods." .. mod_name)
            mod:set_options(params[mod_name])
            mod:enable()
            mod:create_mod_usercmd()
        end
    end
end

return hlchunk
