local stringx = require("hlchunk.utils.string")

local M = {}

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
                vim.api.nvim_set_hl(0, hl_name, {
                    fg = value,
                })
                count = count + 1
            end
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
    local token_list = stringx.split(s, "_")
    local res = ""
    for _, value in pairs(token_list) do
        res = res .. stringx.firstToUpper(value)
    end
    return "HL" .. res .. "Style"
end

function M.set_hls()
    for key, value in pairs(PLUG_CONF) do
        local hl_base_name = get_hl_base_name(key)
        set_hl(hl_base_name, value.style)()
    end
    set_signs()
end

return M
