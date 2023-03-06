local line_num_mod = require("hlchunk.base_mod"):new({
    name = "line_num",
})

function line_num_mod:render()
    if not PLUG_CONF.line_num.enable then
        return
    end

    self:clear()

    local beg_row, end_row = unpack(CUR_CHUNK_RANGE)
    if beg_row < end_row then
        for i = beg_row, end_row do
            ---@diagnostic disable-next-line: param-type-mismatch
            FN.sign_place("", "LineNumberGroup", "sign1", FN.bufname("%"), {
                lnum = i,
            })
        end
    end
end

function line_num_mod:clear()
    FN.sign_unplace("LineNumberGroup", {
        ---@diagnostic disable-next-line: param-type-mismatch
        buffer = FN.bufname("%"),
    })
end

function line_num_mod:enable_mod_autocmd()
    API.nvim_create_augroup("hl_line_augroup", { clear = true })
    API.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "hl_line_augroup",
        pattern = PLUG_CONF.line_num.support_filetypes,
        callback = function()
            line_num_mod:render()
        end,
    })
end

function line_num_mod:disable_mod_autocmd()
    API.nvim_del_augroup_by_name("hl_line_augroup")
end

function line_num_mod:create_mod_usercmd()
    API.nvim_create_user_command("EnableHLLineNum", function()
        line_num_mod:enable()
    end, {})
    API.nvim_create_user_command("DisableHLLineNum", function()
        line_num_mod:disable()
    end, {})
end

function line_num_mod:disable()
    local ok, _ = pcall(function()
        PLUG_CONF.line_num.enable = false
        self:clear()
        self:disable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have enable this plugin")
    end
end

function line_num_mod:enable()
    local ok, _ = pcall(function()
        PLUG_CONF.line_num.enable = true
        self:render()
        self:enable_mod_autocmd()
    end)
    if not ok then
        vim.notify("you have disable this plugin")
    end
end

return line_num_mod
