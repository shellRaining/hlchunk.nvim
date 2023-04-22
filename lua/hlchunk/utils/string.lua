---@param self string
---@param sep? string
---@return string[]
function string:split(sep)
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
function string:firstToUpper()
    return (self:gsub("^%l", string.upper))
end

-- get the char in a string at a given byte index, notice the base is 0, has an option to use utf8
---@param self string
---@param idx number
---@param options? {utf8: boolean}
function string:at(idx, options)
    options = options or { utf8 = false }
    if options.utf8 then
        local utfBeg = vim.str_byteindex(self, idx) + 1
        local utfEnd = vim.str_byteindex(self, idx + 1)
        return self:sub(utfBeg, utfEnd)
    else
        return self:sub(idx, idx)
    end
end

-- trim the blank of a string
---@param self string
---@return string
function string:trim()
    return self:match("^%s*(.-)%s*$")
end
