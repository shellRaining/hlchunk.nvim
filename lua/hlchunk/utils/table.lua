local Array = {}


-- this is constructor of Array class
---@param self Array
---@param ... any
---@return Array
function Array:new(...)
    local o = {}
    local params_num = select("#", ...)

    if params_num == 1 then
        local arg1 = select(1, ...)
        if type(arg1) == "number" then
            for i = 1, tonumber(arg1) do
                o[i] = nil
            end
        else
            o[1] = arg1
        end
    elseif params_num > 1 then
        for i = 1, params_num do
            o[i] = select(i, ...)
        end
    end

    setmetatable(o, self)

    return o
end

function Array:size()
    local i = 0
    for _ in pairs(self) do
        i = i + 1
    end
    return i
end

-- execute a function for each element of a table
---@param f fun(k: any, v: any)
function Array:foreach(f)
    for k, v in pairs(self) do
        f(k, v)
    end
end

return Array
