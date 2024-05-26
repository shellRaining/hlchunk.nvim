# line_num

## line_num is used for what

Actually, it has the same function as chunk, but some people may not like chunk and prefer the form of highlighting line numbers. That's why this mod exists.

## config

The default configuration of this mod is:

```lua
local default_conf = {
    style = "#806d9c",
    priority = 10,
    use_treesitter = false,
}
```

The unique configuration item is use_treesitter, which works the same as the same item in chunk. See details in [chunk](./chunk.md).

Just like chunk, we need to pay extra attention to the common configuration "style": it only accepts a string representing a hexadecimal color to indicate the color of line numbers.

## example

Here is the default line_num style:

<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">

```lua
line_num = {
    style = "#806d9c",
},
```

More interesting styles will be added in the future... If you have good ideas, welcome to suggest! 😊
