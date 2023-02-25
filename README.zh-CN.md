<h1 align="center">hlchunk.nvim</h1>

<p align='center'>
<a href="https://github.com/shell-Raining/hlchunk.nvim/blob/main/README.md">English</a> | <b>简体中文</b>
</p>

这是 [nvim-hlchunk](https://github.com/yaocccc/nvim-hlchunk) 的一个 lua 实现，并且添加了例如缩进高亮的功能，本项目特别感谢 [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)，在我编写这个插件的时候，这个仓库给我提供了很多帮助和灵感

## 简要概述

这个插件由两个部分组成

1. hl_chunk
2. hl_indent
3. hl_line_num

第一部分是用来高亮当前代码块，在本项目中代码块的定义是当前光标所处位置最近的一对括号及其中间的代码段，所以这个插件可能不是很适合 lua 和 python 代码。在未来我会用缩进来定义一个代码块（所以这个项目未来可能会变成类似 `indent_blankline` 的项目（笑））

第二部分是用来高亮缩进，就像是 `indent_blankline` 一样

第三部分和 hl_chunk 的功能差不多，唯一不同之处在于他高亮的部分是行号而不是编辑器的内容，你可以设置行号的前景颜色和背景颜色

## 例子

<img width="700" alt="image" src="https://raw.githubusercontent.com/shell-Raining/img/main/2302/23_hlchunk1.png">
<img width="700" alt="image" src="https://raw.githubusercontent.com/shell-Raining/img/main/2302/23_hlchunk2.png">
<img width="700" alt="image" src="https://raw.githubusercontent.com/shell-Raining/img/main/2302/25_hlchunk3.png">

## 需求

neovim 版本 `>= 0.7.0` (也许，因为我是在这个版本的 neovim 中编写的)

## 安装

### Packer

```lua
use { "shell-Raining/hlchunk.nvim" }

```

### Plug

```lua
Plug "shell-Raining/hlchunk.nvim"
```

## 设置

插件默认带有以下的配置

```lua
{    -- settings for this plugin
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

    -- settings for hl_line_num
    hl_line_num = {
        enable = true,

        style = {
            hibiscus = "#806d9c",
        },
    },
}
```

修改默认的配置请调用：

```lua
require('hlchunk').setup({
  -- your override config
})
```

例如这样：

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

这个插件还提供了一些命令用来打开和关闭插件

- EnableHL
- DisableHL

下面这两个命令用来控制 `hl_chunk` 的状态

- DisableHLChunk
- EnableHLChunk

下面这两个命令用来控制 `hl_indent` 的状态

- DisableHLIndent
- EnableHLIndent
