local api = vim.api

local tsUtils = {}

---@param ft string
---@return string | nil
function tsUtils.get_lang(ft)
    local lang = vim.treesitter.language.get_lang(ft)
    if lang then
        return lang
    end

    for sub_ft in vim.gsplit(ft, ".", { plain = true }) do
        lang = vim.treesitter.language.get_lang(sub_ft)
        if lang then
            return lang
        end
    end

    return nil
end

function tsUtils.get_buf_lang(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local ft = api.nvim_buf_get_option(bufnr, "ft")
    return tsUtils.get_lang(ft)
end

function tsUtils.get_parser(bufnr, lang)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    lang = lang or tsUtils.get_buf_lang(bufnr)
    return lang
end

return tsUtils
