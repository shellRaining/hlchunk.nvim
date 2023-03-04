# hlchunk introduction

## brief

```
├── lua
│   └── hlchunk
│       ├── autocmd.lua
│       ├── global.lua
│       ├── highlight.lua
│       ├── hl_chunk.lua
│       ├── hl_indent.lua
│       ├── hl_line_num.lua
│       ├── init.lua
│       ├── lib
│       │   └── table.lua
│       ├── options.lua
│       ├── usercmd.lua
│       └── utils
│           ├── color.lua
│           └── utils.lua
```

as we knwon, neovim will load the plugin directory in `runtimespath` automatically, this will cause without setup the plugin has been used, so i don't set this dir, instead of `lua` dir, to use this plugin, user should require the it manually.

the project src files is under `lua/hlchunk` dir, we will introduce them one by one

## init.lua

this file controls what to do when setup

we will start from this file because the plugin loads here, when we call `require('hlchunk').setup()`, the `setup` function will execute and merge user config and default config, then judge what features are available, the unused features will not cost memory and CPU time, at last, it will load global variables, usercmds, highlights and autocmds

## autocmd.lua

the file controls state of autocmds

`init.lua` will load `autocmd.lua` and in this file we set some autocmds, when get suitable events from nvim such as `WinScrolled`, the corresponding render function will be executed

## global.lua

this file contains some global variables could be used when rendering, it will be updated in `autocmd.lua`

## usercmd.lua

this file will define some usercmds, all of commands are used to control the state of plugins
