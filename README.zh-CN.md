<h1 align="center">hlchunk.nvim</h1>

<p align='center'>
<a href="https://github.com/shellRaining/hlchunk.nvim/blob/main/README.md">English</a> | <b>简体中文</b>
</p>

这是 [nvim-hlchunk](https://github.com/yaocccc/nvim-hlchunk) 的一个 lua 实现，并且添加了例如缩进高亮的功能，本项目特别感谢 [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)，在我编写这个插件的时候，这个仓库给我提供了很多帮助和灵感

## 简要概述

这个插件由四个部分组成，未来会添加更多的功能（笑）

1. hl_chunk
2. hl_indent
3. hl_line_num
4. hl_blank

第一部分是用来高亮当前代码块，在本项目中代码块的定义是当前光标所处位置最近的一对括号及其中间的代码段，所以这个插件可能不是很适合 lua 和 python 代码。在未来我会用缩进来定义一个代码块（所以这个项目未来可能会变成类似 `indent_blankline` 的项目 😊）

第二部分是用来高亮缩进，就像是 `indent_blankline` 一样，这个功能可以选择基于 treesitter 或者是空格个数来进行渲染。treesitter 的优点是非常精确，但是可能速度上比较慢，而且有些不支持缩进的文件类型，比如 markdown，如果选择基于空格个数的渲染，速度上会有优势，但是在某些特殊情况下可能渲染不精确，如下所示

<img width="400" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/01_hlchunk5.png">

基于空格个数的渲染

<img width="400" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/01_hlchunk6.png">

基于 treesitter 的渲染

第三部分和 hl_chunk 的功能差不多，唯一不同之处在于他高亮的部分是行号而不是编辑器的内容，你可以设置行号的前景颜色和背景颜色

第四部分是用来将空格使用你指定的字符来进行填充的，你可以指定很多有趣的图标和样式，下面这网站中你可以找到很多这样的图标 [Unicode Plus](https://unicodeplus.com/)

## 例子

<b><font color='red'>注意：可以点击图片获取配置信息～</font></b>

<a href='./docs/zh_CN/chunk.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlchunk8.gif">
</a>

### hl_indent

<a href='./docs/zh_CN/indent.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk2.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/27_hlchunk4.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/13_hlindent_bg.png">
</a>

### hl_line_num

<a href='./docs/zh_CN/line_num.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">
</a>

### hl_blank

<a href='./docs/zh_CN/blank.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlblank1.png">
<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2303/11_hlblank2.png'>
</a>

## 需求

neovim 版本 `>= 0.7.0` (也许，因为我是在这个版本的 neovim 中编写的)

## 安装

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

## 设置

插件默认带有以下的配置

<details>
<summary>戳我获取更多信息</summary>

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
            FN.synIDattr(FN.synIDtrans(FN.hlID("Whitespace")), "fg", "gui"),
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

配置文件像下面这样：

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
<hr>

## command

<details>
<summary>戳我获取更多信息</summary>

这个插件还提供了一些命令用来打开和关闭插件

- EnableHL
- DisableHL

下面这两个命令用来控制 `hl_chunk` 的状态

- DisableHLChunk
- EnableHLChunk

下面这两个命令用来控制 `hl_indent` 的状态

- DisableHLIndent
- EnableHLIndent

下面这两个命令用来控制 `hl_blank` 的状态

- DisableHLBlank
- EnableHLBlank

</details>
