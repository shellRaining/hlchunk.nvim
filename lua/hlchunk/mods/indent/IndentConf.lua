local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

---@class UserIndentConf : UserBaseConf
---@field chars? string[]
---@field use_treesitter? boolean
---@field ahead_lines? number

---@class IndentConf : BaseConf
---@field chars table<string, string>
---@field use_treesitter boolean
---@field ahead_lines number
---@overload fun(conf?: UserIndentConf): IndentConf
local IndentConf = class(BaseConf, function(self, conf)
    local default_conf = {
        style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
        priority = 10,
        use_treesitter = false,
        chars = { "│" },
        ahead_lines = 5,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as IndentConf]]
    BaseConf.init(self, conf)

    self.use_treesitter = conf.use_treesitter
    self.chars = conf.chars
    self.ahead_lines = conf.ahead_lines
end)

return IndentConf
