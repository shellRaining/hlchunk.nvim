local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")

local api = vim.api

local constrctor = function(self, conf, meta)
    self.meta = meta
        or {
            name = "",
            augroup_name = "",
            hl_base_name = "",
            ns_id = -1,
            hl_name_list = {},
        } --[[@as MetaInfo]]
    self.conf = conf or (BaseConf())
end

---@class BaseMod
---@field meta MetaInfo
---@field conf BaseConf
---@field init fun(self: BaseMod, meta: MetaInfo, conf: BaseConf)
---@field enable fun(self: BaseMod)
---@field disable fun(self: BaseMod)
---@field render fun(self: BaseMod, range?: Scope)
---@field clear fun(self: BaseMod, range?: Scope)
---@field createUsercmd fun(self: BaseMod)
---@field createAutocmd fun(self: BaseMod)
---@field clearAutocmd fun(self: BaseMod)
---@field setHl fun(self: BaseMod)
---@field clearHl fun(self: BaseMod)
---@field notify fun(self: BaseMod, msg: string, level?: string, opts?: table)
---@overload fun(conf: BaseConf, meta: MetaInfo): BaseMod
local BaseMod = class(constrctor)

function BaseMod:enable()
    local ok, info = pcall(function()
        self.conf.enable = true
        self:setHl()
        vim.notify("enableing")
        self:render()
        self:createAutocmd()
        self:createUsercmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:disable()
    local ok, info = pcall(function()
        self.conf.enable = false
        for _, bufnr in pairs(api.nvim_list_bufs()) do
            -- TODO: need change BaseMod:clear function
            api.nvim_buf_clear_namespace(bufnr, self.meta.ns_id, 0, -1)
        end
        self:clearAutocmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:render(range)
    if (not self.conf.enable) or self.conf.exclude_filetypes[vim.bo.ft] then
        return
    end
    self:clear(range)
end

function BaseMod:clear(range)
    local start = range and range.start or 0
    local finish = range and range.finish or -1

    -- TODO: needed?
    if self.meta.ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, self.meta.ns_id, start, finish)
    end
end

function BaseMod:createUsercmd()
    -- TODO: update the name case
    api.nvim_create_user_command("EnableHL" .. self.meta.name, function()
        self:enable()
    end, {})
    api.nvim_create_user_command("DisableHL" .. self.meta.name, function()
        self:disable()
    end, {})
end

function BaseMod:createAutocmd()
    api.nvim_create_augroup(self.meta.augroup_name, { clear = true })

    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.meta.augroup_name,
        pattern = "*",
        callback = function()
            self:setHl()
        end,
    })
end

function BaseMod:clearAutocmd()
    api.nvim_del_augroup_by_name(self.meta.augroup_name)
end

function BaseMod:setHl()
    local hl_conf = self.conf.style
    self.meta.hl_name_list = {}

    -- such as style = "#abcabc"
    if type(hl_conf) == "string" then
        api.nvim_set_hl(0, self.meta.hl_base_name .. "1", { fg = hl_conf })
        self.meta.hl_name_list = { self.meta.hl_base_name .. "1" }
        return
    end

    for idx, val in ipairs(hl_conf) do
        local value_type = type(val)
        if value_type == "table" then
            if type(val.fg) == "function" or type(val.bg) == "function" then
                --[[
                such as style = {
                    { fg = fg1cb, bg = bg1cb },
                    { fg = "#abcabc", bg = "#cdefef"},
                }
                --]]
                local value_tmp = vim.deepcopy(val)
                value_tmp.fg = type(val.fg) == "function" and val.fg() or val.fg
                value_tmp.bg = type(val.bg) == "function" and val.bg() or val.bg
                api.nvim_set_hl(0, self.meta.hl_base_name .. idx, value_tmp)
            else
                --[[
                such as style = {
                    { fg = "#abcabc", bg = "#cdefef" },
                    { fg = "#abcabc", bg = "#cdefef" },
                }
                --]]
                api.nvim_set_hl(0, self.meta.hl_base_name .. idx, val)
            end
        elseif value_type == "string" then
            -- such as style = {"#abcabc", "#cdefef"}
            api.nvim_set_hl(0, self.meta.hl_base_name .. idx, { fg = val })
        end
        table.insert(self.meta.hl_name_list, self.meta.hl_base_name .. idx)
    end
end

function BaseMod:clearHl()
    -- TODO:
end

function BaseMod:notify(...)
    if self.conf.notify then
        vim.notify(...)
    end
end

return BaseMod
