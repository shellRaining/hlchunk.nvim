local BaseMod = require("hlchunk.base_mod")

local utils = require("hlchunk.utils.utils")
local api = vim.api
local fn = vim.fn

local chunk_mod = BaseMod:new({
    name = "chunk",
})

local ns_id = -1

-- set new virtual text to the right place
function chunk_mod:render()
    if not PLUG_CONF.chunk.enable then
        return
    end

    self:clear()
    ns_id = api.nvim_create_namespace("hlchunk")

    local cur_chunk_range = utils.get_chunk_range()
    if cur_chunk_range[1] < cur_chunk_range[2] then
        local beg_row, end_row = unpack(cur_chunk_range)
        local beg_blank_len = fn.indent(beg_row)
        local end_blank_len = fn.indent(end_row)
        local start_col = math.min(beg_blank_len, end_blank_len) - vim.o.shiftwidth

        local row_opts = {
            virt_text_pos = "overlay",
            virt_text_win_col = start_col,
            hl_mode = "combine",
            priority = 100,
        }
        -- render beg_row and end_row
        if start_col >= 0 then
            local beg_virt_text = PLUG_CONF.chunk.chars.left_top
                .. PLUG_CONF.chunk.chars.horizontal_line:rep(beg_blank_len - start_col - 1)
            local end_virt_text = PLUG_CONF.chunk.chars.left_bottom
                .. PLUG_CONF.chunk.chars.horizontal_line:rep(end_blank_len - start_col - 2)
                .. PLUG_CONF.chunk.chars.right_arrow

            row_opts.virt_text = { { beg_virt_text, "HLChunkStyle1" } }
            api.nvim_buf_set_extmark(0, ns_id, beg_row - 1, 0, row_opts)
            row_opts.virt_text = { { end_virt_text, "HLChunkStyle1" } }
            api.nvim_buf_set_extmark(0, ns_id, end_row - 1, 0, row_opts)
        end

        -- render middle section
        for i = beg_row + 1, end_row - 1 do
            start_col = math.max(0, start_col)
            row_opts.virt_text = { { PLUG_CONF.chunk.chars.vertical_line, "HLChunkStyle1" } }
            row_opts.virt_text_win_col = start_col
            ---@diagnostic disable-next-line: undefined-field
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
        pattern = PLUG_CONF.chunk.support_filetypes,
        callback = function()
            chunk_mod:render()
        end,
    })
end

function chunk_mod:disable_mod_autocmd()
    api.nvim_del_augroup_by_name("hl_chunk_augroup")
end

function chunk_mod:create_mod_usercmd()
    api.nvim_create_user_command("EnableHLChunk", function()
        chunk_mod:enable()
    end, {})
    api.nvim_create_user_command("DisableHLChunk", function()
        chunk_mod:disable()
    end, {})
end

function chunk_mod:enable()
    local ok, _ = pcall(function()
        PLUG_CONF.chunk.enable = true
        self:render()
        self:enable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have enable this plugin")
    end
end

function chunk_mod:disable()
    local ok, _ = pcall(function()
        PLUG_CONF.chunk.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable this plugin")
    end
end

return chunk_mod
