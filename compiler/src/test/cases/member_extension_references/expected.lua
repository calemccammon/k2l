local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
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
    local ____list = __K2L_ReadOnlyListOf("x", "y")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = self:shout(it)
    end
    local ____arg = __K2L_ListWrap(____out, ____count)
    local ____list_1 = __K2L_SingletonListOf("p")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local s = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = self:shout(s)
    end
    return ____arg:plusAll(__K2L_ListWrap(____out_1, ____count_1))
end

function Builder:inside()
    local ____list_2 = __K2L_ReadOnlyListOf(1, 2)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = self:twice(it)
    end
    return __K2L_ListWrap(____out_2, ____count_2)
end

function Builder:deferred()
    local f = function(s) return self:shout(s) end
    return function() return f("later") .. self:twice(3) end
end

local function main()
    local b = Builder.new("!")
    do
        local ____list_3 = __K2L_ReadOnlyListOf("a", "b")
        local ____mod = ____list_3.____modCount
        for ____i_3 = 1, ____list_3.size do
            local it = ____list_3[____i_3]
            b:unaryPlus(it)
            if ____list_3.____modCount ~= ____mod and ____list_3:____comodified(____i_3) then
                break
            end
        end
        local ____list_4 = __K2L_SingletonListOf("c")
        for ____i_4 = 1, ____list_4.size do
            local it = ____list_4[____i_4]
            b:unaryPlus(it)
        end
        local ____list_5 = __K2L_ReadOnlyListOf("m", "n")
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_3, ____n_3 = ____list_5:____array()
        for ____i_5 = 1, ____n_3 do
            local it = ____items_3[____i_5]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = b:shout(it)
        end
        print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
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
