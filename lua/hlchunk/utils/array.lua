---@alias callbackFn fun(v: any, k: any): any

---@class Array
---@field new fun(self: Array, ...: any): Array
---@field from fun(self: Array, t: table | string | Array, f?: callbackFn): Array
---@field size fun(self: Array): number
---@field map fun(self: Array, f: callbackFn): Array
---@field filter fun(self: Array, f: callbackFn): Array
---@field push fun(self: Array, v: any): Array
---@field pop fun(self: Array): any
---@field shift fun(self: Array): any
---@field join fun(self: Array, sep?: string): string
local Array = {}

-- this is constructor of Array class
---@param self Array
---@param ... any
---@return Array
function Array:new(...)
    local o = {}
    local params_num = select("#", ...)
    if params_num == 1 then
        local arg1 = select(1, ...)
        if type(arg1) == "number" then
            for i = 1, tonumber(arg1) do
                o[i] = nil
            end
        else
            o[1] = arg1
        end
    elseif params_num > 1 then
        for i = 1, params_num do
            o[i] = select(i, ...)
        end
    end

    self.__index = self
    setmetatable(o, self)

    return o
end

-- create a new array from another iterable class like table or string
---@param self Array
---@param t table | string | Array
---@param f? callbackFn
---@return Array
function Array:from(t, f)
    local new_arr = Array:new()
    if type(t) == "table" then
        for k, v in pairs(t) do
            new_arr:push(f and f(v, k) or v)
        end
    elseif type(t) == "string" then
        for i = 1, #t do
            new_arr:push(f and f(t:sub(i, i), i) or t:sub(i, i))
        end
    end
    return new_arr
end

-- get size of a table
---@param self Array
---@return number
function Array:size()
    local i = 0
    for _ in pairs(self) do
        i = i + 1
    end
    return i
end

-- execute a function for each element of a table
---@param f callbackFn
function Array:foreach(f)
    for k, v in pairs(self) do
        f(v, k)
    end
end

-- map a function to each element of a table and return this new table
---@param self Array
---@param f callbackFn
---@return Array
function Array:map(f)
    local new_arr = Array:new()
    for k, v in pairs(self) do
        new_arr:push(f(v, k))
    end
    return new_arr
end

-- filter a table by a function and return this new table
---@param self Array
---@param f callbackFn
---@return Array
function Array:filter(f)
    local new_arr = Array:new()
    for k, v in pairs(self) do
        if f(v, k) then
            new_arr:push(v)
        end
    end
    return new_arr
end

-- push a value to the end of a table
---@param self Array
---@param v any
---@return Array
function Array:push(v)
    local size = self:size()
    self[size + 1] = v
    return self
end

-- pop a value from the end of a table
---@param self Array
---@return any
function Array:pop()
    local size = self:size()
    local v = self[size]
    self[size] = nil
    return v
end

-- shift a value from the beginning of a table,
-- warning: very cost time when the table is large, use carefully
---@param self Array
---@return any
function Array:shift()
    local size = self:size()
    local v = self[1]
    for i = 1, size - 1 do
        self[i] = self[i + 1]
    end
    self[size] = nil
    return v
end

-- join a table to a string
---@param self Array
---@param sep? string
---@return string
function Array:join(sep)
    sep = sep or ""
    local res = ""
    for k, v in pairs(self) do
        if k == 1 then
            res = res .. tostring(v)
        else
            res = res .. sep .. tostring(v)
        end
    end
    return res
end

return Array
