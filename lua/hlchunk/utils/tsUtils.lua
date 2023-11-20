local api = vim.api
local ts = vim.treesitter

local tsUtils = {}

---@param ft string
---@return string | nil
-- get language from file type, If the suffix name is separated by dots, it will find the full filetype, if not found,
-- each unit will be searched separately until found, otherwise nil will be returned.
-- like `typescript.tsx` will return `tsx`
-- like `jest.typescript` will return `typescript`
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

---@param bufnr? number if not provided, use current buffer
---@return string | nil
function tsUtils.get_buf_lang(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local ft = api.nvim_buf_get_option(bufnr, "ft")
    return tsUtils.get_lang(ft)
end

---@param lang? string if not provided, use current buffer lang
---@return boolean
function tsUtils.has_parser(lang)
    lang = lang or tsUtils.get_buf_lang(api.nvim_get_current_buf())

    if not lang or #lang == 0 then
        return false
    end
    if vim._ts_has_language(lang) then
        return true
    end
    return false
end

---@param bufnr? number if not provided, use current buffer
---@param lang? string if not provided, use current buffer lang
---@return LanguageTree | nil
function tsUtils.get_parser(bufnr, lang)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    lang = lang or tsUtils.get_buf_lang(bufnr)

    if tsUtils.has_parser(lang) then
        return ts.get_parser(bufnr, lang)
    end
    return nil
end

return tsUtils
