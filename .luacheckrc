-- Rerun tests only if their modification time changed.
cache = true
codes = true

-- Glorious list of warnings: https://luacheck.readthedocs.io/en/stable/warnings.html
ignore = {
    "212/self", -- Unused argument, In the case of callback function
    "111/_"
}

-- Global objects defined by the C code
read_globals = {
    "vim",
}
