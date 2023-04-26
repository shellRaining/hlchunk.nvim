local BaseMod = require("hlchunk.base_mod")

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

local chunk_mod = BaseMod:new({
    name = "chunk",
    options = {
        enable = true,
        use_treesitter = false,
        support_filetypes = support_ft,
        exclude_filetype = exclude_ft,
        chars = {
            horizontal_line = "─",
            vertical_line = "│",
            left_top = "╭",
            left_bottom = "╰",
            right_arrow = ">",
        },
        style = {
            hibiscus = "#806d9c",
            primrose = "#c06f98",
        },
    },
    old_win_info = fn.winsaveview(),
})

-- set new virtual text to the right place
function chunk_mod:render()
    if not self.options.enable or self.options.exclude_filetype[vim.bo.ft] then
        return
    end

    self:clear()
    self.ns_id = api.nvim_create_namespace("hlchunk")

    local cur_chunk_range = self.options.use_treesitter and utils.get_chunk_range_ts() or utils.get_chunk_range()
    if cur_chunk_range and cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local beg_blank_len = fn.indent(beg_row)
        local end_blank_len = fn.indent(end_row)
        local start_col = math.max(math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth, 0)
        local offset = fn.winsaveview().leftcol

        local row_opts = {
            virt_text_pos = "overlay",
            hl_mode = "combine",
            priority = 100,
        }

        -- render beg_row
        if beg_blank_len > 0 then
            local virt_text_len = beg_blank_len - start_col
            local beg_virt_text = self.options.chars.left_top
                .. self.options.chars.horizontal_line:rep(virt_text_len - 1)

            if not utils.col_in_screen(start_col) then
                local utfBeg = vim.str_byteindex(beg_virt_text, math.min(offset - start_col, virt_text_len))
                beg_virt_text = beg_virt_text:sub(utfBeg + 1)
            end

            row_opts.virt_text = { { beg_virt_text, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = math.max(start_col - offset, 0)
            api.nvim_buf_set_extmark(0, self.ns_id, beg_row - 1, 0, row_opts)
        end

        -- render end_row
        if end_blank_len > 0 then
            local virt_text_len = end_blank_len - start_col
            local end_virt_text = self.options.chars.left_bottom
                .. self.options.chars.horizontal_line:rep(end_blank_len - start_col - 2)
                .. self.options.chars.right_arrow

            if not utils.col_in_screen(start_col) then
                local utfBeg = vim.str_byteindex(end_virt_text, math.min(offset - start_col, virt_text_len))
                end_virt_text = end_virt_text:sub(utfBeg + 1)
            end
            row_opts.virt_text = { { end_virt_text, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = math.max(start_col - offset, 0)
            api.nvim_buf_set_extmark(0, self.ns_id, end_row - 1, 0, row_opts)
        end

        -- render middle section
        for i = beg_row + 1, end_row - 1 do
            row_opts.virt_text = { { self.options.chars.vertical_line, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = start_col - offset
            local space_tab = (" "):rep(vim.o.shiftwidth)
            local line_val = fn.getline(i):gsub("\t", space_tab)
            if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
                if utils.col_in_screen(start_col) then
                    api.nvim_buf_set_extmark(0, self.ns_id, i - 1, 0, row_opts)
                end
            end
        end
    end
end

function chunk_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_chunk_augroup", { clear = true })
    api.nvim_create_autocmd({ "TextChanged" }, {
        group = "hl_chunk_augroup",
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_chunk_augroup",
        pattern = self.options.support_filetypes,
        callback = function()
            local cur_win_info = fn.winsaveview()
            local old_win_info = chunk_mod.old_win_info

            if cur_win_info.lnum ~= old_win_info.lnum or cur_win_info.leftcol ~= old_win_info.leftcol then
                chunk_mod.old_win_info = cur_win_info
                chunk_mod:render()
            end
        end,
    })
end

function chunk_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_chunk_augroup")
end

return chunk_mod
