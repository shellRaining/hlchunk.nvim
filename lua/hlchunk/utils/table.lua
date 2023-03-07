local tablex = {}

--- total number of elements in this table.
-- Note that this is distinct from `#t`, which is the number
-- of values in the array part; this value will always
-- be greater or equal. The difference gives the size of
-- the hash part, for practical purposes. Works for any
-- object with a __pairs metamethod.
-- @tab t a table
-- @return the size, if t is not a table, return 0
function tablex.size(t)
    if type(t) ~= "table" then
        return 0
    end
    local i = 0
    for _ in pairs(t) do
        i = i + 1
    end
    return i
end

return tablex
