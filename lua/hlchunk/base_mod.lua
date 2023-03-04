-- C means 'Class'
local C = {
    name = "",
}

function C:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function C:enable()
    vim.notify("not implemented enable " .. self.name)
end
function C:disable()
    vim.notify("not implemented disable " .. self.name)
end
function C:render()
    vim.notify("not implemented render " .. self.name)
end
function C:clear()
    vim.notify("not implemented clear " .. self.name)
end
function C:enable_mod_autocmd()
    vim.notify("not implemented enable_mod_autocmd " .. self.name)
end
function C:disable_mod_autocmd()
    vim.notify("not implemented disable_mod_autocmd " .. self.name)
end
function C:enable_mod_usercmd()
    vim.notify("not implemented enable_mod_usercmd " .. self.name)
end
function C:disable_mod_usercmd()
    vim.notify("not implemented disable_mod_usercmd " .. self.name)
end

return C
