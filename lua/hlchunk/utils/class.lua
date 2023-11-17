---@generic C
local function class(base, init)
    local c = {} -- a new class instance
    if not init and type(base) == "function" then
        init = base
        base = nil
    elseif type(base) == "table" then
        for i, v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    c.__index = c

    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, c)
        if init then
            init(obj, ...)
        else
            if base and base.init then
                base.init(obj, ...)
            end
        end
        return obj
    end
    c.init = init
    setmetatable(c, mt)
    return c
end

return class
