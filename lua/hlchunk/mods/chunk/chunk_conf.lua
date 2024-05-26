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
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as ChunkConf]]
    BaseConf.init(self, conf)

    for key, value in pairs(conf) do
        self[key] = value
    end
end)

return ChunkConf
