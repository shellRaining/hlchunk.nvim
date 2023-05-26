local M = {}
local animations = {}
animations.running = false

function M.get_running()
    return animations.running
end

---@param flag? boolean
function M.set_running(flag)
    animations.running = flag
end

return M
