local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.base_mod.base_conf")

---@class UserChunkConf : UserBaseConf
---@field use_treesitter? boolean
---@field chars? table<string, string>
---@field textobject? string
---@field max_file_size? number
---@field error_sign? boolean

---@class ChunkConf : BaseConf
---@field use_treesitter boolean
---@field chars table<string, string>
---@field textobject string
---@field max_file_size number
---@field error_sign boolean
---@field duration number
---@field delay number
---@overload fun(conf?: table): ChunkConf
local ChunkConf = class(BaseConf, function(self, conf)
    local default_conf = {
        priority = 15,
        style = {
            { fg = "#806d9c" },
            { fg = "#c21f30" },
        },
        use_treesitter = true,
        chars = {
            left_arrow = "─",
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        textobject = "",
        max_file_size = 1024 * 1024,
        error_sign = true,
        duration = 200,
        delay = 300,
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as ChunkConf]]
    BaseConf.init(self, conf)

    self.priority = conf.priority
    self.use_treesitter = conf.use_treesitter
    self.chars = conf.chars
    self.textobject = conf.textobject
    self.max_file_size = conf.max_file_size
    self.error_sign = conf.error_sign
    self.duration = conf.duration
    self.delay = conf.delay
end)

return ChunkConf
