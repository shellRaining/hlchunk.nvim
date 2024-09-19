local class = require("hlchunk.utils.class")

---@class HlChunk.Cache
---@field private cache table
---@field private keys table
---@overload fun(...):HlChunk.Cache
local Cache = class(function(self, ...)
    self.keys = { ... } -- 在构造函数中保存键名
    self.cache = {}
end)

local function navigateCache(cache, values, createIfMissing, isSetValue, setValue)
    local tableRef = cache
    local searchSteps = #values
    for i = 1, searchSteps - 1 do
        local key = values[i]
        if tableRef[key] == nil then
            if createIfMissing then
                tableRef[key] = {}
            else
                return nil
            end
        end
        tableRef = tableRef[key]
    end

    if isSetValue then
        tableRef[values[searchSteps]] = setValue
    else
        return tableRef[values[searchSteps]]
    end
end

function Cache:get(...)
    local values = { ... }
    if #values ~= #self.keys then
        error("The number of keys passed to get() must match the number of keys passed to the constructor")
    end
    return navigateCache(self.cache, values, false)
end

function Cache:set(...)
    local values = { ... }
    if #values ~= #self.keys + 1 then
        error("The number of keys passed to set() must be one more than the number of keys passed to the constructor")
    end
    local value = table.remove(values) -- 将最后一个参数作为要设置的值
    navigateCache(self.cache, values, true, true, value)
end

function Cache:has(...)
    local values = { ... }
    if #values ~= #self.keys then
        error("The number of keys passed to has() must match the number of keys passed to the constructor")
    end
    return navigateCache(self.cache, values, false) ~= nil
end

function Cache:clear(...)
    local values = { ... }
    if #values == 0 then
        self.cache = {}
    else
        navigateCache(self.cache, values, false, true, {})
    end
end

function Cache:remove(...)
    local values = { ... }
    if #values ~= #self.keys then
        error("The number of keys passed to remove() must match the number of keys passed to the constructor")
    end
    navigateCache(self.cache, values, false, true, nil)
end

return Cache
