<div align='center'>
<p><img width='400px' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_logo_bg.png'></p>
</div>
<h1 align='center'>hlchunk.nvim</h1>

<p align='center'>
<a href="./README.md">English</a> | <b>简体中文</b>
</p>

## 这个插件可以做什么

和 [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) 类似，这个插件可以用来高亮缩进线,并且还可以根据当前光标所处的位置，高亮所在代码块.

## 插件性能

使用 `profile.nvim` 进行性能分析，所有实验均是在 macOS 上的 alacritty 进行，Neovim 窗口高度为 66 行，代码文件是 `typescript.js`，从首行开始，到五百行结束。平均每次渲染耗时 `0.7ms`

我做了很多工作来尽可能缩短渲染耗时

1. 异步渲染，减少卡顿
2. 使用 c 函数，加快部分函数调用
3. 尽可能缓存每行的 extmark，减少缩进计算
4. 使用节流函数来尽可能批处理渲染过程

如果你希望能够减少滚动窗口时候突如其来的卡顿感，也许你会喜欢上 `hlchunk.nvim`~

具体的优化工作你可以看我的博客 [https://www.shellraining.top/docs/tools/hlchunk/profile.html](https://www.shellraining.top/docs/tools/hlchunk/profile.html)

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
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2406/hlchunk_v121.gif">
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

neovim 版本 `>= 0.10.0`

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

你可以通过一个总的 setup 函数来进行配置：

```lua
require('hlchunk').setup({
    chunk = {
        enable = true
        -- ...
    },
    indent = {
        enable = true
        -- ...
    }
})
```

也可以通过引入单独的 mod 来启动：

```lua
local indent = require('hlchunk.mods.indent')
indent({
    style = {
        -- ...
    }
}):enable() -- 不要忘记加上 enable 来明确的表示启动
```

## 注意

由于内部采用 `shiftwidth()` 函数来获取缩进宽度，所以对于没有手动设定缩进宽度的文件，可能会出现不准确的情况，这时候你可以手动设置缩进宽度：

```lua
vim.bo.shiftwidth = xxx
```

如果你感觉这个过程很繁琐，可以尝试用 [guess-indent](https://github.com/nmac427/guess-indent.nvim) 或者 [indent-o-matic](https://github.com/Darazaki/indent-o-matic) 此类插件来自动获取缩进宽度。

## 用户指令

有时候（比如性能原因），你可能想要手动关闭某个 mod，可以遵循下面的规则：输入 `DisableHLxxxx`，其中把 `xxxx` 替换为你想要关闭的 mod 名称，比如关闭 `chunk`，你可以输入 `DisableHLchunk`。

同理开启某个 mod，输入 `EnableHLxxxx`。

不过对于在 `enable` 为 `false` 的 mod，插件本身不会为其创建一个 user command（因为没有必要）
