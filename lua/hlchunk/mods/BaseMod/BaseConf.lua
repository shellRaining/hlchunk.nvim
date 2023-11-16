local class = require("hlchunk.utils.class")
local ft = require("hlchunk.utils.filetype")

local api = vim.api

local BaseConf = class(function(self, conf)
    conf = conf or {}
    self.enable = conf.enable or false
    self.style = conf.style
        or {
            -- TODO: can it use?   fg = 3883617, why this effect
            api.nvim_get_hl(0, { name = "Whitespace" }),
        }
    self.excludeFiletypes = conf.exclude_filetypes or ft.exclude_filetypes
    self.supportFiletypes = conf.support_filetypes or ft.support_filetypes
    self.notify = false
    self.priority = conf.priority or 0
end)

return BaseConf
