local class = require("hlchunk.utils.class")
local assert = require("luassert")

describe("class", function()
    local base_user_ctor, base_ctor
    local derived_user_ctor, derived_ctor
    local method = function(self)
        return self.a + self.b
    end

    before_each(function()
        base_user_ctor = function(self, a, b)
            self.a = a
            self.b = b
        end
        base_ctor = class(base_user_ctor)
        base_ctor.method = method

        derived_user_ctor = function(self, a, b, c)
            base_ctor.init(self, a, b)
            self.c = c
        end
        derived_ctor = class(base_ctor, derived_user_ctor)
    end)

    it("should init a base class", function()
        local obj = base_ctor(1, 2)
        assert.equals(obj.a, 1)
        assert.equals(obj.b, 2)
        assert.equals(obj:method(), 3)
        assert.equals(obj.init, base_user_ctor)
    end)

    it("should derive a class from a base class", function()
        local obj = derived_ctor(1, 2, 3)
        assert.equals(obj.a, 1)
        assert.equals(obj.b, 2)
        assert.equals(obj.c, 3)
        assert.equals(obj:method(), 3)
        assert.equals(obj.init, derived_user_ctor)
    end)
end)
