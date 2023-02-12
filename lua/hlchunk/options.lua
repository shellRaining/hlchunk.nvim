local opts = {}

local color_set = {
    hibiscus = "#806d9c",
    primrose = "#c06f98",
}

opts.config = {
    enabled = true,
    hlchunk_supported_files = { "*.ts,*.js,*.json,*.go,*.c,*.cpp,*.rs,*.h,*.hpp,*.lua" },
    hl_chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    hlchunk_hl_style = color_set.primrose,
}

opts.setup = function(params)
    opts.config = vim.tbl_extend("force", {}, opts.config, params or {})
end

return opts
