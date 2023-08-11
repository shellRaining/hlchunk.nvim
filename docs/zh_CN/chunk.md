# chunk

## chunk 用来做什么

是用来高亮当前光标所处代码块。

# 怎样配置 chunk

## 配置项

chunk mod 有四个配置项

1. enable
2. notify
3. use_treesitter
4. exclude_filetypes
5. support_filetypes
6. chars
7. style
8. max_file_size
9. error_sign

`enable` 是用来控制该 mod 是否启动的，默认为 true。

如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

`notify` 是用来控制是否在某些情况下弹出提示（比如连续两次使用 disableHLChunk 命令），默认为 true

`use_treesitter` 是用来控制是否使用 treesitter 来高亮代码块，默认为 true

如果设置为 false，将使用 vim 的 match 来高亮代码块，反之使用 treesitter 来判断当前代码块

`exclude_filetypes` 是一个 lua table 类型，例子如下，默认的 exclude_filetypes 可以在 [default config](../../lua/hlchunk/utils/filetype.lua) 中找到

```lua
exclude_filetypes = {
    aerial = true,
    dashboard = true,
}
```

`support_filetypes` 是一个 lua table 类型，例子如下

```lua
support_filetypes = {
    "*.lua",
    "*.js",
}
```

`chars` 也是一个 lua 表，其中的字符用来指示如何渲染 chunk line，这个表中包含五个部分

- horizontal_line
- vertical_line
- left_top
- left_bottom
- right_arrow

`style` 可以是多种类型，如下

1. 字符串, 例如 `style = "#806d9c"`
2. 表, 例如 `style = {"#806d9c", "#c21f30"}`
3. 表, 例如

```lua
style = {
   { fg = "#806d9c", bg = "#c21f30" },
   { fg = "#806d9c", bg = "#c21f30" },
}
```

4. 包含函数的表, 例如

```lua
local cb = function()
    if vim.g.colors_name == "tokyonight" then
        return "#806d9c"
    else
        return "#00ffff"
    end
end
style = {
    { fg = cb },
    { fg = "#f35336" },
},
```

`max_file_size` 是一个数字，默认为 1024\*1024(1MB)，当打开的文件大小超过这个值时，将不会高亮

`error_sign` is a boolean, the default is true, if you use treesitter to highlight the chunk, when this is a wrong chunk, it will set the chunk color to maple red (or what other you want), to enable this option, style should have two color, the default style is

```lua
style = {
    "#806d9c",
    "#c21f30",
},
```

`error_sign` 是一个布尔值，默认为 true，如果你使用 treesitter 来高亮代码块，当遇到错误的代码块时，它将会把 chunk 的颜色设置为枫叶红（或者你想要的其他颜色），要启用这个选项，style 应该有两个颜色， 默认的 style 为

```lua
style = {
    "#806d9c",
    "#c21f30",
},
```

## example

下面是默认的 chunk 样式

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk1.png">

他的配置方式为

```lua
chunk = {
    chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    style = "#806d9c",
},
```

<a id='chunk_gif'>你可以按照下面的配置来使你的样式看起来像是 GIF 里演示的那样</a>

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlchunk8.gif">

```lua
chunk = {
    chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "┌",
        left_bottom = "└",
        right_arrow = "─",
    },
    style = "#00ffff",
},
```
