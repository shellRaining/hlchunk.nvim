local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.base_mod.base_conf")

---@class HlChunk.UserChunkConf : HlChunk.UserBaseConf
---@field use_treesitter? boolean
---@field chars? table<string, string>
---@field textobject? string
---@field max_file_size? number
---@field error_sign? boolean
---@field node_type_styles? table<string, table> mapping of node type patterns to style

---@class HlChunk.ChunkConf : HlChunk.BaseConf
---@field use_treesitter boolean
---@field chars table<string, string>
---@field textobject string
---@field max_file_size number
---@field error_sign boolean
---@field duration number
---@field delay number
---@field node_type_styles table<string, table> mapping of node type patterns to style
---@overload fun(conf?: table): HlChunk.ChunkConf
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
        -- Node type to style mapping (patterns matched against treesitter node type)
        -- If a node type matches multiple patterns, first match wins
        -- If no match, falls back to default style[1]
        node_type_styles = {
            -- Example config (users can override):
            -- ["^func"] = { fg = "#99aee5" },      -- functions: blue
            -- ["^if"] = { fg = "#c2a2e3" },        -- conditionals: purple
            -- ["else"] = { fg = "#c2a2e3" },       -- else: purple
            -- ["^for"] = { fg = "#fbdf90" },       -- for loops: yellow
            -- ["^while"] = { fg = "#fbdf90" },     -- while loops: yellow
            -- ["try"] = { fg = "#9fe8c3" },        -- try/catch: green
            -- ["except"] = { fg = "#9fe8c3" },     -- except: green
            -- ["catch"] = { fg = "#9fe8c3" },      -- catch: green
            -- ["class"] = { fg = "#ef8891" },      -- classes: red
        },
    }
    conf = vim.tbl_deep_extend("force", default_conf, conf or {}) --[[@as HlChunk.ChunkConf]]
    BaseConf.init(self, conf)

    self.priority = conf.priority
    self.use_treesitter = conf.use_treesitter
    self.chars = conf.chars
    self.textobject = conf.textobject
    self.max_file_size = conf.max_file_size
    self.error_sign = conf.error_sign
    self.duration = conf.duration
    self.delay = conf.delay
    self.node_type_styles = conf.node_type_styles
end)

return ChunkConf
