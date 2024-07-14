local M = {}

M.cpp = require("hlchunk.utils.ts_node_type.cpp")
M.css = require("hlchunk.utils.ts_node_type.css")
M.lua = require("hlchunk.utils.ts_node_type.lua")
M.rust = require("hlchunk.utils.ts_node_type.rust")
M.yaml = require("hlchunk.utils.ts_node_type.yaml")
M.zig = require("hlchunk.utils.ts_node_type.zig")
M.default = {
    "class",
    "^func",
    "method",
    "^if",
    "else",
    "while",
    "for",
    "with",
    "try",
    "except",
    "match",
    "arguments",
    "argument_list",
    "object",
    "dictionary",
    "element",
    "table",
    "tuple",
    "do_block",
    "return",
}

return M
