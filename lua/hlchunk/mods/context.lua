local utils = require("hlchunk.utils.utils")
local api = vim.api
local fn = vim.fn

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

local context_mod = require("hlchunk.base_mod"):new({
    name = "context",
    options = {
        enable = false,
        use_treesitter = false,
        chars = {
            "┃", -- Box Drawings Heavy Vertical
        },
        style = {
            { "#806d9c", "" },
        },
        exclude_filetype = exclude_ft,
    },
})

local ns_id = -1

function context_mod:render()
    if (not self.options.enable) or self.options.exclude_filetype[vim.bo.filetype] then
        return
    end

    self:clear()

    local indent_range = utils.get_indent_range()
    if not indent_range then
        return
    end
    local beg_row, end_row = unpack(indent_range)
    ns_id = api.nvim_create_namespace("hl_context")

    local start_col = math.min(fn.indent(beg_row), fn.indent(end_row))
    local row_opts = {
        virt_text_pos = "overlay",
        virt_text_win_col = start_col,
        hl_mode = "combine",
        priority = 99,
    }

    -- render middle section
    for i = beg_row, end_row do
        row_opts.virt_text = { { self.options.chars[1], "HLContextStyle1" } }
        row_opts.virt_text_win_col = start_col
        ---@diagnostic disable-next-line: undefined-field
        local space_tab = (" "):rep(vim.o.shiftwidth)
        local line_val = fn.getline(i):gsub("\t", space_tab)
        if #fn.getline(i) <= start_col or line_val:sub(start_col + 1, start_col + 1):match("%s") then
            api.nvim_buf_set_extmark(0, ns_id, i - 1, 0, row_opts)
        end
    end
end

function context_mod:clear()
    if ns_id ~= -1 then
        api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
    end
end

function context_mod:enable_mod_autocmd()
    api.nvim_create_augroup("hl_context_augroup", { clear = true })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
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
    api.nvim_del_augroup_by_name("hl_context_augroup")
end

function context_mod:create_mod_usercmd()
    api.nvim_create_user_command("EnableHLContext", function()
        context_mod:enable()
    end, {})
    api.nvim_create_user_command("DisableHLContext", function()
        context_mod:disable()
    end, {})
end

function context_mod:disable()
    pcall(function()
        self.options.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
end

function context_mod:enable()
    pcall(function()
        self.options.enable = true
        self:set_hl(self.options.style)
        self:render()
        self:enable_mod_autocmd()
    end)
end

return context_mod
