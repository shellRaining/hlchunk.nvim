<h1 align="center">hlchunk.nvim</h1>

<p align='center'>
<b>English</b> | <a href="https://github.com/shellRaining/hlchunk.nvim/blob/main/README.zh-CN.md">简体中文</a>
</p>

This is the lua implementation of [nvim-hlchunk](https://github.com/yaocccc/nvim-hlchunk), and add some new features like highlighting indentline, specially thanks [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim), during the process of writing this plugin, this repo provided a lot of help and inspiration for me

## brief

this plugin now have four parts (future will add more... `^v^`)

1. hl_chunk
2. hl_indent
3. hl_line_num
4. hl_blank

the first one is to highlight the current chunk, a chunk is defined as `the closest pair of curly braces and the code in between`, so it might not work very well in lua or python source code. In the future, I might define a chunk by using indentation (so, this plugin may become another `indent_blankline` in the future 😊)

the second one is to highlight indentline like `indent_blankline`, you can choose a different indent render mode, one is base treesitter, another is base on the number of blank. the advantage of treeitter is that it is very accurate, but it may have low performance, and doesn't support some filetype, such as markdown, if you choose the latter mode, it will render faster (maybe), but will have some issues in particular situation, example below.

<img width="400" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/01_hlchunk5.png">

base on blank number

<img width="400" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/01_hlchunk6.png">

base on treesitter

the third one is similar to hl_chunk, the difference is that it will highlight line number, you can set front color or background color for it

the last one is hl_blank, which can highlight the blank with some funny char and style, you can see in the example below, you can find many useful chars in this website [Unicode Plus](https://unicodeplus.com/)

## example

<b><font color='red'> NOTE: you can click the picture to get more information about how to configure like this </font></b>

### hl_chunk

<a href='./docs/en/chunk.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlchunk8.gif">
</a>

### hl_indent

<a href='./docs/en/indent.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk2.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/27_hlchunk4.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/13_hlindent_bg.png">
</a>

### hl_line_num

<a href='./docs/en/line_num.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">
</a>

### hl_blank

<a href='./docs/en/blank.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlblank1.png">
<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2303/11_hlblank2.png'>
</a>

## Requirements

neovim version `>= 0.7.0` (maybe, just test at this version)

## Installation

### Packer

```lua
use { "shellRaining/hlchunk.nvim" }
```

### Plug

```lua
Plug "shellRaining/hlchunk.nvim"
```

### Lazy

```lua
{ "shellRaining/hlchunk.nvim", event = { "UIEnter" }, },
```

## Setup

The script comes with the following defaults:

<details>
<summary>Click this Dropdown to see defaults setttings.</summary>

```lua
{
    chunk = {
        enable = true,
        support_filetypes = {
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
        },
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = "#00ffff",
    },

    indent = {
        enable = true,
        use_treesitter = false,
        -- You can uncomment to get more indented line look like
        chars = {
            "│",
        },
        -- you can uncomment to get more indented line style
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

    line_num = {
        enable = true,
        support_filetypes = {
            "..."
        },
        style = "#806d9c",
    },

    blank = {
        enable = true,
        chars = {
            "․",
        },
        style = {
            vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
        },
        exclude_filetype = "...",
    },
}
```

<hr>

example:

```lua
require('hlchunk').setup({
    indent = {
        chars = { "│", "¦", "┆", "┊", },

        style = {
            "#8B00FF",
        },
    },
})
```

</details>

## command

<details>
<summary>Click this Dropdown to see Available Commands</summary>

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

- DisableHLLineNum
- EnableHLLineNum

the two will control `hl_line_num`

- DisableHLBlank
- EnableHLBlank

the two will control `hl_blank`

</details>
