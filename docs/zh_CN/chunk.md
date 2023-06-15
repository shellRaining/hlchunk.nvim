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

`style` 是一个 RGB 字符串或者一个 RGB 字符串表，默认为 "#806d9c"。

`max_file_size` 是一个数字，默认为 1024*1024(1MB)，当打开的文件大小超过这个值时，将不会高亮

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
