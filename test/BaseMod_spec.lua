package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")

function Test()
end

os.exit(luaunit.LuaUnit.run())
