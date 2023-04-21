## TODO:

- [ ] when one hunk is in another hunk, don't highlight the outer hunk, such as this situation under, when cursor at x, please highlight the inner hunk at right

```
{
    {

    },
 x  {

    }
}
```

- [ ] when open two split windows bind with the same buffer, the highlighting will render incorrectly

- [ ] enrich the contents of the README

- [ ] add on-demand render for hl_indent

- [ ] when open a large file, you should optimize the speed (hlchunk mod)

        maybe I can not solve it, because all the function is cost time, and I can't find a way to optimize it

- [ ] add nowrap support for all mods

- [ ] Optimize context algorithm, expand context range when get too few info

- [ ] add is comment function

- [ ] Add support for non-multiple indentation
