local class = require("hlchunk.utils.class")
local BaseConf = require("hlchunk.mods.BaseConf")

local api = vim.api

---@type BaseMod
local BaseMod = class(function(self, meta, conf)
    self.meta = meta or {
        name = "",
        augroupName = "",
        hlBaseName = "",
    }
    self.conf = conf or (BaseConf())
end)

function BaseMod:enable()
    local ok, info = pcall(function()
        local ns_id = api.nvim_create_namespace(self.meta.name)
        self.conf.enable = true
        self:setHl()
        self:render(ns_id)
        self:createAutocmd(ns_id)
        self:createUsercmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:disable(ns_id)
    local ok, info = pcall(function()
        self.conf.enable = false
        for _, bufnr in pairs(api.nvim_list_bufs()) do
            -- TODO: need change BaseMod:clear function
            api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
        end
        self:clearAutocmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:render(ns_id, range)
    if (not self.conf.enable) or self.conf.excludeFiletypes[vim.bo.ft] then
        return
    end
    self:clear(ns_id)
end

function BaseMod:clear(ns_id, range)
    local start = range and range.start or 0
    local finish = range and range.finish or -1

    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, start, finish)
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
    api.nvim_create_augroup(self.meta.augroupName, { clear = true })

    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.meta.augroupName,
        pattern = "*",
        callback = function()
            self:setHl()
        end,
    })
end

function BaseMod:clearAutocmd()
    api.nvim_del_augroup_by_name(self.meta.augroupName)
end

function BaseMod:setHl()
    local hl_conf = self.conf.style

    -- such as style = "#abcabc"
    if type(hl_conf) == "string" then
        api.nvim_set_hl(0, self.meta.hlBaseName .. "0", { fg = hl_conf })
        return
    end

    for idx, val in ipairs(hl_conf) do
        local value_type = type(val)
        if value_type == "table" then
            --[[
            such as style = {
                { fg = fg1cb, bg = bg1cb },
                { fg = "#abcabc", bg = "#cdefef"},
            }
            --]]
            if type(val.fg) == "function" or type(val.bg) == "function" then
                local value_tmp = vim.deepcopy(val)
                value_tmp.fg = type(val.fg) == "function" and val.fg() or val.fg
                value_tmp.bg = type(val.bg) == "function" and val.bg() or val.bg
                api.nvim_set_hl(0, self.meta.hlBaseName .. idx, value_tmp)
                goto continue
            end
            --[[
            such as style = {
                { fg = "#abcabc", bg = "#cdefef" },
                { fg = "#abcabc", bg = "#cdefef" },
            }
            --]]
            api.nvim_set_hl(0, self.meta.hlBaseName .. idx, val)
        elseif value_type == "string" then
            -- such as style = {"#abcabc", "#cdefef"}
            api.nvim_set_hl(0, self.meta.hlBaseName .. idx, { fg = val })
        end
        ::continue::
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
