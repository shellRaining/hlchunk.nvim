local ffi = require("ffi")

ffi.cdef([[
    typedef struct {} Error;
    typedef struct file_buffer buf_T;
    typedef int32_t linenr_T;
    buf_T *find_buffer_by_handle(int buffer, Error *err);
    int get_indent_buf(buf_T *buf, linenr_T lnum);
    int get_sw_value(buf_T *buf);
]])
local C = ffi.C

local M = {}

---@param bufnr number
---@param row number 0-index
---@return number
function M.get_indent(bufnr, row)
    local line_cnt = vim.api.nvim_buf_line_count(bufnr)
    if row >= line_cnt then
        return -1
    end
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return C.get_indent_buf(handler, row + 1)
end

function M.get_sw(bufnr)
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return C.get_sw_value(handler)
end

return M
