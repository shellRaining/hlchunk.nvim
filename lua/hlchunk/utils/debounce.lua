local M = {}
local setTimeout = require("hlchunk.utils.timer").setTimeout

function M.debounce(fn, delay)
    ---@type uv_timer_t | nil
    local timer = nil
    return function(...)
        local args = { ... }
        if timer then
            timer:stop()
        end
        timer = setTimeout(function()
            fn(unpack(args))
        end, delay)
    end
end

return M
