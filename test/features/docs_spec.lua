--- Doc-gardening: ensure file paths referenced in AGENTS.md / ARCHITECTURE.md
--- still exist. Catches stale references after refactors.
local assert = require("luassert")
-- vim.loop is the stable name across Neovim 0.10+; vim.uv alias may be nil
-- on some builds, so prefer the long-standing one.
local uv = vim.loop

local DOCS = { "AGENTS.md", "ARCHITECTURE.md" }

--- collect every relative path-looking token from the doc body.
--- covers markdown links ](path) and backticked paths with an extension `foo/bar.lua`.
local function extractPaths(body)
    local found = {}
    local seen = {}

    local function consider(raw)
        if seen[raw] then
            return
        end
        seen[raw] = true
        -- strip anchor and line-number suffix
        local path = raw:gsub("#.*$", "")
        path = path:gsub(":%d+$", "")
        if path == "" then
            return
        end
        -- skip non-relative / placeholder / glob references
        if path:match("^https?://") then
            return
        end
        if path:match("^mailto:") then
            return
        end
        if path:match("^/") then
            return
        end
        if path:match("[%{%}%*%<%>]") then
            return
        end
        -- only validate paths that look like source/docs files (known extensions).
        -- avoids treating package names like "plenary.nvim" as file paths.
        -- note: lua patterns have no alternation, so check via a set.
        local ext = path:match("%.([a-z]+)$")
        if
            not (
                ext == "lua"
                or ext == "md"
                or ext == "toml"
                or ext == "yml"
                or ext == "yaml"
                or ext == "json"
                or ext == "sh"
            )
        then
            return
        end
        table.insert(found, path)
    end

    for link in body:gmatch("%([^)]+%)") do
        local raw = link:sub(2, -2)
        consider(raw)
    end
    for code in body:gmatch("`([^`]+)`") do
        consider(code)
    end
    return found
end

describe("doc-gardening", function()
    for _, doc in ipairs(DOCS) do
        it(doc .. " references only existing paths", function()
            local fd = assert(io.open(doc, "r"))
            local body = fd:read("*a")
            fd:close()

            local missing = {}
            for _, path in ipairs(extractPaths(body)) do
                if not uv.fs_stat(path) then
                    table.insert(missing, path)
                end
            end
            assert.equals(0, #missing, doc .. " references missing paths: " .. table.concat(missing, ", "))
        end)
    end
end)
