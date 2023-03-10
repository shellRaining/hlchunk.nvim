-- Rerun tests only if their modification time changed.
cache = true
codes = true

exclude_files = {
    "tests/indent/lua/",
}

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
    "121", -- setting read-only global variable
    "212", -- Unused argument, In the case of callback function
    "411", -- Redefining a local variable.
    "412", -- Redefining an argument.
    "422", -- Shadowing an argument
    "122", -- Indirectly setting a readonly global
}

-- Global objects defined by the C code
read_globals = {
    "vim",
    "API",
    "FN",
    "PLUG_CONF",
    "TABLEX",
    "STRINGX",
    "UTILS",

    "SPACE_TAB",
    "CUR_LINE_NUM",
    "WIN_INFO",
    "CUR_CHUNK_RANGE",
    "ROWS_BLANK_LIST",
    "CUR_INDENT_RANGE",
}
