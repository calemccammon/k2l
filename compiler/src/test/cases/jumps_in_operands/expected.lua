local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function allEqual(a, b)
    if a.size ~= b.size then
        return false
    end
    for i = 0, a.size - 1 do
        local ____cond = a[i + 1] == b:get(i)
        if not ____cond then
            do return false end
            ____cond = nil
        end
    end
    return true
end

local function noneNegative(xs)
    for ____i = 1, xs.size do
        local x = xs[____i]
        if x > 100 then
            local big = x
            local ____cond_2 = big < 1000
            if not ____cond_2 then
                do return false end
                ____cond_2 = nil
            end
        else
            local ____cond_1 = x >= 0
            if not ____cond_1 then
                do return false end
                ____cond_1 = nil
            end
        end
    end
    return true
end

local function firstGap(xs)
    local last = -1
    for ____i_1 = 1, xs.size do
        local x = xs[____i_1]
        local ____cond_3 = x == last + 1
        if not ____cond_3 then
            do break end
            ____cond_3 = nil
        end
        last = x
    end
    return last + 1
end

local function countEven(xs)
    local n = 0
    for ____i_2 = 1, xs.size do
        local x = xs[____i_2]
        do
            local ____cond_4 = x % 2 == 0
            if not ____cond_4 then
                goto ____continue
                ____cond_4 = nil
            end
            n = n + 1
        end
        ::____continue::
    end
    return n
end

local function guarded(x)
    local ____ok, ____result, ____returned = pcall(function()
        local ____cond_5 = x ~= nil and x > 0
        if not ____cond_5 then
            do return true, "not positive" end
            ____cond_5 = nil
        end
        local ____cond_6 = __K2L_NotNull(x) < 10
        if ____cond_6 then
            do return true, "small" end
            ____cond_6 = nil
        end
    end)
    print("checked " .. __K2L_Str(x))
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
    return "large"
end

local function describe(x)
    local result
    if type(x) == "string" then
        local s = x
        result = "string of " .. #s
    else
        result = "other"
    end
    local label
    if math.type(x) == "integer" then
        local n = x
        label = "int " .. n + 1
    else
        label = "?"
    end
    return result .. "/" .. label
end

local function main()
    print(allEqual(__K2L_ListOf(1, 2, 3), __K2L_ListOf(1, 2, 3)))
    print(allEqual(__K2L_ListOf(1, 2, 3), __K2L_ListOf(1, 5, 3)))
    print(noneNegative(__K2L_ListOf(1, 200, 3)))
    print(noneNegative(__K2L_ListOf(1, 2000, 3)))
    print(noneNegative(__K2L_ListOf(1, -2, 3)))
    print(firstGap(__K2L_ListOf(0, 1, 2, 4, 5)))
    print(countEven(__K2L_ListOf(1, 2, 3, 4, 6)))
    print(guarded(nil))
    print(guarded(5))
    print(guarded(50))
    print(describe("abc"))
    print(describe(41))
end

__K2L_RunMain(main)
return {allEqual = allEqual, noneNegative = noneNegative, firstGap = firstGap, countEven = countEven, guarded = guarded, describe = describe}
