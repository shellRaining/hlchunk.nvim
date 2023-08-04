<div align='center'>
<p><img width='400px' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_logo_bg.png'></p>
</div>
<h1 align='center'>hlchunk.nvim</h1>

<p align='center'>
<a href="https://github.com/shellRaining/hlchunk.nvim/blob/main/README.md">English</a> | <b>简体中文</b>
</p>

## 这个插件可以做什么

和 [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim) 类似,这个插件可以用来高亮缩进线,并且还可以根据当前光标所处的位置,高亮所在代码块.

## 这个插件优势在哪里

1. 更具有拓展型
2. 更快的渲染速度 (每千次渲染花费 0.04 秒, 行高 50 行情况下)
3. 维护更积极 (作者是个带学生, 有大把的时间来维护这个插件, 笑)

## 简要概述

这个插件由五个部分组成，未来会添加更多的功能（笑）

1. chunk
2. indent
3. line_num
4. blank
5. context (处于实验阶段)

一张图搞懂这些功能分别是做什么的

<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_intro.png'>

## 详细展示

<b><font color='red'>注意：可以点击图片获取配置信息～</font></b>

### chunk

<a href='./docs/zh_CN/chunk.md#chunk_gif'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlchunk8.gif">
</a>

### indent

<a href='./docs/zh_CN/indent.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk2.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/27_hlchunk4.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2305/01_indent.png">
</a>

### line_num

<a href='./docs/zh_CN/line_num.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">
</a>

### blank

<a href='./docs/zh_CN/blank.md'>
<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2303/11_hlblank2.png'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlblank1.png">
</a>

## 需求

neovim 版本 `>= 0.7.0`

## 安装

### Packer

```lua
use { "shellRaining/hlchunk.nvim" }

```

### Plug

```vimscript
call plug#begin()
Plug 'shellRaining/hlchunk.nvim'
call plug#end()

lua << EOF
require("hlchunk").setup({})
EOF
```

### Lazy

```lua
{
  "shellRaining/hlchunk.nvim",
  event = { "UIEnter" },
  config = function()
    require("hlchunk").setup({})
  end
},
```

## 设置

插件默认带有以下的配置

<details>
<summary>戳我获取更多信息</summary>

```lua
{
    chunk = {
        enable = true,
        notify = true, -- 在某些情况下弹出提示（比如连续两次使用 disableHLChunk 命令）
        exclude_filetypes = {
            aerial = true,
            dashboard = true,
        }
        support_filetypes = {
            "*.lua",
            "*.js",
        }
        use_treesitter = true,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = {
            { fg = "#806d9c" },
        },
    },

    indent = {
        enable = true,
        use_treesitter = false,
        chars = {
            "│",
        },
        style = {
            { fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") }
        },
    },

    line_num = {
        enable = true,
        use_treesitter = false,
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
    },
}
```

</details>

<hr>

配置文件像下面这样：

```lua
require('hlchunk').setup({
    indent = {
        chars = { "│", "¦", "┆", "┊", }, -- 更多的字符可以在 https://unicodeplus.com/ 这个网站上找到


        style = {
            "#8B00FF",
        },
    },
    blank = {
        enable = false,
    }
})
```

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
