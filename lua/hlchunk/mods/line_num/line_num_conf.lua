local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.base_mod.base_conf")

---@class HlChunk.UserLineNumConf : HlChunk.UserBaseConf
---@field use_treesitter? boolean

---@class HlChunk.LineNumConf : HlChunk.BaseConf
---@field use_treesitter boolean
---@overload fun(conf?: table): HlChunk.ChunkConf
local LineNumConf = class(BaseConf, function(self, conf)
    local default_conf = {
        style = "#806d9c",
        priority = 10,
        use_treesitter = false,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as HlChunk.LineNumConf]]
    BaseConf.init(self, conf)

    self.style = conf.style
    self.use_treesitter = conf.use_treesitter
end)

return LineNumConf
