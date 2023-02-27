local tablex = {}

--- copy a table into another, in-place.
-- @within Copying
-- @tab t1 destination table
-- @tab t2 source (actually any iterable object)
-- @return first table
function tablex.update(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
    return t1
end

--- total number of elements in this table.
-- Note that this is distinct from `#t`, which is the number
-- of values in the array part; this value will always
-- be greater or equal. The difference gives the size of
-- the hash part, for practical purposes. Works for any
-- object with a __pairs metamethod.
-- @tab t a table
-- @return the size
function tablex.size(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
    end
    return i
end

return tablex
