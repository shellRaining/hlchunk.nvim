local chunkHelper = {}

function chunkHelper.calc(str, col, leftcol)
    local len = vim.api.nvim_strwidth(str)
    if col < leftcol then
        local byte_idx = math.min(leftcol - col, len)
        local utf_beg = vim.str_byteindex(str, byte_idx)
        str = str:sub(utf_beg + 1)
    end

    col = math.max(col - leftcol, 0)

    return str, col
end

function chunkHelper.utf8Split(inputstr)
    local list = {}
    for uchar in string.gmatch(inputstr, "[^\128-\191][\128-\191]*") do
        table.insert(list, uchar)
    end
    return list
end

---@param i number
---@param j number
---@return table
function chunkHelper.rangeFromTo(i, j, step)
    local t = {}
    step = step or 1
    for x = i, j, step do
        table.insert(t, x)
    end
    return t
end

function chunkHelper.shallowCmp(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    local flag = true
    for i, v in ipairs(t1) do
        if t2[i] ~= v then
            flag = false
            break
        end
    end
    return flag
end

return chunkHelper
