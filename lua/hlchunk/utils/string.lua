local mt = getmetatable("")

---@param self string
---@param sep? string
---@return string[]
mt.__index.split = function(self, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(self, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---@param self string
mt.__index.firstToUpper = function(self)
    return (self:gsub("^%l", string.upper))
end

-- get the char in a string at a given byte index, notice the base is 0, has an option to use utf8
---@param self string
---@param idx number
---@param options? {utf8: boolean}
mt.__index.at = function(self, idx, options)
    options = options or { utf8 = false }
    if options.utf8 then
        local utfBeg = vim.str_byteindex(self, idx) + 1
        local utfEnd = vim.str_byteindex(self, idx + 1)
        return self:sub(utfBeg, utfEnd)
    else
        return self:sub(idx, idx)
    end
end
