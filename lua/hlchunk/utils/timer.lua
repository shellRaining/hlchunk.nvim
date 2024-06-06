local M = {}
local new_timer = vim.uv.new_timer

---@param fn function The function to be called after the delay
---@param delay number The delay in milliseconds
---@vararg any The arguments to be passed to the function
---@return uv_timer_t | nil
function M.setTimeout(fn, delay, ...)
    local timer = new_timer() --[[@as uv_timer_t | nil]]
    if not timer then
        return nil
    end
    local arg = { ... }
    timer:start(delay, 0, function()
        vim.schedule(function()
            fn(unpack(arg))
        end)
    end)
    return timer
end

---@param fn function The function to be called after the interval
---@param interval number The interval in milliseconds
---@vararg any The arguments to be passed to the function
---@return uv_timer_t | nil
function M.setInterval(fn, interval, ...)
    local timer = new_timer() --[[@as uv_timer_t | nil]]
    if not timer then
        return nil
    end
    local arg = { ... }
    timer:start(interval, interval, function()
        vim.schedule(function()
            fn(unpack(arg))
        end)
    end)
    return timer
end

---@param fn function
---@param delay integer The delay in milliseconds
---@return function
function M.debounce(fn, delay)
    ---@type uv_timer_t | nil
    local timer = nil
    return function(...)
        if timer then
            timer:stop()
        end
        timer = M.setTimeout(fn, delay, ...)
    end
end

---throttle function, assume we call a throttled func every 300ms for 9 times, and interval set to 1000ms
---then will actually call 3 times, and timeline as follow:
---`0ms` 300ms 600ms 900ms call throttled func, 0ms will tigger the timer, other 3 will be ignored
---1000ms actually call throttled func
---`1200ms` 1500ms 1800ms 2100ms call throttled func, 1200ms will tigger the timer, other 3 will be ignored
---2200ms actually call throttled func
---`2400ms` trigger the last call, then 3400ms actually call throttled func
--- | 0ms  | 300ms | 600ms | 900ms | 1000ms | 1200ms | 1500ms | 1800ms | 2100ms | 2200ms | 2400ms | 3400ms |
--- | ---- | ----- | ----- | ----- | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
--- | call | ignore| ignore| ignore| execute| call   | ignore | ignore | ignore | execute| call   | execute|
---@param fn any
---@param interval any
---@return function
function M.throttle(fn, interval)
    local timer = nil
    return function(...)
        local args = { ... }
        if timer then
            return
        end

        timer = M.setTimeout(function()
            fn(unpack(args))
            timer = nil
        end, interval)
    end
end

return M
