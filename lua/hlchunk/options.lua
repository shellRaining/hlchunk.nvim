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
    lazy = true,
    TelescopePrompt = true,
    [""] = true, -- because TelescopePrompt will set a empty ft, so add this.
}

local support_ft = {
    "*.ts",
    "*.tsx",
    "*.js",
    "*.jsx",
    "*.html",
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

local whitespaceStyle = FN.synIDattr(FN.synIDtrans(FN.hlID("Whitespace")), "fg", "gui")
-- local cursorlineStyle = FN.synIDattr(FN.synIDtrans(FN.hlID("cursorline")), "bg", "gui")

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
            { whitespaceStyle, "" },
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
            "․",
        },
        style = {
            -- { "", cursorline },
            { whitespaceStyle, "" },
        },
        exclude_filetype = exclude_ft,
    },

    context = {
        enable = false,
        use_treesitter = false,
        chars = {
            "┃", -- Box Drawings Heavy Vertical
        },
        style = {
            { "#806d9c", "" },
        },
        exclude_filetype = exclude_ft,
    },
}

return opts
