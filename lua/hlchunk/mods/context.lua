local context_mod = require("hlchunk.base_mod"):new({
    name = "context",
})

local ns_id = -1

function context_mod:render()
    if (not PLUG_CONF.context.enable) or PLUG_CONF.context.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()

    local indent_range = UTILS.get_indent_range()
    if not indent_range then
        return
    end
    local beg_row, end_row = unpack(indent_range)
    ns_id = API.nvim_create_namespace("hl_context")

    local start_col = math.min(FN.indent(beg_row), FN.indent(end_row))
    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
        hl_mode = "combine",
        priority = 99,
    }
    -- render middle section
    for i = beg_row, end_row do
        row_opts.virt_text = { { PLUG_CONF.context.chars[1], "HLContextStyle1" } }
        row_opts.virt_text_win_col = start_col
        ---@diagnostic disable-next-line: undefined-field
        local line_val = FN.getline(i):gsub("\t", SPACE_TAB)
        if #FN.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
            API.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
        end
    end
end

function context_mod:clear()
    if ns_id ~= -1 then
        API.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function context_mod:enable_mod_autocmd()
    API.nvim_create_augroup("hl_context_augroup", { clear = true })
    API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
        group = "hl_context_augroup",
        pattern = "*",
        callback = function()
            local ok, info = pcall(context_mod.render, context_mod)
            if not ok then
                vim.notify(tostring(info))
            end
        end,
    })
end

function context_mod:disable_mod_autocmd()
    API.nvim_del_augroup_by_name("hl_context_augroup")
end

function context_mod:create_mod_usercmd() end

function context_mod:disable()
    pcall(function()
        PLUG_CONF.context.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
end

function context_mod:enable()
    pcall(function()
        PLUG_CONF.context.enable = true
        self:render()
        self:enable_mod_autocmd()
    end)
end

return context_mod
