local api = vim.api
local ani_manager = require('hlchunk.utils.animation_manager')
local M = {}
M.sleep = 20

---@param ns_id? number
---@param opts?  table
---@param len?   number
function M.start_draw(ns_id, opts, len)
    M:stop_draw()
    M.timer = vim.loop.new_timer()
    M.index = 1

    M.timer:start(M.sleep, M.sleep, vim.schedule_wrap(function()
        local row_opts = {
            virt_text_pos = "overlay",
            hl_mode = "combine",
            priority = 100,
        }

        row_opts.virt_text = { { opts.virt_text[M.index], "HLChunk1" } }
        row_opts.virt_text_win_col = opts.offset[M.index]

        api.nvim_buf_set_extmark(0, ns_id, opts.line_num[M.index] - 1, 0, row_opts)

        M.index = M.index + 1
        if M.index == len then
            M:stop_draw()
            ani_manager.set_running(false)
        end
    end))
end

function M.stop_draw()
    if M.timer ~= nil then
        M.timer:close()
        M.timer = nil
    end
end

return M
