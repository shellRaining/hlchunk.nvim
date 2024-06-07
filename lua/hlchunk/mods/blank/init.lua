local IndentMod = require("hlchunk.mods.indent")
local BlankConf = require("hlchunk.mods.blank.blank_conf")
local class = require("hlchunk.utils.class")
local cFunc = require("hlchunk.utils.cFunc")

local api = vim.api
local fn = vim.fn

local constuctor = function(self, conf, meta)
    local default_meta = {
        name = "blank",
        augroup_name = "hlchunk_blank",
        hl_base_name = "HLBlank",
        ns_id = api.nvim_create_namespace("blank"),
    }

    IndentMod.init(self, conf, meta)
    self.meta = vim.tbl_deep_extend("force", default_meta, meta or {})
    self.conf = BlankConf(conf)
end

---@class BlankMod: IndentMod
---@overload fun(conf?: UserIndentConf, meta?: MetaInfo): IndentMod
local BlankMod = class(IndentMod, constuctor)

function BlankMod:renderLeader(bufnr, index, offset, shadow_char_num, row_opts)
    if offset == 0 then
        return
    end

    local leaderChar = self.conf.chars[(shadow_char_num - 1) % #self.conf.chars + 1]
    local leaderTextStyle = self.meta.hl_name_list[(shadow_char_num - 1) % #self.meta.hl_name_list + 1]
    local leaderText = ""
    for _ = 1, offset do
        leaderText = leaderText .. leaderChar
    end
    row_opts.virt_text = { { leaderText, leaderTextStyle } }
    api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, index - 1, 0, row_opts)
end

function BlankMod:renderLine(bufnr, index, blankLen)
    local row_opts = {
        virt_text_pos = "overlay",
        hl_mode = "combine",
        priority = self.conf.priority,
    }
    local leftcol = fn.winsaveview().leftcol --[[@as number]]
    local sw = cFunc.get_sw(bufnr)
    local render_char_num, offset, shadow_char_num = cFunc.calc(blankLen, leftcol, sw)

    self:renderLeader(bufnr, index, offset, shadow_char_num, row_opts)
    for i = 1, render_char_num do
        local char = self.conf.chars[(i - 1 + shadow_char_num) % #self.conf.chars + 1]
        local text = ""
        for _ = 1, sw do
            text = text .. char
        end
        local style = self.meta.hl_name_list[(i - 1 + shadow_char_num) % #self.meta.hl_name_list + 1]
        row_opts.virt_text = { { text, style } }
        row_opts.virt_text_win_col = offset + (i - 1) * sw

        -- when use treesitter, without this judge, when paste code will over render
        if row_opts.virt_text_win_col < 0 or row_opts.virt_text_win_col >= cFunc.get_indent(bufnr, index - 1) then
            -- if the len of the line is 0, and have leftcol, we should draw it indent by context
            if api.nvim_buf_get_lines(bufnr, index - 1, index, false)[1] ~= "" then
                return
            end
        end
        api.nvim_buf_set_extmark(bufnr, self.meta.ns_id, index - 1, 0, row_opts)
    end
end

return BlankMod
