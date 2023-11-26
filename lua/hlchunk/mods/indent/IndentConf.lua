local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

---@class UserIndentConf : UserBaseConf
---@field chars? string[]
---@field use_treesitter? boolean

---@class IndentConf : BaseConf
---@field use_treesitter boolean
---@field chars table<string, string>
---@overload fun(conf?: UserIndentConf): IndentConf
local IndentConf = class(BaseConf, function(self, conf)
    local default_conf = {
        style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
        priority = 10,
        use_treesitter = false,
        chars = { "│" },
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as IndentConf]]
    BaseConf.init(self, conf)

    self.use_treesitter = conf.use_treesitter
    self.chars = conf.chars
end)

return IndentConf
