local opts = {}

local exclude_ft = {
    dashboard = true,
    help = true,
    lspinfo = true,
    packer = true,
    checkhealth = true,
    man = true,
    mason = true,
    NvimTree = true,
    plugin = true,
}

local support_ft = {
    "*.ts",
    "*.js",
    "*.json",
    "*.go",
    "*.c",
    "*.cpp",
    "*.rs",
    "*.h",
    "*.hpp",
    "*.lua",
    "*.vue",
}

opts.config = {
    chunk = {
        enable = true,
        support_filetypes = support_ft,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = {
            hibiscus = "#806d9c",
            primrose = "#c06f98",
        },
    },

    indent = {
        enable = true,
        use_treesitter = false,
        chars = {
            "│",
        },
        style = {
            vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
        },
        exclude_filetype = exclude_ft,
    },

    line_num = {
        enable = true,
        style = "#806d9c",
        support_filetypes = support_ft,
    },

    blank = {
        enable = true,
        chars = {
            " ",
            -- "⁚",
            -- "⁖",
            -- "⁘",
            -- "⁙",
        },
        style = {
            { "", FN.synIDattr(FN.synIDtrans(FN.hlID("cursorline")), "bg", "gui") },
            { vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"), "" },
            -- "#806d9c",
            -- "#c06f98",
        },
        exclude_filetype = exclude_ft,
    },
}

return opts
