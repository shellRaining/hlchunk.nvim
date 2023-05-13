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

- [ ] enrich the contents of the README

- [ ] when open a large file, you should optimize the speed (hlchunk mod)

        maybe I can not solve it, because all the function is cost time, and I can't find a way to optimize it

- [ ] Optimize context algorithm, expand context range when get too few info

- [ ] Add support for non-multiple indentation

- [ ] optimize base_mod

- [ ] win size changed bug fix
