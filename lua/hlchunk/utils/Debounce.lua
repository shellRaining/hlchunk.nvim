local uv = vim.uv or vim.loop

local Debounce = setmetatable({
    _timer = nil,
}, {
    __call = function(self)
        if not self._timer then
            self._timer = uv.new_timer()
        end
    end,
})

return Debounce
