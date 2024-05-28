local function createClass(base, user_ctor)
    local c = {}

    if base then
        for i, v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end

    c.__index = c -- NOTE: this is important that __index can't place before copy process, or it will be override
    c.init = user_ctor
    return c
end

---@generic T
---@param user_ctor T
---@return fun(...): T
local function baseClass(user_ctor)
    local c = createClass(nil, user_ctor)
    local mt = {}
    mt.__call = function(_, ...)
        local obj = {}
        setmetatable(obj, c)
        user_ctor(obj, ...)
        return obj
    end
    setmetatable(c, mt)
    return c
end

local function derivedClass(base, user_ctor)
    local c = createClass(base, user_ctor)
    local mt = {}
    mt.__call = function(_, ...)
        local instance = {}
        setmetatable(instance, c)
        if user_ctor then
            user_ctor(instance, ...)
        else
            if base and base.init then
                base.init(instance, ...)
            end
        end
        return instance
    end
    setmetatable(c, mt)
    return c
end

---@return any
local function class(base, init)
    if not init and type(base) == "function" then
        local user_ctor = base
        return baseClass(user_ctor)
    else
        return derivedClass(base, init)
    end
end

return class
