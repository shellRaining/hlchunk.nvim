local BaseMod = require("hlchunk.base_mod")
local utils = require("hlchunk.utils.utils")
local ft = require("hlchunk.utils.filetype")
local api = vim.api
local fn = vim.fn
local CHUNK_RANGE_RET = utils.CHUNK_RANGE_RET

---@class LineNumOpts: BaseModOpts
---@field use_treesitter boolean

---@class LineNumMod: BaseMod
---@field options LineNumOpts
local line_num_mod = BaseMod:new({
    name = "line_num",
    options = {
        enable = true,
        notify = true,
        use_treesitter = false,
        style = "#806d9c",
        support_filetypes = ft.support_filetypes,
        exclude_filetypes = ft.exclude_filetypes,
        choke_at_linecount = -1,
    },
})

function line_num_mod:render()
    if
        not self.options.enable
        or self.options.exclude_filetypes[vim.bo.ft]
        or BaseMod.check_choke(self, vim.api.nvim_buf_line_count(0))
    then
        return
    end

    self:clear()
    self.ns_id = api.nvim_create_namespace(self.name)

    local retcode, cur_chunk_range = utils.get_chunk_range(self, nil, {
        use_treesitter = self.options.use_treesitter,
    })
    if retcode ~= CHUNK_RANGE_RET.OK then
        return
    end

    local beg_row, end_row = unpack(cur_chunk_range)
    for i = beg_row, end_row do
        local row_opts = {}
        row_opts.number_hl_group = "HLLine_num1"
        api.nvim_buf_set_extmark(0, self.ns_id, i - 1, 0, row_opts)
    end
end

function line_num_mod:enable_mod_autocmd()
    BaseMod.enable_mod_autocmd(self)

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = self.augroup_name,
        pattern = self.options.support_filetypes,
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = line_num_mod.old_win_info

            if cur_win_info.lnum ~= old_win_info.lnum or cur_win_info.leftcol ~= old_win_info.leftcol then
                line_num_mod.old_win_info = cur_win_info
                line_num_mod:render()
            end
        end,
    })
end

return line_num_mod
