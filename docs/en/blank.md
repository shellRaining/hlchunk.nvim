# how to configure blank mod

## Configurable items

blank have four configurable items

1. enable
2. notify
3. chars
4. style
5. exclude_filetype

`enable` is used to control whether enable hl_blank, if set it to false, its usercmd and autocmd will not set, so it will not work

`notify` same as chunk mod

`chars` is used to configure what char to render the blank, it is a table contains many char, like this

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

`style` is a RGB string or RGB string list, if it is a table, it will choice different color to render different blank (indent)

`exclude_filetype` is opposite of support_filetypes, it is a lua table like this, same as chunk mod

```lua
exclude_filetype = {
    aerial = true,
    NvimTree = true,
}
```

## example

below is the default style of blank

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

you can also set it like rainbow

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

it also can configure use multiple chars

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

at last, it can set background color

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
