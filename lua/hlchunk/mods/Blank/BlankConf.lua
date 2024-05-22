local class = require("hlchunk.utils.class")
local IndentConf = require("hlchunk.mods.Indent.IndentConf")

---@class UserBlankConf : UserIndentConf

---@class BlankConf : BaseConf
---@overload fun(conf?: UserIndentConf): IndentConf
local BlankConf = class(IndentConf, function(self, conf)
    local default_conf = {
        priority = 9,
        chars = { "․" },
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as IndentConf]]
    IndentConf.init(self, conf)
end)

return BlankConf
