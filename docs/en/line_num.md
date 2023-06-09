# how to configure hl_line_num

## Configurable items

line_num have three configurable items

1. enable
2. notify
3. style
4. support_filetypes

`enable` is used to control whether enable hl_line_num, if set it to false, its usercmd and autocmd will not set, so it will not work

`notify` same as chunk mod

`style` is a RGB string, it will set the color of font color of line number

`support_filetypes` is a table, you can set like this

```lua
support_filetypes = {
    "*.lua",
    "*.js",
}

```

## example

below is the default style of indent line

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">

```lua
line_num = {
    style = "#806d9c",
},
```

future will add more intresting style... if you have good idea, show it at issue please 😊
