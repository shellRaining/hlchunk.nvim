<h1 align="center">hlchunk.nvim</h1>

<p align='center'>
<b>English</b> | <a href="https://github.com/shell-Raining/hlchunk.nvim/blob/main/README.zh-CN.md">简体中文</a>
</p>

This is the lua implementation of [nvim-hlchunk](https://github.com/yaocccc/nvim-hlchunk), and add some new features like highlighting indentline, specially thanks [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim), during the process of writing this plugin, this repo provided a lot of help and inspiration for me

## brief

this plugin have two parts,

1. hl_chunk
2. hl_indent

the first one is to highlight the current chunk, a chunk is defined as `the closest pair of curly braces and the code in between`, so it might not work very well in lua or python source code. In the future, I might define a chunk by using indentation (so, this plugin may become another `indent_blankline` in the future, laugh)

the second one is to highlight indentline like `indent_blankline`

## example

<img width="700" alt="image" src="https://raw.githubusercontent.com/shell-Raining/img/main/2302/23_hlchunk1.png">
<img width="700" alt="image" src="https://raw.githubusercontent.com/shell-Raining/img/main/2302/23_hlchunk2.png">

## Requirements

neovim version `>= 0.7.0` (maybe, just test at this version)

## Installation

### Packer

```lua
use { "shell-Raining/hlchunk.nvim" }

```

### Plug

```lua
Plug "shell-Raining/hlchunk.nvim"
```

## Setup

The script comes with the following defaults:

```lua
{
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

        enable_hl_line_num = true,
        hl_line_num_style = {
            hibiscus = "#806d9c",
        },
    },

    -- settings for hl_indent
    hl_indent = {
        enable = true,
        chars = {
            vertical_line = "│",
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
        },
    },
}
```

To override the custom configuration, call:

```lua
require('hlchunk').setup({
  -- your override config
})
```

example:

```lua
require('hlchunk').setup({
    -- when overide the config, enable option must be contained
    enabled = true,

    hl_indent = {
        enable = true,
        style = {
            "#FF0000",
            "#FF7F00",
            "#FFFF00",
            "#00FF00",
            "#00FFFF",
            "#0000FF",
            "#8B00FF",
        },
    },
})
```

## command

this plugin provides some commands to switch plugin status, which are listed below

- EnableHL
- DisableHL

the two commands are used to switch the whole plugin status, when use `DisableHL`, include `hl_chunk` and `hl_indent` will be disable

- DisableHLChunk
- EnableHLChunk

the two will control `hl_chunk`

- DisableHLIndent
- EnableHLIndent

the two will control `hl_indent`
