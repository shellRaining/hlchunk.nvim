local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

---@type IndentConf
local IndentConf = class(BaseConf, function(self, conf)
    vim.notify(vim.inspect(conf))
    BaseConf.init(self, conf)
    conf = conf or {}
    self.use_treesitter = conf.use_treesitter or false
    self.chars = conf.chars or { "│" }
end)

return IndentConf
