local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseMod.BaseConf")
local Scope = require("hlchunk.utils.Scope")

local api = vim.api
local fn = vim.fn

---@param self BaseMod
---@param conf BaseConf
---@param meta MetaInfo
local constrctor = function(self, conf, meta)
    local default_meta = {
        name = "",
        augroup_name = "",
        hl_base_name = "",
        ns_id = -1,
        hl_name_list = {},
    }
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = BaseConf(conf)
end

---@class BaseMod
---@field meta MetaInfo include info just used in mod inside, user can't access it
---@field conf BaseConf user config
---@field init fun(self: BaseMod, conf: BaseConf, meta: MetaInfo) not used for init mod, but as super keyword when inherit
---@field enable fun(self: BaseMod) enable the mod, the main entry of the mod
---@field disable fun(self: BaseMod) disable the mod
---@field protected shouldRender fun(self: BaseMod): boolean just a tool function
---@field protected render fun(self: BaseMod, range?: Scope)
---@field protected clear fun(self: BaseMod, range?: Scope)
---@field protected createUsercmd fun(self: BaseMod)
---@field protected createAutocmd fun(self: BaseMod)
---@field protected clearAutocmd fun(self: BaseMod)
---@field protected setHl fun(self: BaseMod)
---@field protected clearHl fun(self: BaseMod)
---@field protected notify fun(self: BaseMod, msg: string, level?: string, opts?: table)
---@overload fun(conf?: UserBaseConf, meta?: MetaInfo): BaseMod
local BaseMod = class(constrctor)

function BaseMod:enable()
    local ok, info = pcall(function()
        self.conf.enable = true
        self:setHl()
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

function BaseMod:shouldRender()
    return self.conf.enable and not self.conf.exclude_filetypes[vim.bo.ft] and fn.shiftwidth() ~= 0
end

function BaseMod:render(range)
    if not self:shouldRender() then
        return
    end
    self:clear(range)
end

---@param range Scope the range to clear, start line and end line all include, 0-index
function BaseMod:clear(range)
    range = range or Scope(0, fn.line("w0") - 1, fn.line("w$") --[[@as number]])
    local start = range.start
    local finish = range.finish + 1

    if finish == api.nvim_buf_line_count(range.bufnr) then
        finish = -1
    end

    if self.meta.ns_id ~= -1 then
        api.nvim_buf_clear_namespace(range.bufnr, self.meta.ns_id, start, finish)
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
