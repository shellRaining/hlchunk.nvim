-- C means 'Class'

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
---@field set_options fun(self: BaseMod, options: table)
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
function BaseMod:set_options(options)
    if self.options == nil then
        vim.notify("not set the default config for " .. self.name, vim.log.levels.ERROR)
    end
    self.options = vim.tbl_deep_extend("force", self.options, options or {})
end

return BaseMod
