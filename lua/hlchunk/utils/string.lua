local stringx = {}

function stringx.split(s, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function stringx.firstToUpper(s)
    return (s:gsub("^%l", string.upper))
end

function stringx.at(s, idx)
    return s:sub(idx, idx)
end

---@param tbl string[]
---@param sep? string
function stringx.join(tbl, sep)
    sep = sep or ""
    local res = ""
    for _, value in pairs(tbl) do
        res = res .. value .. sep
    end
    return res
end

return stringx
