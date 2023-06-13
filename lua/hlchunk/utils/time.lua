local M = {}

function M.run_and_time(f, ...)
    local start_time = os.time()
    local start_clock = os.clock()
    f(...)
    local end_clock = os.clock()
    local elapsed_clock = end_clock - start_clock
    local end_time = os.time()
    local elapsed_time_ms = (end_time - start_time) * 1000 + elapsed_clock * 1000 -- 计算运行时间并转换为毫秒
    local function_name = debug.getinfo(2, "n").name or "<anonymous>"
    vim.notify("Function " .. function_name .. " took " .. elapsed_time_ms .. " ms to run.")
end

return M
