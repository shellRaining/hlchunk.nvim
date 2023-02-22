local opts = {}

opts.config = {
    enabled = true,
    hlchunk_supported_files = { "*.ts", "*.js", "*.json", "*.go", "*.c", "*.cpp", "*.rs", "*.h", "*.hpp", "*.lua" },

    hl_chunk_chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    hlchunk_style = {
        chunk_style = {
            hibiscus = "#806d9c",
            primrose = "#c06f98",
        },
        indent_style = {
            hibiscus = "#806d9c",
            primrose = "#c06f98",
        },
    },
}

return opts
