local Array = require("hlchunk.utils.array")
local api = vim.api
local fn = vim.fn

---@class BaseMod
---@field name string
---@field options table | nil
---@field new fun(self: BaseMod, o: table): BaseMod
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod)
---@field clear fun(self: BaseMod, line_start: number | nil, line_end: number | nil)
---@field enable_mod_autocmd fun(self: BaseMod)
---@field disable_mod_autocmd fun(self: BaseMod)
---@field create_mod_usercmd fun(self: BaseMod)
---@field set_options fun(self: BaseMod, options: table | nil)
local BaseMod = {
    name = "",
    options = nil,
    ns_id = -1,
    old_win_info = fn.winsaveview(),
}

function BaseMod:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function BaseMod:enable()
    local ok, info = pcall(function()
        self.options.enable = true
        self:set_hl(self.options.style)
        self:render()
        self:enable_mod_autocmd()
        self:create_mod_usercmd()
    end)
    if not ok then
        -- vim.notify("you have enable " .. self.name .. " mod")
        vim.notify(tostring(info))
    end
end
function BaseMod:disable()
    local ok, _ = pcall(function()
        self.options.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable " .. self.name .. " mod")
    end
end
function BaseMod:render()
    vim.notify("not implemented render " .. self.name, vim.log.levels.ERROR)
end

function BaseMod:clear(line_start, line_end)
    line_start = line_start or 0
    line_end = line_end or -1

    if self.ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, self.ns_id, line_start, line_end)
    end
end
function BaseMod:enable_mod_autocmd()
    vim.notify("not implemented enable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:disable_mod_autocmd()
    vim.notify("not implemented disable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:create_mod_usercmd()
    local token_array = Array:from(self.name:split("_"))
    local mod_name = token_array
        :map(function(value)
            return value:firstToUpper()
        end)
        :join()
    api.nvim_create_user_command("EnableHL" .. mod_name, function()
        self:enable()
    end, {})
    api.nvim_create_user_command("DisableHL" .. mod_name, function()
        self:disable()
    end, {})
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

-- set highlight for mod
---@param args table
function BaseMod:set_hl(args)
    local token_array = Array:from(self.name:split("_"))
    local hl_name = "HL"
        .. token_array
            :map(function(value)
                return value:firstToUpper()
            end)
            :join()
        .. "Style"
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
