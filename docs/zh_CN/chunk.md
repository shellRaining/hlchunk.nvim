# 怎样配置 hl_chunk

## 配置项

chunk mod 有四个配置项

1. enable
2. support_filetypes
3. chars
4. style

enable 是用来控制该 mod 是否启动的，如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

support_filetypes 是一个 lua table 类型，例子如下

```lua
support_filetypes = {
    "*.lua",
    "*.js",
}
```

chars 也是一个 lua 表，其中的字符用来指示如何渲染 chunk line，这个表中包含五个部分

- horizontal_line
- vertical_line
- left_top
- left_bottom
- right_arrow

style 是一个 RGB 字符串或者一个表，如果是表，他将会使用不同颜色来渲染 chunk line

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

你可以按照下面的配置来使你的样式看起来像是 GIF 里演示的那样

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
