local hlchunk = {}

-- global var that represents utils and built-in functions
local api = vim.api
local fn = vim.fn
PLUG_CONF = require("hlchunk.options").config

-- static global variables

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

local function set_usercmds()
    api.nvim_create_user_command("EnableHL", enable_all_mods, {})
    api.nvim_create_user_command("DisableHL", disable_all_mods, {})
end

local function set_hl(hl_base_name, args)
    local count = 1

    return function()
        if type(args) == "string" then
            api.nvim_set_hl(0, hl_base_name .. "1", {
                fg = args,
            })
        elseif type(args) == "table" then
            for _, value in pairs(args) do
                local hl_name = hl_base_name .. tostring(count)
                if type(value) == "string" then
                    api.nvim_set_hl(0, hl_name, {
                        fg = value,
                    })
                elseif type(value) == "table" then
                    api.nvim_set_hl(0, hl_name, {
                        fg = value[1],
                        bg = value[2],
                        nocombine = true,
                    })
                end
                count = count + 1
            end
        else
            vim.notify("highlight format error")
        end
    end
end

local function set_signs()
    if type(PLUG_CONF.line_num.style) == "table" then
        local tbl = {}
        for i = 1, 1 do
            local sign_name = "sign" .. tostring(i)
            local hl_name = "HLLineNumStyle" .. tostring(i)
            tbl[#tbl + 1] = { name = sign_name, numhl = hl_name }
        end
        fn.sign_define(tbl)
    else
        fn.sign_define("sign1", {
            numhl = "HLLineNumStyle1",
        })
    end
end

local function get_hl_base_name(s)
    local stringx = require("hlchunk.utils.string")
    local token_list = stringx.split(s, "_")
    local res = ""
    for _, value in pairs(token_list) do
        res = res .. stringx.firstToUpper(value)
    end
    return "HL" .. res .. "Style"
end

-- execute this function to get styles
local function set_hls()
    for key, value in pairs(PLUG_CONF) do
        local hl_base_name = get_hl_base_name(key)
        set_hl(hl_base_name, value.style)()
    end
    set_signs()
end

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
        if mod_conf.enable then
            mods_status[mod_name] = true
        end
    end

    return mods_status
end

---@class PlugConfig
---@field chunk? table
---@field line_num? table
---@field indent? table
---@field blank? table
---@field context? table
---@param params PlugConfig
hlchunk.setup = function(params)
    set_usercmds()
    set_hls()
    local mods_status = get_mods_status(params)
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
