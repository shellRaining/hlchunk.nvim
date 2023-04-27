local utils = require("hlchunk.utils.utils")
local api = vim.api
local fn = vim.fn

local support_ft = {
    "*.ts",
    "*.tsx",
    "*.js",
    "*.jsx",
    "*.html",
    "*.json",
    "*.go",
    "*.c",
    "*.lua",
    "*.py",
    "*.cpp",
    "*.rs",
    "*.h",
    "*.hpp",
    "*.lua",
    "*.vue",
}

local exclude_ft = {
    aerial = true,
    dashboard = true,
    help = true,
    lspinfo = true,
    lspsagafinder = true,
    packer = true,
    checkhealth = true,
    man = true,
    mason = true,
    NvimTree = true,
    ["neo-tree"] = true,
    plugin = true,
    lazy = true,
    TelescopePrompt = true,
    [""] = true, -- because TelescopePrompt will set a empty ft, so add this.
}

local line_num_mod = require("hlchunk.base_mod"):new({
    name = "line_num",
    options = {
        use_treesitter = false,
        enable = true,
        style = "#806d9c",
        support_filetypes = support_ft,
        exclude_filetype = exclude_ft,
    },
})

function line_num_mod:render()
    if not self.options.enable or self.options.exclude_filetype[vim.bo.ft] then
        return
    end

    self:clear()

    local cur_chunk_range = self.options.use_treesitter and utils.get_chunk_range_ts() or utils.get_chunk_range()
    if cur_chunk_range and cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        for i = beg_row, end_row do
            ---@diagnostic disable-next-line: param-type-mismatch
            fn.sign_place("", "LineNumberGroup", "sign1", fn.bufname("%"), {
                lnum = i,
            })
        end
    end
end

function line_num_mod:clear()
    fn.sign_unplace("LineNumberGroup", {
        ---@diagnostic disable-next-line: param-type-mismatch
        buffer = fn.bufname("%"),
    })
end

function line_num_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_line_augroup", { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_line_augroup",
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

function line_num_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_line_augroup")
end

function line_num_mod:set_signs()
    if type(self.options.style) == "table" then
        local tbl = {}
        for i = 1, 1 do
            local sign_name = "sign" .. tostring(i)
            local hl_name = "HLLineNumStyle" .. tostring(i)
            tbl[#tbl + 1] = { name = sign_name, numhl = hl_name }
        end
        fn.sign_define(tbl)
    else
        fn.sign_define("sign1", {
            numhl = "HLLineNumStyle1",
        })
    end
end

function line_num_mod:enable()
    local ok, _ = pcall(function()
        self.options.enable = true
        self:set_hl(self.options.style)
        self:set_signs()
        self:render()
        self:enable_mod_autocmd()
        self:create_mod_usercmd()
    end)
    if not ok then
        vim.notify("you have disable line_num mod")
    end
end

return line_num_mod
