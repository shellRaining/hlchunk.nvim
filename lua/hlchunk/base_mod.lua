local Array = require("hlchunk.utils.array")
local api = vim.api
local fn = vim.fn

---@class BaseModOpts
---@field enable boolean
---@field style string | table<string> | table<table>
---@field exclude_filetypes table<string, boolean>
---@field support_filetypes table<string>
---@field notify boolean

---@class RuntimeVar
---@field old_win_info table<number, number>

---@class MetaInfo
---@field name string
---@field ns_id number
---@field augroup_name string
---@field hl_base_name string

---@class RenderOpts
---@field lazy boolean

---@class BaseMod
---@field name string the name of mod, use Snake_case naming style, such as line_num
---@field ns_id number namespace id
---@field old_win_info table used to record old window info such as leftcol, curline and top line and so on
---@field options BaseModOpts default config for mod, and user can change it when setup
---@field augroup_name string with format hl_{mod_name}_augroup, such as hl_chunk_augroup
---@field hl_base_name string with format HL{mod_name:firstToUpper()}, such as HLChunk
---@field new fun(self: BaseMod, o: table): BaseMod
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod, opts: RenderOpts | nil)
---@field clear fun(self: BaseMod, line_start: number | nil, line_end: number | nil)
---@field enable_mod_autocmd fun(self: BaseMod)
---@field disable_mod_autocmd fun(self: BaseMod)
---@field create_mod_usercmd fun(self: BaseMod)
---@field set_options fun(self: BaseMod, options: table | nil)
---@field extra fun(self:BaseMod)
local BaseMod = {
    name = "",
    options = {},
    ns_id = -1,
    old_win_info = fn.winsaveview(),
    augroup_name = "",
    hl_base_name = "",
}

function BaseMod:new(o)
    o = o or {}
    o.augroup_name = o.augroup_name or ("hl_" .. o.name .. "_augroup")
    o.hl_base_name = o.hl_base_name or ("HL" .. o.name:firstToUpper())
    self.__index = self
    setmetatable(o, self)
    return o
end

function BaseMod:enable()
    local ok, info = pcall(function()
        self.options.enable = true
        self:set_hl()
        self:render()
        self:enable_mod_autocmd()
        self:create_mod_usercmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:disable()
    local ok, _ = pcall(function()
        self.options.enable = false
        for _, bufnr in pairs(api.nvim_list_bufs()) do
            api.nvim_buf_clear_namespace(bufnr, self.ns_id, 0, -1)
        end
        self:disable_mod_autocmd()
    end)
    if not ok then
        self:notify("you have disable " .. self.name .. " mod")
    end
end

function BaseMod:render()
    self:notify("not implemented render " .. self.name, vim.log.levels.ERROR)
end

function BaseMod:clear(line_start, line_end)
    line_start = line_start or 0
    line_end = line_end or -1

    if self.ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, self.ns_id, line_start, line_end)
    end
end

function BaseMod:enable_mod_autocmd()
    api.nvim_create_augroup(self.augroup_name, { clear = true })

    local this = self
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.augroup_name,
        pattern = "*",
        callback = function()
            this:set_hl()
        end,
    })
end

function BaseMod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name(self.augroup_name)
end

function BaseMod:create_mod_usercmd()
    local token_array = Array:from(self.name:split("_"))
    local mod_name = token_array
        :map(function(value)
            return value:firstToUpper()
        end)
        :join()
    api.nvim_create_user_command("EnableHL" .. mod_name, function()
        self:enable()
    end, {})
    api.nvim_create_user_command("DisableHL" .. mod_name, function()
        self:disable()
    end, {})
end

-- set highlight for mod
-- there are four types to config
-- 1. style = "#abcabc"
-- 2. style = {"#abcabc", "#cdefef"}
-- 3. style = {
--      { fg = "#abcabc", bg = "#cdefef" },
--      { fg = "#abcabc", bg = "#cdefef" },
-- }
-- 4. style = {
--      { fg = fg1cb, bg = bg1cb },
--      { fg = "#abcabc", bg = "#cdefef"},
-- }
function BaseMod:set_hl()
    local hl_opts = self.options.style

    -- such as style = "#abcabc"
    if type(hl_opts) == "string" then
        api.nvim_set_hl(0, self.hl_base_name .. "1", { fg = hl_opts })
        return
    end

    for idx, value in ipairs(hl_opts) do
        local value_type = type(value)
        if value_type == "table" then
            --[[
            such as style = {
                { fg = fg1cb, bg = bg1cb },
                { fg = "#abcabc", bg = "#cdefef"},
            }
            --]]
            if type(value.fg) == "function" or type(value.bg) == "function" then
                local value_tmp = vim.deepcopy(value)
                value_tmp.fg = type(value.fg) == "function" and value.fg() or value.fg
                value_tmp.bg = type(value.bg) == "function" and value.bg() or value.bg
                api.nvim_set_hl(0, self.hl_base_name .. idx, value_tmp)
                return
            end
            --[[
            such as style = {
                { fg = "#abcabc", bg = "#cdefef" },
                { fg = "#abcabc", bg = "#cdefef" },
            }
            --]]
            api.nvim_set_hl(0, self.hl_base_name .. idx, value)
        elseif value_type == "string" then
            -- such as style = {"#abcabc", "#cdefef"}
            api.nvim_set_hl(0, self.hl_base_name .. idx, { fg = value })
        end
    end
end

-- set options for mod, if the mod dont have default config, it will notify you
---@param options BaseModOpts
function BaseMod:set_options(options)
    if self.options == nil then
        self:notify("not set the default config for " .. self.name, vim.log.levels.ERROR)
        return
    end
    self.options = vim.tbl_deep_extend("force", self.options, options or {})
end

---@param msg string
---@param level number?
function BaseMod:notify(msg, level)
    level = level or vim.log.levels.INFO
    -- notice that if self.options.notify is nil, it will still notify you
    if self.options == nil or self.options.notify == false then
        return
    end
    vim.notify(msg, level)
end

return BaseMod
