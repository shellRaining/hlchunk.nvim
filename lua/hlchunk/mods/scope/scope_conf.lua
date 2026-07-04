local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.base_mod.base_conf")

---@class HlChunk.UserScopeConf : HlChunk.UserBaseConf
---@field use_treesitter? boolean

---@class HlChunk.ScopeConf : HlChunk.BaseConf
---@field use_treesitter boolean
---@overload fun(conf?: table): HlChunk.ScopeConf
local ScopeConf = class(BaseConf, function(self, conf)
    local default_conf = {
        enable = false,
        priority = 10,
        style = {
            { bg = "#3a3a5c" },
        },
        use_treesitter = true,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as HlChunk.ScopeConf]]
    BaseConf.init(self, conf)

    self.priority = conf.priority
    self.use_treesitter = conf.use_treesitter
end)

return ScopeConf
