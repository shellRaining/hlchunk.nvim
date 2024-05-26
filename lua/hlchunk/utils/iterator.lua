local M = {}

---@param arr table
---@return number
local function arrLen(arr)
    local len = 0
    for _ in pairs(arr) do
        len = len + 1
    end
    return len
end

---@generic T
---@param array T[]
---@param limit? number limit the number of elements to iterate, default not limited
---@param cycle? boolean whether to cycle the array, default false
---@return fun():number, T
function M.array2iter(array, limit, cycle)
    local default_limit = -1
    limit = limit or default_limit
    cycle = cycle or false

    local idx = 0
    local i = 0
    local len = arrLen(array)

    if len == 0 and cycle then
        return function()
            return nil, nil
        end
    end
    return function()
        idx = idx + 1
        i = i + 1
        if idx > len then
            if cycle then
                idx = 1
            else
                return nil
            end
        end

        if limit ~= default_limit and i > limit then
            return nil
        end

        return idx, array[idx]
    end
end

return M
