local class = require("hlchunk.utils.class")
local ft = require("hlchunk.utils.filetype")

---@alias HlChunk.StyleType string | table<string, string> | table<string, table<string, string>>

---@class HlChunk.UserBaseConf
---@field enable? boolean
---@field style? HlChunk.StyleType
---@field exclude_filetypes? table<string, boolean>
---@field notify? boolean
---@field priority? number

---@class HlChunk.BaseConf
---@field enable boolean
---@field style HlChunk.StyleType
---@field exclude_filetypes table<string, boolean>
---@field notify boolean
---@field priority number
---@field init fun(self: HlChunk.UserBaseConf, conf: table)
---@overload fun(conf?: HlChunk.UserBaseConf): HlChunk.BaseConf
---@overload fun(conf?: HlChunk.BaseConf): HlChunk.BaseConf
local BaseConf = class(function(self, conf)
    local default_conf = {
        enable = false,
        style = {},
        notify = false,
        priority = 0,
        exclude_filetypes = ft.exclude_filetypes,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as HlChunk.BaseConf]]
    self.enable = conf.enable
    self.style = conf.style
    self.exclude_filetypes = conf.exclude_filetypes
    self.notify = conf.notify
    self.priority = conf.priority
end)

return BaseConf
