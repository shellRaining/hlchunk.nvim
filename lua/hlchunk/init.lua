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

local function set_usercmds()
    API.nvim_create_user_command("EnableHL", enable_all_mods, {})
    API.nvim_create_user_command("DisableHL", disable_all_mods, {})
end

local function set_hl(hl_base_name, args)
    local count = 1

    return function()
        if type(args) == "string" then
            vim.api.nvim_set_hl(0, hl_base_name .. "1", {
                fg = args,
            })
        elseif type(args) == "table" then
            for _, value in pairs(args) do
                local hl_name = hl_base_name .. tostring(count)
                if type(value) == "string" then
                    vim.api.nvim_set_hl(0, hl_name, {
                        fg = value,
                    })
                elseif type(value) == "table" then
                    vim.api.nvim_set_hl(0, hl_name, {
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
        vim.fn.sign_define(tbl)
    else
        vim.fn.sign_define("sign1", {
            numhl = "HLLineNumStyle1",
        })
    end
end

local function get_hl_base_name(s)
    local token_list = STRINGX.split(s, "_")
    local res = ""
    for _, value in pairs(token_list) do
        res = res .. STRINGX.firstToUpper(value)
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

hlchunk.setup = function(params)
    require("hlchunk.global")
    PLUG_CONF = vim.tbl_deep_extend("force", PLUG_CONF, params)
    set_usercmds()
    set_hls()

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
            mod:create_mod_usercmd()
        end
    end
end

return hlchunk
