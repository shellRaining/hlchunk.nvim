local assert = require("luassert")
local cFunc = require("hlchunk.utils.cFunc")

describe("cFunc", function()
    it("skipwhite", function()
        local str

        str = "    abc"
        assert.equals(cFunc.skipwhite(str), "a")
        str = "    "
        assert.equals(cFunc.skipwhite(str), "")
        str = ""
        assert.equals(cFunc.skipwhite(str), "")
        str = "abc"
        assert.equals(cFunc.skipwhite(str), "a")
    end)
end)
