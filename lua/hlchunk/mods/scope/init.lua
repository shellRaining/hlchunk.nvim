local BaseMod = require("hlchunk.mods.base_mod")
local ScopeConf = require("hlchunk.mods.scope.scope_conf")
local chunkHelper = require("hlchunk.utils.chunkHelper")
local class = require("hlchunk.utils.class")

local api = vim.api
local CHUNK_RANGE_RET = chunkHelper.CHUNK_RANGE_RET

---@class HlChunk.ScopeMetaInfo : HlChunk.MetaInfo

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "scope",
        augroup_name = "hlchunk_scope",
        hl_base_name = "HLScope",
        ns_id = api.nvim_create_namespace("scope"),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = ScopeConf(conf)
end

---@class HlChunk.ScopeMod : HlChunk.BaseMod
---@field conf HlChunk.ScopeConf
---@field meta HlChunk.ScopeMetaInfo
---@field render fun(self: HlChunk.ScopeMod, range: HlChunk.Scope)
---@overload fun(conf?: HlChunk.UserScopeConf, meta?: HlChunk.MetaInfo): HlChunk.ScopeMod
local ScopeMod = class(BaseMod, constructor)

function ScopeMod:render(range)
    if not self:shouldRender(range.bufnr) then
        return
    end

    local hl_name = self.meta.hl_name_list[1]
    if not hl_name then
        return
    end

    local bufnr = range.bufnr
    local ns_id = self.meta.ns_id
    local priority = self.conf.priority

    for i = range.start, range.finish do
        api.nvim_buf_set_extmark(bufnr, ns_id, i, 0, {
            end_row = i + 1,
            end_col = 0,
            hl_group = hl_name,
            priority = priority,
        })
    end
end

function ScopeMod:createAutocmd()
    BaseMod.createAutocmd(self)

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = self.meta.augroup_name,
        callback = function(event)
            local bufnr = event.buf
            if not self:shouldRender(bufnr) then
                return
            end
            local winnr = api.nvim_get_current_win()
            local pos = api.nvim_win_get_cursor(winnr)
            local retcode, cur_scope_range = chunkHelper.get_chunk_range({
                pos = { bufnr = bufnr, row = pos[1] - 1, col = pos[2] },
                use_treesitter = self.conf.use_treesitter,
            })
            self:clear({ bufnr = bufnr, start = 0, finish = api.nvim_buf_line_count(bufnr) })
            if retcode ~= CHUNK_RANGE_RET.OK then
                if retcode == CHUNK_RANGE_RET.NO_TS then
                    self:notify("[hlchunk.scope]: no parser for " .. vim.bo[bufnr].ft, nil, { once = true })
                elseif retcode == CHUNK_RANGE_RET.NO_CHUNK then
                    self:notify("[hlchunk.scope]: no scope node found at cursor", nil, { once = true })
                end
                return
            end
            self:render(cur_scope_range)
        end,
    })
end

return ScopeMod
