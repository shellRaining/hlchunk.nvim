local stringx = require("hlchunk.utils.string")
local Array = require("hlchunk.utils.array")
local api = vim.api

---@class BaseMod
---@field name string
---@field options table | nil
---@field new fun(self: BaseMod, o: table): BaseMod
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod)
---@field clear fun(self: BaseMod)
---@field enable_mod_autocmd fun(self: BaseMod)
---@field disable_mod_autocmd fun(self: BaseMod)
---@field create_mod_usercmd fun(self: BaseMod)
---@field set_options fun(self: BaseMod, options: table | nil)
local BaseMod = {
    name = "",
    options = nil,
}

function BaseMod:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function BaseMod:enable()
    vim.notify("not implemented enable " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:disable()
    vim.notify("not implemented disable " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:render()
    vim.notify("not implemented render " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:clear()
    vim.notify("not implemented clear " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:enable_mod_autocmd()
    vim.notify("not implemented enable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:disable_mod_autocmd()
    vim.notify("not implemented disable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:create_mod_usercmd()
    vim.notify("not implemented create_mod_usercmd " .. self.name, vim.log.levels.ERROR)
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

---@param args table
function BaseMod:set_hl(args)
    local token_array = Array:from(stringx.split(self.name, "_"))
    local hl_name = "HL" .. token_array
        :map(function(value)
            return stringx.firstToUpper(value)
        end)
        :join() .. "Style"
    set_hl(hl_name, args)()
end

-- set options for mod, if the mod dont have default config, it will notify you
---@param options table | nil
function BaseMod:set_options(options)
    if self.options == nil then
        vim.notify("not set the default config for " .. self.name, vim.log.levels.ERROR)
        return
    end
    self.options = vim.tbl_deep_extend("force", self.options, options or {})
end

return BaseMod
