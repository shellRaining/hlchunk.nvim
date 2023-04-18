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
    "*.cpp",
    "*.rs",
    "*.h",
    "*.hpp",
    "*.lua",
    "*.vue",
}

local chunk_mod = BaseMod:new({
    name = "chunk",
    options = {
        enable = true,
        support_filetypes = support_ft,
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
})

local ns_id = -1

-- set new virtual text to the right place
function chunk_mod:render()
    if not self.options.enable then
        return
    end

    self:clear()
    ns_id = api.nvim_create_namespace("hlchunk")

    local cur_chunk_range = utils.get_chunk_range()
    if cur_chunk_range and cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local beg_blank_len = fn.indent(beg_row)
        local end_blank_len = fn.indent(end_row)
        local start_col = math.max(math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth, 0)

        local row_opts = {
            virt_text_pos = "overlay",
            virt_text_win_col = start_col,
            hl_mode = "combine",
            priority = 100,
        }

        -- render beg_row
        if beg_blank_len > 0 then
            local beg_virt_text = self.options.chars.left_top
                .. self.options.chars.horizontal_line:rep(beg_blank_len - start_col - 1)

            row_opts.virt_text = { { beg_virt_text, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = start_col
            api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, row_opts)
        end

        -- render end_row
        if end_blank_len > 0 then
            local end_virt_text = self.options.chars.left_bottom
                .. self.options.chars.horizontal_line:rep(end_blank_len - start_col - 2)
                .. self.options.chars.right_arrow
            row_opts.virt_text = { { end_virt_text, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = start_col
            api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, row_opts)
        end

        -- render middle section
        for i = beg_row + 1, end_row - 1 do
            start_col = math.max(0, start_col)
            row_opts.virt_text = { { self.options.chars.vertical_line, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = start_col
            local space_tab = (" "):rep(vim.o.shiftwidth)
            local line_val = fn.getline(i):gsub("\t", space_tab)
            if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
                api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
            end
        end
    end
end

-- clear the virtual text marked before
function chunk_mod:clear()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function chunk_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_chunk_augroup", { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged" }, {
        group = "hl_chunk_augroup",
        pattern = self.options.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
end

function chunk_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_chunk_augroup")
end

return chunk_mod
