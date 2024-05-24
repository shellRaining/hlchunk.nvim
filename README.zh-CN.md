<div align='center'>
<p><img width='400px' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_logo_bg.png'></p>
</div>
<h1 align='center'>hlchunk.nvim</h1>

<p align='center'>
<a href="./README.md">English</a> | <b>简体中文</b>
</p>

## 注意！！！

最近代码发生了很多变动。如果您遇到任何 bug，请随时提出 issue。我将在未来改进代码清晰度和文档。

## 这个插件可以做什么

和 [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) 类似，这个插件可以用来高亮缩进线,并且还可以根据当前光标所处的位置，高亮所在代码块.

## 简要概述

这个插件由四个部分组成

1. chunk
1. indent
1. line_num
1. blank

一张图搞懂这些功能分别是做什么的

<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_intro.png'>

## 详细展示

**注意：可以点击图片获取配置信息～**

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

neovim 版本 `>= 0.9.0`

## 安装（使用 lazy.nvim）

```lua
{
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({})
  end
},
```

## 配置

由于这个插件是由多个小部分组成，他们会有一些共同的配置项，如下所示：

```lua
local default_conf = {
    enable = false,
    style = {},
    notify = false,
    priority = 0,
    exclude_filetypes = {
        aerial = true,
        dashboard = true,
        -- some other filetypes
    }
}
```

1. enable: 用来控制某个 mod 是否启用
1. style：用来控制 mod 的样式，不同的 mod 会有不同的样式配置方式，具体可以看各自的文档
1. notify：用来控制某个 mod 是否显示提示信息（通过 notify 函数）
1. priority：用来控制某个 mod 的渲染优先级，优先级越高，显示的优先级越高，默认情况下 `chunk` > `indent` >  `blank` > `line_num`
1. exclude_filetypes：用来控制某个 mod 在某些文件类型下不启用

各个 mod 特定的配置方式可以查看各自的文档，链接如下：

- [chunk](./docs/zh_CN/chunk.md)
- [indent](./docs/zh_CN/indent.md)
- [line_num](./docs/zh_CN/line_num.md)
- [blank](./docs/zh_CN/blank.md)

## command

有时候（比如性能原因），你可能想要手动关闭某个 mod，可以遵循下面的规则：输入 `DisableHLxxxx`，其中把 `xxxx` 替换为你想要关闭的 mod 名称，比如关闭 `chunk`，你可以输入 `DisableHLchunk`。

同理开启某个 mod，输入 `EnableHLxxxx`。

不过对于在 `enable` 为 `false` 的 mod，插件本身不会为其创建一个 user command（因为没有必要）
