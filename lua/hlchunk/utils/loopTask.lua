---@diagnostic disable: inject-field
local class = require("hlchunk.utils.class")
local setTimeout = require("hlchunk.utils.timer").setTimeout

---@param matrix table<number, table<number>> matrix that needs to be transposed
---@return table<number, table<number>> transposed matrix
---EXAMPLE: if the input matrix is `{{1, 2, 3}, {4, 5, 6}}`, then the output matrix will be `{{1, 4}, {2, 5}, {3, 6}}`
---not change the original matrix
local function transpose(matrix)
    local res = {}
    for i = 1, #matrix[1] do
        res[i] = {}
        for j = 1, #matrix do
            res[i][j] = matrix[j][i]
        end
    end
    return res
end

---@param total_time number total time in milliseconds
---@param step_num number how many steps to take, also represent the len of return table
---@return table<number> table of numbers that represent the time intervals
---EXAMPLE: if you choose a linear strategy, and the total_time is 1000ms, and the step_num is 10, then this function will return  `[100, 100, 100, 100, 100, 100, 100, 100, 100, 100]`
local function linearStrategy(total_time, step_num)
    local res = {}
    for _ = 1, step_num do
        table.insert(res, total_time / step_num)
    end
    return res
end

local function createStrategy(name, total_time, step_num)
    if name == "linear" then
        return linearStrategy(total_time, step_num)
    end
end

---@class HlChunk.LoopTask
---@field private timer uv_timer_t | nil uv_timer_t object from the LuaJIT runtime
---@field private fn function function that will be executed when the timer fires
---@field private data table table that contains any data that needs to be passed to the function
---@field private strategy string string that determines how the function is executed when the timer fires
---@field private time_intervals table<number> table of numbers that represent the time intervals
---@field progress number number that represents the current progress of the timer
---@field public start fun(self: HlChunk.LoopTask):nil function that starts the timer
---@field public stop fun(self: HlChunk.LoopTask):nil function that stops the timer
---@overload fun(fn: function, strategy: string, duration: number, ...: any):HlChunk.LoopTask
local LoopTask = class(function(self, fn, strategy, duration, ...)
    self.data = transpose({ ... })
    self.timer = nil
    self.fn = fn
    self.strategy = strategy
    self.time_intervals = createStrategy(strategy, duration, #self.data)
    self.progress = 1
end)
function LoopTask:start()
    if self.timer or #self.data == 0 then
        return
    end

    local f
    f = function()
        self.fn(unpack(self.data[self.progress]))
        self.progress = self.progress + 1
        if self.progress > #self.time_intervals then
            if self.timer then
                self.timer:stop() -- TODO: why self.timer could be nil
            end
            self.timer = nil
            return
        else
            self.timer = setTimeout(f, self.time_intervals[self.progress])
            if not self.timer then
                self:stop()
                return
            end
        end
    end
    self.timer = setTimeout(f, self.time_intervals[self.progress])
    if not self.timer then
        self:stop()
        return
    end
end
function LoopTask:stop()
    if self.timer then
        self.timer:stop()
        self.timer = nil
    end
end

return LoopTask
