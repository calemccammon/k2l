local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str

local Builder = __K2L_Class("Builder")

function Builder:____init(bang)
    self.bang = bang
    self.parts = __K2L_ListOf()
end

function Builder:unaryPlus(____this)
    self.parts:add(____this .. self.bang)
end

function Builder:shout(____this_1)
    return ____this_1:upper() .. self.bang
end

function Builder:twice(____this_2)
    return ____this_2 * 2 + self.parts.size
end

function Builder:fromInside()
    return __K2L_ListOf("x", "y"):map(function(it) return self:shout(it) end):plusAll(__K2L_ListOf("p"):map(function(s) return self:shout(s) end))
end

function Builder:inside()
    return __K2L_ListOf(1, 2):map(function(it) return self:twice(it) end)
end

function Builder:deferred()
    local f = function(s) return self:shout(s) end
    return function() return f("later") .. self:twice(3) end
end

local function main()
    local b = Builder.new("!")
    do
        for _, it in ipairs(__K2L_ListOf("a", "b")) do
            b:unaryPlus(it)
        end
        for _, it in ipairs(__K2L_ListOf("c")) do
            b:unaryPlus(it)
        end
        print(__K2L_Str(__K2L_ListOf("m", "n"):map(function(it) return b:shout(it) end)))
        local f = function(it) return b:shout(it) end
        print(f("with"))
        local g = function(n) return b:twice(n) end
        print(g(4))
    end
    print(__K2L_Str(b.parts))
    print(__K2L_Str(b:fromInside()))
    print(__K2L_Str(b:inside()))
    print(b:deferred()())
    local ____result
    ____result = function(s) return b:shout(s) end
    local h = ____result
    print(h("held"))
    local ____result_1
    ____result_1 = b:shout("q") .. b:twice(5)
    print(____result_1)
end

main()
return {Builder = Builder}
