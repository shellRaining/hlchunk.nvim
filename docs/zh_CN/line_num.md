# line_num

## line_num 用来做什么

其实他和 chunk 的功能相同，只是可能有些人不喜欢 chunk，偏好高亮行号的形式，因此有了这个 mod

## 配置项

该 mod 的默认配置如下：

```lua
local default_conf = {
    style = "#806d9c",
    use_treesitter = false,
}
```

独有的配置项为 `use_treesitter`，用法和 chunk 的该项一样，详情见 [chunk](./chunk.md)

和 chunk 一样，我们需要额外注意 style 这个通用配置：他只接收一个字符串，表示十六进制颜色，来表示行号的颜色

## example

下面是默认的 line_num 样式

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">

```lua
line_num = {
    style = "#806d9c",
},
```

未来还会添加更多有意思的样式…… 如果你有好的想法，非常欢迎来提建议 😊
