local mt = getmetatable("")

---@param self string
---@param sep? string
mt.__index.split = function(self, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(self, "([^" .. sep .. "]+)") do
        -- t:insert(str)
        table.insert(t, str)
    end
    return t
end

---@param self string
mt.__index.firstToUpper = function(self)
    return (self:gsub("^%l", string.upper))
end

---@param self string
---@param idx number
mt.__index.at = function(self, idx)
    return self:sub(idx, idx)
end

-- function string:split(sep)
--     if sep == nil then
--         sep = "%s"
--     end
--     local t = {}
--     for str in string.gmatch(self, "([^" .. sep .. "]+)") do
--         -- t:insert(str)
--         table.insert(t, str)
--     end
--     return t
-- end

-- function string:firstToUpper()
--     return (self:gsub("^%l", string.upper))
-- end

-- function string:at(idx)
-- local start = vim.str_byteindex(self, idx)
-- local finish = vim.str_byteindex(self, idx + 1)
-- return self:sub(start + 1, finish)
--     return self:sub(idx, idx)
-- end
