# blank

## blank 可以用来做什么

我们代码的缩进一般是由空格或者 tab 组成的，因此可以在这些空位上动一些手脚，比如添加特殊字符表示这是一个空格，或者添加背景颜色，做出彩虹的效果。这个 mod 实质上继承自 indent，重写了 render 方法而已。

## 配置项

由于继承自 indent，他们的配置几乎相似和通用。blank mod 的默认配置如下：

```lua
local default_conf = {
    priority = 9,
    chars = { "․" },
}
```

`chars` 是一个 lua 表，其中的字符用来指示如何渲染 blank 字符，你可以设置为下面这样，来循环使用这些字符（尽管这样设置并不会很好看）：

```lua
chars = {
    " ",
    "․",
    "⁚",
    "⁖",
    "⁘",
    "⁙",
},
```

`style` 继承自 indent，因此和 indent 的颜色实际上是一样的，并且配置方式一样。详情见 [indent](./indent.md)

## example

下面是默认的 blank 样式

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/12_hlblank_default.png">

```lua
blank = {
    chars = {
        "․",
    },
    style = {
        { vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"), "" },
    },
},
```

你也可以将空格设置的像是彩虹一般 🌈

![screenshot](https://github.com/shellRaining/hlchunk.nvim/assets/55068959/8c9cb644-cf1e-4fc9-adb8-33e12a4c7401)

```lua
blank = {
    enable = true,
    chars = {
        " ",
    },
    style = {
        { bg = "#434437" },
        { bg = "#2f4440" },
        { bg = "#433054" },
        { bg = "#284251" },
    },
},
```

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/07_hlchunk7.png">

```lua
indent = {
    chars = {
        "․",
    },
    style = {
        { vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"), "" },
        "#806d9c",
        "#c06f98",
    },
}
```

你也可以设置多种字符类型

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlblank1.png">

```lua
indent = {
    chars = {
            "․",
            "⁚",
            "⁖",
            "⁘",
            "⁙",
    },
    style = {
        "#666666",
        "#555555",
        "#444444",
    },
}
```

最后，他还可以设置背景颜色

<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2303/11_hlblank2.png'>

```lua
blank = {
    enable = true,
    chars = {
        " ",
    },
    style = {
        { bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("cursorline")), "bg", "gui") },
        { bg = "", fg = "" },
    },
}
```
