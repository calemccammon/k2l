local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unit = ____lualib.__K2L_Unit

local function id(x)
    return x
end

local function t(label, f)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
            local e = ____error
            print(label .. " IOOBE: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print(label .. " NSEE: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print(label .. " AE: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(label .. " IAE: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " OTHER: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    local s = "hello"
    local e = ""
    t("s[1]", function() return __K2L_StringCharAt(s, id(1)) end)
    t("s[5]", function() return __K2L_StringCharAt(s, id(5)) end)
    t("s[-1]", function() return __K2L_StringCharAt(s, id(-1)) end)
    t("e[0]", function() return __K2L_StringCharAt(e, id(0)) end)
    t("sub(2)", function() return __K2L_Text.substring(s, id(2)) end)
    t("sub(5)", function() return __K2L_Text.substring(s, id(5)) end)
    t("sub(6)", function() return __K2L_Text.substring(s, id(6)) end)
    t("sub(-1)", function() return __K2L_Text.substring(s, id(-1)) end)
    t("sub(1,3)", function() return __K2L_Text.substring(s, id(1), id(3)) end)
    t("sub(3,1)", function() return __K2L_Text.substring(s, id(3), id(1)) end)
    t("sub(0,9)", function() return __K2L_Text.substring(s, id(0), id(9)) end)
    t("sub(-1,2)", function() return __K2L_Text.substring(s, id(-1), id(2)) end)
    t("sub(5,5)", function() return __K2L_Text.substring(s, id(5), id(5)) end)
    t("sub(0..2)", function()
        return __K2L_Text.substringOf(s, __K2L_IntRange.new(0, id(2)))
    end)
    t("sub(0..9)", function()
        return __K2L_Text.substringOf(s, __K2L_IntRange.new(0, id(9)))
    end)
    t("subSeq(1,3)", function() return __K2L_Text.substring(s, id(1), id(3)) end)
    t("subSeq(1,9)", function() return __K2L_Text.substring(s, id(1), id(9)) end)
    t("subSeq(3,1)", function() return __K2L_Text.substring(s, id(3), id(1)) end)
    t("first", function() return __K2L_Text.first(s) end)
    t("e.first", function() return __K2L_Text.first(e) end)
    t("last", function() return __K2L_Text.last(s) end)
    t("e.last", function() return __K2L_Text.last(e) end)
    t("e.single", function() return __K2L_Text.single(e) end)
    t("take(-1)", function() return __K2L_Text.take(s, id(-1)) end)
    t("drop(-1)", function() return __K2L_Text.drop(s, id(-1)) end)
    t("takeLast(-1)", function() return __K2L_Text.takeLast(s, id(-1)) end)
    t("dropLast(-1)", function() return __K2L_Text.dropLast(s, id(-1)) end)
    t("take(9)", function() return __K2L_Text.take(s, id(9)) end)
    t("drop(9)", function() return __K2L_Text.drop(s, id(9)) end)
    t("substringBefore", function() return __K2L_Text.substringBefore(s, "z") end)
    t("repeat(-1)", function() return __K2L_Text.repeatCount(s, id(-1)) end)
    t("padStart(-1)", function() return __K2L_StringPadStart(s, id(-1)) end)
    t("removeRange(3,1)", function()
        return __K2L_Text.removeRange(s, id(3), id(1))
    end)
    t("elementAt(9)", function() return __K2L_Text.get(s, id(9)) end)
    t("chunked(0)", function() return __K2L_Text.chunked(s, id(0)) end)
    t("windowed(0)", function() return __K2L_Text.windowed(s, id(0)) end)
    t("toInt", function() return __K2L_StringToInt("x") end)
    t("digitToInt", function() return __K2L_Num.digitToInt("x") end)
    local list = __K2L_ReadOnlyListOf(1, 2, 3)
    local mlist = __K2L_ListOf(1, 2, 3)
    local arr = __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2, 3)
    local ia = __K2L_TypedArrayOf("[I", 1, 2, 3)
    t("list[3]", function() return list:get(id(3)) end)
    t("list[-1]", function() return list:get(id(-1)) end)
    t("list.get(3)", function() return list:get(id(3)) end)
    t("mlist[3]", function() return mlist:get(id(3)) end)
    t("arr[3]", function() return arr:get(id(3)) end)
    t("arr[-1]", function() return arr:get(id(-1)) end)
    t("ia[3]", function() return ia:get(id(3)) end)
    t("mlist[3]=", function()
        local ____key = id(3)
        mlist:set(____key, 1)
        return __K2L_Unit
    end)
    t("mlist[-1]=", function()
        local ____key_1 = id(-1)
        mlist:set(____key_1, 1)
        return __K2L_Unit
    end)
    t("arr[3]=", function()
        local ____key_2 = id(3)
        arr:set(____key_2, 1)
        return __K2L_Unit
    end)
    t("ia[5]=", function()
        local ____key_3 = id(5)
        ia:set(____key_3, 1)
        return __K2L_Unit
    end)
    t("ia[3]+=", function()
        local ____key_4 = id(3)
        ia:set(____key_4, ia:get(____key_4) + 1)
        return __K2L_Unit
    end)
    t("list.first", function() return __K2L_ReadOnlyListOf():first() end)
    t("list.last", function() return __K2L_ReadOnlyListOf():last() end)
    t("list.take(-1)", function() return list:take(id(-1)) end)
    t("list.drop(-1)", function() return list:drop(id(-1)) end)
    t("list.elementAt", function() return list:elementAt(id(7)) end)
    t("list.subList", function() return list:subList(id(2), id(9)) end)
    t("list.subList2", function() return list:subList(id(2), id(1)) end)
    t("mlist.removeAt", function() return mlist:removeAt(id(9)) end)
    t("mlist.add", function()
        mlist:addAt(id(9), 1)
        return __K2L_Unit
    end)
    t("list.single", function() return list:single() end)
    t("list.chunked", function() return list:chunked(id(0)) end)
    t("list.windowed", function() return list:windowed(id(0)) end)
    t("list.max", function() return __K2L_ReadOnlyListOf():max() end)
    t("list.reduce", function()
        return __K2L_ReadOnlyListOf():reduce(function(a, b) return a + b end)
    end)
    t("list.random", function()
        return __K2L_ReadOnlyListOf():random(__K2L_Random.default())
    end)
    t("ints.avg", function() return __K2L_ReadOnlyListOf():average() end)
    t("div", function() return __K2L_IDiv(1, id(0)) end)
    t("rem", function() return __K2L_IRem(1, id(0)) end)
    t("rem fn", function() return __K2L_IRem(1, id(0)) end)
    t("mod", function() return __K2L_Num.mod(1, id(0)) end)
    t("floorDiv", function() return __K2L_FloorDiv(1, id(0)) end)
    t("ldiv", function() return __K2L_IDiv(1, id(0)) end)
    t("lrem", function() return __K2L_IRem(1, id(0)) end)
    t("lmod", function() return __K2L_Num.mod(1, id(0)) end)
    t("fdiv", function() return 1.0 / id(0) end)
    t("frem", function() return math.fmod(1.5, id(0) + 0.0) end)
    t("frem2", function() return math.fmod(-1.5, 0.0) end)
    t("frem3", function() return math.fmod(5.5, -2.0) end)
    t("frem4", function() return math.fmod(-5.5, 2.0) end)
    t("fmod", function() return -5.5 % 2.0 end)
    t("fmod0", function() return 5.5 % 0.0 end)
    t("zero div", function() return 0.0 / 0.0 end)
    t("imod", function() return __K2L_Num.mod(-7, id(3)) end)
    t("imod2", function() return __K2L_Num.mod(7, id(-3)) end)
    t("ifloor", function() return __K2L_FloorDiv(-7, id(2)) end)
    t("irem", function() return __K2L_IRem(-7, id(3)) end)
    t("irem2", function() return __K2L_IRem(7, id(-3)) end)
    local data = __K2L_TypedArrayOf("[I", 5, 6, 7)
    local text = "abc"
    local numbers = __K2L_ReadOnlyListOf(1, 2, 3)
    local total = 0
    for i = 0, data.size - 1 do
        total = total + data[i + 1]
    end
    for i = 0, numbers.size - 1 do
        total = total + numbers[i + 1]
    end
    local ____range = __K2L_IntRange.new(0, #text - 1)
    for i = ____range.first, ____range.last, ____range.step do
        total = total + text:sub(i + 1, i + 1):byte()
    end
    for i = numbers.size - 1, 0, -1 do
        total = total + numbers[i + 1]
    end
    for i = 0, #text - 1 do
        total = total + text:sub(i + 1, i + 1):byte()
    end
    for i = 0, data.size - 1 do
        data[i + 1] = data[i + 1] * 2
    end
    print(total)
    print(__K2L_Str(data:toList()))
    t("loop+1", function()
        local x = 0
        for i = 0, data.size - 1 do
            x = x + data:get(i + 1)
        end
        return x
    end)
end

main()
return {id = id, t = t}
