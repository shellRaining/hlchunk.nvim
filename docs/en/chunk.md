# how to configure chunk mod

## Configurable items

chunk have four configurable items

1. enable
2. support_filetypes
3. chars
4. style

enable is used to control whether enable hl_chunk, if set it to false, its usercmd and autocmd will not set, so it will not work

support_filetypes is a table, you can set like this

```lua
support_filetypes = {
    "*.lua",
    "*.js",
}
```

chars is used to configure what char to render the chunk line, a chunk line contains five parts

- horizontal_line
- vertical_line
- left_top
- left_bottom
- right_arrow

style is a RGB string or RGB string list, if it is a table, it will choice different color to render different chunk

## example

below is the default style of chunk line

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk1.png">

its configuration is

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

you can also set like this gif

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
