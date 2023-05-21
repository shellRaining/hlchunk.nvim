local M = {}

M.support_filetype = {
    "*.ts",
    "*.tsx",
    "*.js",
    "*.jsx",
    "*.html",
    "*.json",
    "*.go",
    "*.c",
    "*.py",
    "*.cpp",
    "*.rs",
    "*.h",
    "*.hpp",
    "*.lua",
    "*.vue",
    "*.java",
}

M.exclude_filetype = {
    aerial = true,
    dashboard = true,
    help = true,
    lspinfo = true,
    lspsagafinder = true,
    packer = true,
    checkhealth = true,
    man = true,
    mason = true,
    NvimTree = true,
    ["neo-tree"] = true,
    plugin = true,
    lazy = true,
    TelescopePrompt = true,
    [""] = true, -- because TelescopePrompt will set a empty ft, so add this.
    alpha = true,
}

M.type_patterns = {
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
    "variable_declaration",
    "return",
}

return M
