local ffi = require("ffi")

ffi.cdef([[
    typedef struct {} Error;
    typedef int colnr_T;
    typedef struct file_buffer buf_T;
    typedef int32_t linenr_T;
    buf_T *find_buffer_by_handle(int buffer, Error *err);
    int get_indent_buf(buf_T *buf, linenr_T lnum); // fn.indent
    int get_sw_value(buf_T *buf); // fn.shiftwidth
    char *ml_get_buf(buf_T *buf, linenr_T lnum); // fn.getbufline
    colnr_T ml_get_buf_len(buf_T *buf, linenr_T lnum); // #fn.getbufline

    // string utils
    char *skipwhite(const char *p);
]])
local C = ffi.C

local M = {}

---@param bufnr number
---@param lnum number 0-index
---@return number
function M.get_indent(bufnr, lnum)
    local line_cnt = vim.api.nvim_buf_line_count(bufnr)
    if lnum >= line_cnt or lnum <= 0 then
        return -1
    end
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return C.get_indent_buf(handler, lnum + 1)
end

function M.get_sw(bufnr)
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return C.get_sw_value(handler)
end

---@param bufnr number
---@param lnum number 0-index
---@return string
function M.get_line(bufnr, lnum)
    local line_cnt = vim.api.nvim_buf_line_count(bufnr)
    if lnum >= line_cnt or lnum <= 0 then
        return ""
    end
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return ffi.string(C.ml_get_buf(handler, lnum + 1))
end

---@param bufnr number
---@param lnum number 0-index
---@return number
function M.get_line_len(bufnr, lnum)
    local line_cnt = vim.api.nvim_buf_line_count(bufnr)
    if lnum >= line_cnt or lnum <= 0 then
        return 0
    end
    local handler = C.find_buffer_by_handle(bufnr, ffi.new("Error"))
    return C.ml_get_buf_len(handler, lnum + 1)
end

---return the first non-white character in the string, or '' if the string is empty or contains only white characters
---@param s string
---@return string
function M.skipwhite(s)
    local c = ffi.string(C.skipwhite(s), 1)
    return c == "\0" and "" or c
end

return M
