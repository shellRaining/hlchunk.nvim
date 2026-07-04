# AGENTS.md

## 项目定位

hlchunk.nvim 是一个 Neovim（>= 0.10.0）缩进与代码块高亮插件，用 Lua 编写。核心能力：indent line、chunk 高亮（基于 treesitter 或括号匹配）、行号高亮、blank 修饰。所有渲染通过 `nvim_buf_set_extmark` 的 virt_text overlay 实现。

## 技术栈约束

- Lua（LuaJIT），运行于 Neovim 内，不引入任何外部 Lua 依赖
- 可选依赖：`nvim-treesitter`（indent 模块的 treesitter 缩进）
- 渲染靠 Neovim extmark + namespace；性能关键路径用 FFI 直调 Neovim C API（见 `lua/hlchunk/utils/cFunc.lua`）
- 测试用 `plenary.nvim` 的 busted 格式，headless 运行

## 本地命令

```
make ci                 # 本地预演 CI：selene + stylua + test
make test               # 跑 plenary busted 测试（headless）
make selene             # selene 静态检查（linter）
make stylua             # 格式校验（只读 --check）
make fmt                # 格式写入（stylua 原地格式化）
make lua-language-server # 类型检查（基于 .luarc.json + neodev 类型库）
make dependencies       # 按 Makefile 中 pin 的 commit 拉取 plenary/neodev
```

CI 等价命令：`make selene && make stylua && make test`。
`make lua-language-server` 对应单独的 typecheck workflow。

## 目录地图

详细架构与数据流见 [ARCHITECTURE.md](ARCHITECTURE.md)。

用户向配置说明见 `docs/en/<mod>.md` 与 `docs/zh_CN/<mod>.md`。

```
lua/hlchunk/
  init.lua              入口：setup() 遍历用户配置，按需加载 mod
  mods/
    base_mod/           BaseMod/BaseConf 基类，所有 mod 继承自它
    chunk/              块高亮（treesitter 优先，括号匹配回退）
    indent/             缩进线
    line_num/           块内行号高亮
    blank/              空白字符修饰（继承自 indent）
  utils/                工具：class/scope/cache/timer/ffi/indent/chunk/filetype/ts_node_type
test/features/          plenary busted 测试，命名 *_spec.lua
docs/                   用户文档
```

## 核心约定

1. 新增模块继承 `BaseMod`，配置继承 `BaseConf`，严格遵守 `UserXxxConf` / `XxxConf` 二元类型模式
2. 所有公开类型用 `---@class` / `---@field` 注解，函数用 `---@param` / `---@return`
3. 错误处理：生命周期方法（enable/disable/render）用 pcall 包裹 + `self:notify`，不向上抛
4. 性能：渲染必须可被 `max_file_size` 和 `exclude_filetypes` 关闭；高频回调用 `utils/timer.lua` 的 debounce/throttle
5. 不引入新依赖；优先 FFI 或纯 Lua 实现
6. 行/列索引：API 层 0-index（row/col）；vim.fn 层 1-index。混用时显式 ±1 并注释
7. 修改 `lua/hlchunk/utils/ts_node_type/` 下文件后，必须在 `init.lua` 注册

## PR 流程

1. 本地通过 `make selene && make stylua && make test`
2. 新增功能补 `test/features/*_spec.lua`
3. 用户可见行为变化同步更新 `docs/en` 与 `docs/zh_CN`
4. commit message 遵循现有风格（见 `git log`，如 `feat(chunk): ...`、`fix(indent): ...`）
