local class = require("hlchunk.utils.class")

---@class Cache
---@field private cache table<number, table<string|number, any>>
---@overload fun():Cache
local Cache = class(function(self)
    self.cache = {}
end)

---@param bufnr number
---@param key string|number
---@return any
function Cache:get(bufnr, key)
    if not self.cache[bufnr] then
        return nil
    end
    return self.cache[bufnr][key]
end

---@param bufnr number
---@param key string|number
---@param value any
function Cache:set(bufnr, key, value)
    if not self.cache[bufnr] then
        self.cache[bufnr] = {}
    end
    self.cache[bufnr][key] = value
end

---@param bufnr number
---@param key string|number
---@return boolean
function Cache:has(bufnr, key)
    return self.cache[bufnr] and self.cache[bufnr][key]
end

---@param bufnr number
function Cache:clear(bufnr)
    self.cache[bufnr] = {}
end

return Cache
