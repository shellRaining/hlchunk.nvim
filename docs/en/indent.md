# how to configure indent mod

## Configurable items

chunk have five configurable items

1. enable
2. notify
3. use_treesitter
4. chars
5. style
6. exclude_filetype

`enable` is used to control whether enable hl_indent, if set it to false, its usercmd and autocmd will not set, so it will not work

`notify` is used to control whether notify when some situation(like disable indent mod double time)

`use_treesitter` is a boolean value, if set it to true, this mod will judge indent by using treesitter

`chars` is used to configure what char to render the indent line, it is a table contains many char, like this

```lua
chars = {
    "│",
    "¦",
    "┆",
    "┊",
},
```

`style` is a RGB string or RGB string list, if it is a table, it will choice different color to render different indent line

`exclude_filetype` is opposite of support_filetypes, it is a lua table like this, the default exclude_filetypes can be found in the [default config](../../lua/hlchunk/utils/filetype.lua)

```lua
exclude_filetype = {
    aerial = true,
    NvimTree = true,
}
```

## example

below is the default style of indent line

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

you can also set it like rainbow 🌈

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

it also can configure use multiple chars

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

if you like bold line, you can set background color

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/13_hlindent_bg.png">

````lua
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
