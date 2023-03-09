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

return stringx
