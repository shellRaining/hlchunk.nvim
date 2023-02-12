# hlchunk.nvim
This is the lua implementation of [nvim-hlchunk](https://github.com/yaocccc/nvim-hlchunk)

<img width="390" alt="image" src="https://user-images.githubusercontent.com/111564053/218303363-1dd1499c-ad9c-4632-8c4a-1b8be90526f0.png">
<img width="296" alt="image" src="https://user-images.githubusercontent.com/111564053/218303396-66ce2890-05f1-410f-b04e-e2d41dd59fb4.png">
<img width="334" alt="image" src="https://user-images.githubusercontent.com/111564053/218303477-52dc3a39-3e72-4a72-9455-3bf674a3fe6a.png">


## Requirements

neovim version `>= 0.7.0` (maybe, just test at this version)

## Installation

### Packer

```lua
use { "shell-Raining/hlchunk.nvim" }

```

### Plug

```lua
Plug "shell-Raining/hlchunk.nvim"
```

## Setup

The script comes with the following defaults:

```lua
{
    enabled = true,
    hlchunk_supported_files = { "*.ts,*.js,*.json,*.go,*.c,*.cpp,*.rs,*.h,*.hpp,*.lua" },
    hl_chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
    },
    hlchunk_hl_style = "#c06f98",
}
```

To override the custom configuration, call:

```lua
require('hlchunk').setup({
  -- your override config
})
```

example:

```lua
require('hlchunk').setup({
  hlchunk_hl_style = "#806d9c",
})
```
