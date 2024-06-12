# chunk

## chunk 用来做什么

这个 mod 可以用来指示当前光标所在的一个 chunk（比如 function_declaration，if_statement）等。并且提供了 textobject 方便你快速的操作这个 chunk。

## 配置项

该 mod 的默认配置如下：

```lua
local default_conf = {
    priority = 15,
    style = {
        { fg = "#806d9c" },
        { fg = "#c21f30" },
    },
    use_treesitter = true,
    chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    textobject = "",
    max_file_size = 1024 * 1024,
    error_sign = true,
    -- 动画相关
    duration = 200,
    delay = 300,
}
```

独有的配置项为 `use_treesitter`，`chars`，`textobject`，`max_file_size`，`error_sign`，`duration`，`delay`

- `use_treesitter` 是用来控制是否使用 treesitter 来高亮代码块，默认为 true。
  如果该项被设置为 true，他是通过自底向上的查找树的节点，直至找到匹配的节点类型，以此获取相应的 chunk 范围的。而如果设置为 false，将使用 vim 的 `searchpair` 来查找最近的相邻大括号来推断位置（也因此导致 Python 等脚本语言无法正常使用该 mod）

- `chars` 是一个表，其中的字符用来指示用哪些字符来渲染 chunk，这个表中包含五个部分

  - horizontal_line
  - vertical_line
  - left_top
  - left_bottom
  - right_arrow

- `textobject` 是一个字符串，默认没有值。他用来表示想要用哪些字符来表示 textobject，比如我使用的就是 `ic`，意为 `inner chunk`，你也可以修改为其他顺手的字符

- `max_file_size` 是一个数字，默认为 `1MB`，当打开的文件大小超过这个值时，将自动关闭该 mod

- `error_sign` 是一个布尔值，默认为 true，如果你使用 treesitter 来高亮代码块，当遇到错误的代码块时，它将会把 chunk 的颜色设置为枫叶红（或者你想要的其他颜色），要启用这个选项，style 应该有两个颜色， 默认的 style 为

  ```lua
  style = {
      "#806d9c", -- 紫罗兰色
      "#c21f30", -- 枫叶红色
  },
  ```

- `duration` 用来控制动画的持续时间，以毫秒为单位，默认 200 ms

- `delay` 从移动光标到动画开始间隔的时间，以毫秒为单位，默认 300 ms，设置为 0 可以取消动画效果

对于通用的配置（在 [README](../../README.zh-CN.md) 中有提到），仅有部分需要特别注意：

- `style` 是一个字符串或者 Lua 表。如果是字符串，必须是一个 RGB 十六进制字符串。如果是一个表，接收一到两个表示十六进制颜色的字符串，如果只有一个颜色，那么只会使用一个颜色来渲染 chunk，如果有两个颜色，那么会使用两个颜色来渲染 chunk，第一个颜色用来渲染正常的 chunk，第二个颜色用来渲染错误的 chunk。

除此之外，还可以使用这样的配置来动态的切换 chunk 的颜色，这是为了解决[这个 issue](https://github.com/shellRaining/hlchunk.nvim/issues/46)

```lua
local cb = function()
    if vim.g.colors_name == "tokyonight" then
        return "#806d9c"
    else
        return "#00ffff"
    end
end
chunk = {
    style = {
        { fg = cb },
        { fg = "#f35336" },
    },
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
