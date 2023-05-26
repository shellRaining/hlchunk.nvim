local M = {}

---@param beg_row? number
---@param end_row? number
function M.is_same_context(beg_row, end_row)
    if M.beg_row == beg_row and M.end_row == end_row then
        return true
    else
        M.beg_row, M.end_row = beg_row, end_row
        return false
    end
end

function M.clear_context()
    M.beg_row, M.end_row = nil, nil
end

return M
