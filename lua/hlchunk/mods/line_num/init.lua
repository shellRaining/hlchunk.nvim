local BaseMod = require("hlchunk.mods.base_mod")
local LineNumConf = require("hlchunk.mods.line_num.line_num_conf")
local chunkHelper = require("hlchunk.utils.chunkHelper")
local class = require("hlchunk.utils.class")

local api = vim.api
local CHUNK_RANGE_RET = chunkHelper.CHUNK_RANGE_RET

---@class LineNumMetaInfo : MetaInfo

local constructor = function(self, conf, meta)
    local default_meta = {
        name = "line_num",
        augroup_name = "hlchunk_line_num",
        hl_base_name = "HLLineNum",
        ns_id = api.nvim_create_namespace("line_num"),
    }

    BaseMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = LineNumConf(conf)
end

---@class LineNumMod : BaseMod
---@field conf LineNumConf
---@field meta LineNumMetaInfo
---@field render fun(self: LineNumMod, range: Scope, opts?: {error: boolean})
---@overload fun(conf?: UserLineNumConf, meta?: MetaInfo): LineNumMod
local LineNumMod = class(BaseMod, constructor)

function LineNumMod:render(range)
    if not self:shouldRender(range.bufnr) then
        return
    end

    local beg_row = range.start
    local end_row = range.finish
    local row_opts = {
        number_hl_group = self.meta.hl_name_list[1],
    }
    for i = beg_row, end_row do
        api.nvim_buf_set_extmark(0, self.meta.ns_id, i, 0, row_opts)
    end
end

function LineNumMod:createAutocmd()
    BaseMod.createAutocmd(self)

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = self.meta.augroup_name,
        callback = function(event)
            local bufnr = event.buf
            local winnr = api.nvim_get_current_win()
            local pos = api.nvim_win_get_cursor(winnr)
            local retcode, cur_chunk_range = chunkHelper.get_chunk_range({
                pos = { bufnr = bufnr, row = pos[1] - 1, col = pos[2] },
                use_treesitter = self.conf.use_treesitter,
            })
            self:clear({ bufnr = bufnr, start = 0, finish = api.nvim_buf_line_count(bufnr) })
            if retcode ~= CHUNK_RANGE_RET.OK then
                return
            end
            self:render(cur_chunk_range)
        end,
    })
end

return LineNumMod
