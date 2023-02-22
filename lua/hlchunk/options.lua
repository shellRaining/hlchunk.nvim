local opts = {}

local indent_default_style = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui")

opts.config = {
    -- settings for this plugin
    enabled = true,
    hlchunk_supported_files = { "*.ts", "*.js", "*.json", "*.go", "*.c", "*.cpp", "*.rs", "*.h", "*.hpp", "*.lua" },

    -- setttings for hl_chunk
    hl_chunk_chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    chunk_style = {
        hibiscus = "#806d9c",
        primrose = "#c06f98",
    },

    -- settings for hl_indent
    -- NOTE: because to tranverse a table in lua is not ordered, so use string as key is not good i think
    hl_indent_chars = {
        vertical_line = "│",
    },
    indent_style = {
        indent_default_style,
        "#806d9c",
        "#c06f98",
    },
}

return opts
