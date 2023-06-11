# 如何设置 hl_indent

## 配置项

indent mod 有五个配置项

1. enable
2. notify
3. use_treesitter
4. chars
5. style
6. exclude_filetype

`enable` 是用来控制该 mod 是否启动的，如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

`notify` 是用来控制是否在某些情况下通知用户，比如禁用 indent mod 两次

`use_treesitter` 是一个布尔类型，如果设置为 false，将不会采用基于 treesitter 的渲染

`chars` 是一个 lua 表，其中的字符用来指示如何渲染 indent line，这个表中包含五个部分

```lua
chars = {
    "│",
    "¦",
    "┆",
    "┊",
},
```

`style` 是一个 RGB 字符串或者一个表，如果是表，他将会使用不同颜色来渲染 indent line

`exclude_filetype` 是 support_filetype 的反面，用来控制在哪些文件类型不渲染 indent line，默认的 exclude_filetypes 可以在 [default config](../../lua/hlchunk/utils/filetype.lua) 中找到

```lua
exclude_filetype = {
    aerial = true,
    NvimTree = true,
}
```

## example

下面是默认的 indent 样式

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk1.png">

```lua
indent = {
    chars = {
        "│",
    },
    style = {
        vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
    },
}
```

你也可以将缩进线设置的像是彩虹一般 🌈

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk2.png">

```lua
indent = {
    chars = {
        "│",
    },
    style = {
        "#FF0000",
        "#FF7F00",
        "#FFFF00",
        "#00FF00",
        "#00FFFF",
        "#0000FF",
        "#8B00FF",
    },
}
```

你也可以设置多种字符类型

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/01_hlchunk5.png">

```lua
indent = {
    chars = {
        "│",
        "¦",
        "┆",
        "┊",
    },
    style = {
        vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
    },
}
```

如果你喜欢更粗的显示效果，你可以设置渲染的背景颜色

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/13_hlindent_bg.png">

```lua
indent = {
    enable = true,
    use_treesitter = false,
    chars = {
        " ",
    },
    style = {
        { bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui") },
    },
    exclude_filetype = exclude_ft,
}
```
