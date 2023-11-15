package.path = package.path .. ";../lua/?.lua"

local luaunit = require("luaunit")
local class = require("hlchunk.utils.class")

local TestClass = class(function() end)
function TestClass:testAddPositive()
    ---@class Base
    ---@field name string
    local Base = class(function(_, name)
        _.name = name
    end)
    function Base:__string()
        return self.name
    end

    local base = Base("base")
    luaunit.assertEquals(base.name, "base")
end

os.exit(luaunit.LuaUnit.run())
