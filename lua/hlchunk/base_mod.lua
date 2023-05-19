local Array = require("hlchunk.utils.array")
local api = vim.api
local fn = vim.fn

---@class BaseMod
---@field name string the name of mod, use Snake_case naming style, such as line_num
---@field ns_id number
---@field old_win_info table used to record old window info such as leftcol, curline and top line and so on
---@field options table | nil default config for mod, and user can change it when setup
---@field augroup_name string with format hl_{mod_name}_augroup, such as hl_chunk_augroup
---@field hl_base_name string with format HL{mod_name:firstToUpper()}, such as HLChunk
local BaseMod = {
    name = "",
    options = nil,
    ns_id = -1,
    old_win_info = fn.winsaveview(),
    augroup_name = "",
    hl_base_name = "",
}

---@class BaseMod
---@field new fun(self: BaseMod, o: table): BaseMod
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod)
---@field clear fun(self: BaseMod, line_start: number | nil, line_end: number | nil)
---@field enable_mod_autocmd fun(self: BaseMod)
---@field disable_mod_autocmd fun(self: BaseMod)
---@field create_mod_usercmd fun(self: BaseMod)
---@field set_options fun(self: BaseMod, options: table | nil)
function BaseMod:new(o)
    o = o or {}
    o.augroup_name = o.augroup_name or ("hl_" .. o.name .. "_augroup")
    o.hl_base_name = o.hl_base_name or ("HL" .. o.name:firstToUpper())
    self.__index = self
    setmetatable(o, self)
    return o
end

function BaseMod:enable()
    local ok, info = pcall(function()
        self.options.enable = true
        self:set_hl()
        self:render()
        self:enable_mod_autocmd()
        self:create_mod_usercmd()
    end)
    if not ok then
        vim.notify(tostring(info))
    end
end

function BaseMod:disable()
    local ok, info = pcall(function()
        self.options.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable " .. self.name .. " mod")
        vim.notify(tostring(info))
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
    api.nvim_create_augroup(self.augroup_name, { clear = true })
end

function BaseMod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name(self.augroup_name)
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

-- set highlight for mod
function BaseMod:set_hl(color)
    local hl_opts = self.options.style
    if color then
      hl_opts = color
    end
    if type(hl_opts) == "string" then
        api.nvim_set_hl(0, self.hl_base_name .. "1", { fg = hl_opts })
        return
    end

    for idx, value in ipairs(hl_opts) do
        local value_type = type(value)
        if value_type == "table" then
            api.nvim_set_hl(0, self.hl_base_name .. idx, value)
        elseif value_type == "string" then
            api.nvim_set_hl(0, self.hl_base_name .. idx, { fg = value })
        end
    end
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
