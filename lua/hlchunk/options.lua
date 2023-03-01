local opts = {}

-- #FF0000
-- #FF7F00
-- #FFFF00
-- #00FF00
-- #00FFFF
-- #0000FF
-- #8B00FF

opts.config = {
    -- settings for this plugin
    enabled = true,
    hlchunk_supported_files = { "*.ts", "*.js", "*.json", "*.go", "*.c", "*.cpp", "*.rs", "*.h", "*.hpp", "*.lua" },

    -- setttings for hl_chunk

    hl_chunk = {
        enable = true,
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
    hl_indent = {
        enable = true,
        use_treesitter = false,
        chars = {
            vertical_line1 = "│",
            vertical_line2 = "¦",
            vertical_line3 = "┆",
            vertical_line4 = "┊",
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
        },
    },

    -- settings for hl_line_num
    hl_line_num = {
        enable = true,

        style = {
            violet = "#806d9c",
        },
    },
}

return opts
