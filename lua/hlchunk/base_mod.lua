local stringx = require("hlchunk.utils.string")

---@class BaseMod
---@field name string
---@field options table | nil
---@field new fun(self: BaseMod, o: table): BaseMod
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod)
---@field clear fun(self: BaseMod)
---@field enable_mod_autocmd fun(self: BaseMod)
---@field disable_mod_autocmd fun(self: BaseMod)
---@field create_mod_usercmd fun(self: BaseMod)
---@field set_options fun(self: BaseMod, options: table | nil)
local BaseMod = {
    name = "",
    options = nil,
}

function BaseMod:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

function BaseMod:enable()
    vim.notify("not implemented enable " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:disable()
    vim.notify("not implemented disable " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:render()
    vim.notify("not implemented render " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:clear()
    vim.notify("not implemented clear " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:enable_mod_autocmd()
    vim.notify("not implemented enable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:disable_mod_autocmd()
    vim.notify("not implemented disable_mod_autocmd " .. self.name, vim.log.levels.ERROR)
end
function BaseMod:create_mod_usercmd()
    vim.notify("not implemented create_mod_usercmd " .. self.name, vim.log.levels.ERROR)
end

-- set highlight for mod
---@class HLOpts
---@field fg? string (or foreground): color name or "#RRGGBB", see note.
---@field bg? string (or background): color name or "#RRGGBB", see note.
---@field sp? string (or special): color name or "#RRGGBB"
---@field blend? integer integer between 0 and 100
---@field bold? boolean
---@field standout? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field underdouble? boolean
---@field underdotted? boolean
---@field underdashed? boolean
---@field strikethrough? boolean
---@field italic? boolean
---@field reverse? boolean
---@field nocombine? boolean
---@field link? string name of another highlight group to link to
---@field ctermfg? string Sets foreground of cterm color
---@field ctermbg? string Sets background of cterm color
---@field cterm? string cterm attribute map

---@param args HLOpts
function BaseMod:set_hl(args)
    local token_list = stringx.split(self.name, "_")
    local hl_name = ""
    for _, value in pairs(token_list) do
        hl_name = hl_name .. stringx.firstToUpper(value)
    end
    vim.api.nvim_set_hl(0, hl_name, args)
end

-- set options for mod, if the mod dont have default config, it will notify you
---@param options table | nil
function BaseMod:set_options(options)
    if self.options == nil then
        vim.notify("not set the default config for " .. self.name, vim.log.levels.ERROR)
        return
    end
    self.options = vim.tbl_deep_extend("force", self.options, options or {})
end

return BaseMod
