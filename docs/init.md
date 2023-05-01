# hlchunk introduction

## brief

```
lua
└── hlchunk
    ├── base_mod.lua
    ├── init.lua
    ├── mods
    │   ├── blank.lua
    │   ├── chunk.lua
    │   ├── indent.lua
    │   └── line_num.lua
    └── utils
        ├── string.lua
        ├── table.lua
        └── utils.lua
```

as we knwon, neovim will load the plugin directory in `runtimespath` automatically, this will cause without setup the plugin has been used, so i don't set this dir, instead of `lua` dir, to use this plugin, user should require the it manually.

the project src files is under `lua/hlchunk` dir, we will introduce them one by one

1. init.lua

   this file controls what to do when setup

   we will start from this file because the plugin loads here, when we call `require('hlchunk').setup()`, the `setup` function will execute and merge user config and default config, then judge what features are available, the unused features will not cost memory and CPU time, at last, it will load global variables, usercmds, highlights and autocmds

2. base_mod.lua

   this file defines the base mod behavior, as user you need not to care it

3. utils/

   this dir contains some useful functions to render and deal with strings...
