# 怎样配置 hl_blank

## 配置项

blank mod 有四个配置项

1. enable
2. notify
3. chars
4. style
5. exclude_filetype

`enable` 是用来控制该 mod 是否启动的，如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

`notify` 是用来控制是否在某些情况下通知用户，比如禁用 blank mod 两次

`chars` 是一个 lua 表，其中的字符用来指示如何渲染 blank 字符

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

`style` 是一个 RGB 字符串或者一个表，如果是表，他将会使用不同颜色来渲染 blank

`exclude_filetype` 是 support_filetype 的反面，用来控制在哪些文件类型不渲染 blank，默认的 exclude_filetypes 可以在 [default config](../../lua/hlchunk/utils/filetype.lua) 中找到

```lua
exclude_filetype = {
    aerial = true,
    NvimTree = true,
}
```

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
