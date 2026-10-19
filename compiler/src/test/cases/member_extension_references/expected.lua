local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
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
    return __K2L_ReadOnlyListOf("x", "y"):map(function(it) return self:shout(it) end):plusAll(__K2L_SingletonListOf("p"):map(function(s) return self:shout(s) end))
end

function Builder:inside()
    return __K2L_ReadOnlyListOf(1, 2):map(function(it) return self:twice(it) end)
end

function Builder:deferred()
    local f = function(s) return self:shout(s) end
    return function() return f("later") .. self:twice(3) end
end

local function main()
    local b = Builder.new("!")
    do
        local ____list = __K2L_ReadOnlyListOf("a", "b")
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local it = ____list[____i]
            b:unaryPlus(it)
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
        local ____list_1 = __K2L_SingletonListOf("c")
        for ____i_1 = 1, ____list_1.size do
            local it = ____list_1[____i_1]
            b:unaryPlus(it)
        end
        print(__K2L_Str(__K2L_ReadOnlyListOf("m", "n"):map(function(it) return b:shout(it) end)))
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
