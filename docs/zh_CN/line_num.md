# 如何设置 line_num mod

## 配置项

line_num 有三个配置项

1. enable
2. notify
2. style
3. support_filetypes

`enable` 是用来控制该 mod 是否启动的，如果设置为 false，其所携带的 usercmd 和 autocmd 均不会产生，此时该 mod 关闭

`notify` 是用来控制是否在某些情况下通知用户，比如禁用 line_num mod 两次

`style` 是一个 RGB 字符串或者一个表，如果是表，他将会使用不同颜色来渲染 chunk line

`support_filetypes` 是一个 lua table 类型，例子如下

```lua
support_filetypes = {
    "*.lua",
    "*.js",
}

```

## example

下面是默认的 line_num 样式

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">

```lua
line_num = {
    style = "#806d9c",
},
```

未来还会添加更多有意思的样式…… 如果你有好的想法，非常欢迎来提建议 😊
