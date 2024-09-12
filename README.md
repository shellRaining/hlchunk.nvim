<div align='center'>
<p><img width='400px' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_logo_bg.png'></p>
</div>
<h1 align='center'>hlchunk.nvim</h1>

<p align='center'>
<b>English</b> | <a href="./README.zh-CN.md">简体中文</a>
</p>

## What can this plugin do

Similar to [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim), this plugin can highlight the indent line, and highlight the code chunk according to the current cursor position.

## plugin performance

Using `profile.nvim` for performance analysis, all experiments were conducted on macOS with alacritty, Neovim window height was 66 lines, the code file was `typescript.js`, starting from the first line to the five hundredth line. The average rendering time per render was `0.7ms`.

I did a lot of work to minimize rendering time as much as possible

1. Asynchronous rendering to reduce stuttering

2. Using C functions to speed up some function calls

3. Caching extmarks for each line as much as possible to reduce indentation calculations

4. Using throttle functions to batch the rendering process as much as possible

If you want to reduce the sudden stuttering when scrolling the window, maybe you will like `hlchunk.nvim`~

For detailed optimization work, you can see my blog (written in Chinese): [https://www.shellraining.top/docs/tools/hlchunk/profile.html](https://www.shellraining.top/docs/tools/hlchunk/profile.html)

## Brief introduction

This plugin now have four parts

1. chunk
1. indent
1. line_num
1. blank

One picture to understand what these mods do

<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2305/01_intro.png'>

## more details about each mod

<b> NOTICE: you can click the picture to get more information about how to configure like this </b>

### chunk

<a href='./docs/en/chunk.md#chunk_example1'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2406/hlchunk_v121.gif">
</a>

### indent

<a href='./docs/en/indent.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/23_hlchunk2.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/27_hlchunk4.png">
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2305/01_indent.png">
</a>

### line_num

<a href='./docs/en/line_num.md'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2302/25_hlchunk3.png">
</a>

### blank

<a href='./docs/en/blank.md'>
<img width='500' src='https://raw.githubusercontent.com/shellRaining/img/main/2303/11_hlblank2.png'>
<img width="500" alt="image" src="https://raw.githubusercontent.com/shellRaining/img/main/2303/08_hlblank1.png">
</a>

## Requirements

neovim version `>= 0.9.0`

## Installation (with lazy.nvim)

```lua
{
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({})
  end
},
```

## Setup

This plugin is composed of multiple mods, so they have some common configuration items as follows:

```lua
local default_conf = {
    enable = false,
    style = {},
    notify = false,
    priority = 0,
    exclude_filetypes = {
        aerial = true,
        dashboard = true,
        -- some other filetypes
    }
}
```

1. enable: control whether a certain mod is enabled
1. style: used to control the style of the mod, different mods will have different style configuration methods, you can check their respective documentation for details
1. notify: used to control whether a certain mod displays notification messages (through the notify function)
1. priority: used to control the rendering priority of a certain mod, the higher the priority, the higher the priority of display, by default `chunk` > `indent` > `blank` > `line_num`
1. exclude_filetypes: used to control that a certain mod is not enabled for certain file types

The specific configuration methods for each mod can be found in their respective documentation, the links are as follows:

- [chunk](./docs/en/chunk.md)
- [indent](./docs/en/indent.md)
- [line_num](./docs/en/line_num.md)
- [blank](./docs/en/blank.md)

You can config the whole plugin by using setup function:

```lua
require('hlchunk').setup({
    chunk = {
        enable = true
        -- ...
    },
    indent = {
        enable = true
        -- ...
    }
})
```

Require the specific mod alone also work

```lua
local indent = require('hlchunk.mods.indent')
indent({
    style = {
        -- ...
    }
}):enable() -- don't forget call enable method
```

## notice

Because this plugin use `shiftwidth` function to get the indent width, so for files that do not set the indent width manually, there may be inaccurate situations, you can set the indent width manually:

```lua
vim.bo.shiftwidth = xxx
```

If you feel boring to set the indent width manually, you can use [autoindent.nvim](https://github.com/nmac427/guess-indent.nvim) or [indent-o-matic](https://github.com/Darazaki/indent-o-matic) to guess indent automatically.

## command

Sometimes (e.g., for performance reasons), you may want to manually disable a certain mod, you can follow the rules below: enter `DisableHLxxxx`, replacing `xxxx` with the name of the mod you want to disable, for example, to disable `chunk`, you can enter `DisableHLchunk`.

Similarly, to enable a mod, enter `EnableHLxxxx`.

However, for mods with `enable` set to `false`, the plugin itself will not create a user command (because there is no need).
