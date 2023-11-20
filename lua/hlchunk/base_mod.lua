local Array = require("hlchunk.utils.array")
local class = require("hlchunk.utils.class")
local api = vim.api

local BaseMod = class(function(_)
    _.meta = {
        name = "",
        augroup_name = "",
        hl_base_name = "",
    }
    _.conf = {
        enable = false,
        style = "",
        exclude_filetypes = {},
        support_filetypes = {},
        notify = false,
    }
end)

-- just enable a mod instance, called when the mod was disable or not init
function BaseMod:enable()
    local ok, info = pcall(function()
        self.options.enable = true
        self:set_hl()
        self:render()
        self:enable_mod_autocmd()
        -- self:create_mod_usercmd()
    end)
    if not ok then
        self:notify(tostring(info))
    end
end

function BaseMod:disable()
    local ok, info = pcall(function()
        self.options.enable = false
        for _, bufnr in pairs(api.nvim_list_bufs()) do
            -- TODO: need change BaseMod:clear function
            api.nvim_buf_clear_namespace(bufnr, self.ns_id, 0, -1)
        end
        self:disable_mod_autocmd()
    end)
    if not ok then
        self:notify(tostring(info))
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
    api.nvim_create_augroup(self.meta.augroup_name, { clear = true })

    local this = self
    api.nvim_create_autocmd({ "ColorScheme" }, {
        group = self.meta.augroup_name,
        pattern = "*",
        callback = function()
            this:set_hl()
        end,
    })
end

function BaseMod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name(self.meta.augroup_name)
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
    -- TODO: need ref
    local hl_opts = self.options.style

    -- such as style = "#abcabc"
    if type(hl_opts) == "string" then
        api.nvim_set_hl(0, self.meta.hl_base_name .. "1", { fg = hl_opts })
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
                api.nvim_set_hl(0, self.meta.hl_base_name .. idx, value_tmp)
                goto continue
            end
            --[[
            such as style = {
                { fg = "#abcabc", bg = "#cdefef" },
                { fg = "#abcabc", bg = "#cdefef" },
            }
            --]]
            api.nvim_set_hl(0, self.meta.hl_base_name .. idx, value)
        elseif value_type == "string" then
            -- such as style = {"#abcabc", "#cdefef"}
            api.nvim_set_hl(0, self.meta.hl_base_name .. idx, { fg = value })
        end
        ::continue::
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
---@param opts {once: boolean}?
function BaseMod:notify(msg, level, opts)
    level = level or vim.log.levels.INFO
    opts = opts or { once = false }
    -- notice that if self.options.notify is nil, it will still notify you
    if self.options == nil or self.options.notify == false then
        return
    end

    if opts.once then
        vim.notify_once(msg, level, opts)
    else
        vim.notify(msg, level, opts)
    end
end

return BaseMod
