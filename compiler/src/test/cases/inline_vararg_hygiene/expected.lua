local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unpack = ____lualib.__K2L_Unpack

local limit = 3
local prefix = "p"

local function withVararg(f, ...)
    local xs = __K2L_ArrayOf(...)
    for ____i = 1, xs.size do
        local x = xs[____i]
        f(x)
    end
end

local function sumAll(base, f, ...)
    local xs = __K2L_ArrayOf(...)
    local total = base
    for ____i_1 = 1, xs.size do
        local x = xs[____i_1]
        total = total + f(x)
    end
    return total + xs.size
end

local function label(...)
    local parts = __K2L_ArrayOf(...)
    return parts:joinToString("-")
end

local function capped(n, f)
    for i = 0, limit - 1 do
        f(n + i)
    end
end

local function tagged(n, f)
    f(prefix .. n)
end

local function outer(n, f)
    capped(n, f)
end

local function varargs()
    do
        local xs = __K2L_ArrayOf(1, 2, 3)
        for ____i_2 = 1, xs.size do
            local x = xs[____i_2]
            if x == 2 then
                return x
            end
        end
    end
    return 0
end

local function spreads()
    local extra = __K2L_TypedArrayOf("[I", 10, 20, 30)
    local ____result
    do
        local xs = __K2L_ArrayOf(4, __K2L_Unpack(extra))
        local total = 1
        for ____i_3 = 1, xs.size do
            local x = xs[____i_3]
            local ____result_1
            if x > 25 then
                return x
            end
            ____result_1 = x * 2
            total = total + ____result_1
        end
        ____result = total + xs.size
    end
    local r = ____result
    return r
end

local function emptyVarargs()
    local a = label()
    local b = label("a", "b")
    return a .. "|" .. b
end

local function named()
    local ____result_2
    do
        local ____xs = __K2L_ArrayOf(__K2L_Unpack(__K2L_TypedArrayOf("[I", 1, 2)))
        local total = 5
        for ____i_4 = 1, ____xs.size do
            local x = ____xs[____i_4]
            local ____result_3
            if x > 100 then
                return -1
            end
            ____result_3 = x
            total = total + ____result_3
        end
        ____result_2 = total + ____xs.size
    end
    local r = ____result_2
    return r
end

local function captured()
    local ____limit = 10
    for i = 0, limit - 1 do
        do
            local it = ____limit + i
            if it > 100 then
                return it
            end
        end
    end
    return ____limit
end

local function param(____limit_1)
    for i = 0, limit - 1 do
        do
            local it = ____limit_1 + i
            if it > 100 then
                return it
            end
        end
    end
    return ____limit_1 * 2
end

local function hiddenInLoop()
    local seen = 0
    for ____limit_2 = 1, 2 do
        for i = 0, limit - 1 do
            do
                local it = ____limit_2 + i
                if it > 100 then
                    return it
                end
                seen = seen + it
            end
        end
    end
    return seen
end

local function hiddenPrefix()
    local ____prefix = "local"
    local r = ____prefix
    do
        local it = prefix .. 1
        if it == "zzz" then
            return "no"
        end
        r = r .. it
    end
    return r
end

local function nested()
    local ____limit_3 = 7
    local total = 0
    for i = 0, limit - 1 do
        do
            local it = ____limit_3 + i
            if it > 100 then
                return it
            end
            total = total + it
        end
    end
    return total + ____limit_3
end

local function main()
    print(varargs())
    print(spreads())
    print(emptyVarargs())
    print(named())
    print(captured())
    print(param(4))
    print(hiddenInLoop())
    print(hiddenPrefix())
    print(nested())
end

__K2L_Main(main)
return {limit = limit, prefix = prefix, withVararg = withVararg, sumAll = sumAll, label = label, capped = capped, tagged = tagged, outer = outer, varargs = varargs, spreads = spreads, emptyVarargs = emptyVarargs, named = named, captured = captured, param = param, hiddenInLoop = hiddenInLoop, hiddenPrefix = hiddenPrefix, nested = nested}
