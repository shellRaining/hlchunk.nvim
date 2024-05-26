# blank

## what blank be used for

Our code indentation generally consists of spaces or tabs. Therefore, we can customize the blank spaces, such as adding special characters to indicate a space, or adding background colors to achieve rainbow effects. Essentially, this mod inherits from indent and only rewrites the render method.

## config

Since it inherits from indent, their configurations are almost similar and universal. The default configuration of the blank mod is as follows:

```lua
local default_conf = {
    priority = 9,
    chars = { "․" },
}
```

`chars` is a Lua table whose characters are used to indicate how to render blank characters. You can set it like this to use the characters cyclically (although this setting does not look very good):

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

`style` inherits from indent, so the color is actually the same as indent and the configuration method is the same. See indent for [details](./indent.md).

## example

Here is the default blank style:

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

You can also set the spaces to be like a rainbow 🌈

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

You can also set multiple character types.

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

Finally, it can also set background colors.

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
