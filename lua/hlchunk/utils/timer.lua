local M = {}
local uv = vim.loop

function M.setTimeout(fn, delay, ...)
    local timer = uv.new_timer()
    local arg = { ... }
    timer:start(delay, 0, function()
        vim.schedule(function()
            fn(unpack(arg))
        end)
    end)
    return timer
end

function M.setInterval(fn, interval, ...)
    local timer = uv.new_timer()
    local arg = { ... }
    timer:start(interval, interval, function()
        vim.schedule(function()
            fn(unpack(arg))
        end)
    end)
    return timer
end

return M
