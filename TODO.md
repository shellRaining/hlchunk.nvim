## TODO:

- [x] when move cursor in visual mode, the selection background color will be hovered

  use when set `virt_text`, use `hl_mode = "combine"` option

- [ ] when one hunk is in another hunk, don't highlight the outer hunk, such as this situation under, when cursor at x, please highlight the inner hunk at right

```
{
    {

    },
 x  {

    }
}
```

- [x] add indent line highlight

- [x] try to add treesitter support, because the syntax base on regex is so slow and not accurate

- [x] set the indent more highlighting support

- [x] please update README

- [x] add support for single style of hl_indent

- [ ] when open two split windows bind with the same buffer, the highlighting will render incorrectly

- [x] add support for more characters when render hl_indent

- [x] refactor the hl_indent by use vim.fn.indent()

- [ ] enrich the contents of the README

- [ ] add on-demand render for hl_indent

- [ ] add support for fold text

- [ ] when open a large file, you should optimize the spped
