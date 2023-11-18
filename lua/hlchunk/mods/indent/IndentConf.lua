local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

---@class UserIndentConf : UserBaseConf
---@field chars? string[]
---@field use_treesitter? boolean

---@class IndentConf : BaseConf
---@field use_treesitter boolean
---@field chars table<string, string>
---@overload fun(conf?: table): IndentConf
local IndentConf = class(BaseConf, function(self, conf)
    local default_conf = {
        enable = false,
        style = { vim.api.nvim_get_hl(0, { name = "Whitespace" }) },
        notify = false,
        priority = 10,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {})
    BaseConf.init(self, conf)
    self.use_treesitter = conf.use_treesitter or false
    self.chars = conf.chars or { "│" }
end)

return IndentConf
