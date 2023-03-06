local opts = {}

-- #FF0000
-- #FF7F00
-- #FFFF00
-- #00FF00
-- #00FFFF
-- #0000FF
-- #8B00FF

opts.config = {
    chunk = {
        enable = true,
        -- settings for this plugin
        support_filetypes = {
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
        },
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

    -- settings for hl_indent
    indent = {
        enable = true,
        use_treesitter = false,
        chars = {
            "│",
        },
        style = {
            vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
        },
        exclude_filetype = {
            dashboard = true,
            help = true,
            lspinfo = true,
            packer = true,
            checkhealth = true,
            man = true,
            mason = true,
            NvimTree = true,
            plugin = true,
        },
    },

    -- settings for hl_line_num
    line_num = {
        enable = true,
        support_filetypes = {
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
        },
        style = "#806d9c",
    },
}

return opts
