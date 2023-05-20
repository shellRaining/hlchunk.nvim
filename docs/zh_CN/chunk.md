# chunk

## chunk 用来做什么

是用来高亮当前代码块，在本项目中代码块的定义是当前光标所处位置最近的一对括号及其中间的代码段，所以这个插件可能不是很适合 lua 和 python 代码。在未来我会用缩进来定义一个代码块（所以这个项目未来可能会变成类似 `indent_blankline` 的项目 😊）

# 怎样配置 chunk

## 配置项

chunk mod 有四个配置项

1. enable
2. use_treesitter
3. exclude_filetypes
4. support_filetypes
5. chars
6. style

`enable` 是用来控制该 mod 是否启动的，如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

`use_treesitter` 是用来控制是否使用 treesitter 来高亮代码块，如果设置为 false，那么该 mod 将使用 vim 的 match 来高亮代码块

`exclude_filetypes` 是一个 lua table 类型，例子如下

```lua
exclude_filetypes = {
    "lua",
    "python",
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

`style` 是一个 RGB 字符串或者一个 RGB 字符串表

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
