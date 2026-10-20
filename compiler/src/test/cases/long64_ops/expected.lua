local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_NumberFormatException = ____lualib.__K2L_NumberFormatException
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local Account = __K2L_Class("Account")

function Account:____init(id, balance)
    self.id = id
    self.balance = balance
end

function Account.new(id, balance)
    return setmetatable({id = id, balance = balance}, Account)
end

function Account:toString()
    return "Account(id=" .. self.id .. ", balance=" .. self.balance .. ")"
end

function Account:hashCode()
    return (31 * __K2L_Hash(self.id) + __K2L_Hash(self.balance) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Account:equals(other)
    return getmetatable(other) == Account and self.id == other.id and self.balance == other.balance
end

local function fib(n)
    local a = 0
    local b = 1
    for it = 0, n - 1 do
        do
            local t = a + b
            a = b
            b = t
        end
    end
    return a
end

local function collatz(start)
    local n = start
    local steps = 0
    while n ~= 1 do
        n = (n >= 0 and n % 2 or (n % 2 - 2) % (-2)) == 0 and (n >= 0 and n // 2 or (n + 1) // 2) or 3 * n + 1
        steps = steps + 1
    end
    return steps
end

local function larger(a, b)
    return __K2L_Compare(a, b) > 0 and a or b
end

local function describe(x)
    if math.type(x) == "integer" then
        return "long " .. x
    elseif math.type(x) == "integer" then
        return "int " .. x
    elseif type(x) == "string" then
        return "string " .. x
    else
        return "other"
    end
end

local function classify(n)
    if n == 0 then
        return "zero"
    elseif n == 9223372036854775807 then
        return "max"
    elseif n == -9223372036854775807 - 1 then
        return "min"
    elseif n >= 1 and n <= 1000 then
        return "small"
    elseif n >= 1001 and n <= 9223372036854775807 then
        return "large"
    else
        return "negative"
    end
end

local ____lambda_1 = function(acc, x) return acc * 31 + x end
local ____lambda_2 = function(a, b) return a ~ b end
local ____lambda_3 = function(it) return it.value.size end
local ____lambda_4 = function(it) return it.balance end
local ____lambda_5 = function(it) return it * 3 end
local ____lambda_6 = function(it) return it >= 0 and it // 7 or (it + 6) // 7 end
local ____lambda_7 = function(it) return it > 0 end
local ____lambda_8 = function(x) return math.type(x) == "integer" end
local ____lambda_9 = function() return __K2L_ListOf() end
local function main()
    local big = 5000000000000000000
    local max = 9223372036854775807
    local min = -9223372036854775807 - 1
    print(max + 1)
    print(min - 1)
    print(big * 3)
    print(-min)
    print(__K2L_IDiv(min, -1))
    print(max * max)
    print(big + big)
    print(1 - 3)
    local ____dividend = 2 * big
    print(7 + (____dividend >= 0 and ____dividend // 4 or (____dividend + 3) // 4))
    local ____dividend_1 = big + 1
    print(____dividend_1 >= 0 and ____dividend_1 % 1000 or (____dividend_1 % 1000 - 1000) % (-1000))
    local ____dividend_2 = -big - 1
    print(____dividend_2 >= 0 and ____dividend_2 % 1000 or (____dividend_2 % 1000 - 1000) % (-1000))
    local ____dividend_3 = -big - 1
    print(____dividend_3 >= 0 and ____dividend_3 // 1000 or (____dividend_3 + 999) // 1000)
    print(__K2L_IRem(max, -1000))
    print(fib(90))
    print(fib(92) + fib(91))
    print(collatz(837799))
    print(collatz(1000000000039))
    local v = max - 2
    v = v + 1
    v = v + 1
    print(v)
    v = v + 1
    print(v)
    v = v - 5
    print(v)
    v = v * 2
    print(v)
    v = v >= 0 and v // 3 or (v + 2) // 3
    print(v)
    v = v >= 0 and v % 1000003 or (v % 1000003 - 1000003) % (-1000003)
    print(v)
    local w = min + 1
    w = w - 1
    print(w)
    w = w - 1
    print(w)
    print(-w)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(__K2L_IDiv(big, big - big))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        print(__K2L_IRem(big, 0))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_ArithmeticException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print(big & 4294967295)
    print(big | 1)
    print(big ~ max)
    print(~big)
    print(1 << 63)
    print(min >> 63)
    print(min >> 1)
    print(-1 >> 60)
    print(-256 // (1 << 4))
    print(big // (1 << 20))
    print(big << 3)
    print(3405691582 << 32 | 3735928559)
    print(__K2L_Bits.ones64(3405691582 << 32 | 3735928559))
    print(__K2L_Bits.clz64(big))
    print(__K2L_Bits.ctz64(big))
    print(__K2L_Bits.highest64(big))
    print(__K2L_Bits.lowest64(big))
    print(__K2L_Bits.rotl64(big, 13))
    print(__K2L_Bits.rotl64(big, -13))
    print(__K2L_Bits.clz64(min))
    print(__K2L_ToInt32(big))
    print(__K2L_ToInt32(big + 12345))
    print(__K2L_ToInt32(max))
    print(__K2L_ToInt32(min))
    print(__K2L_Num.toShort(big))
    print(__K2L_Num.toByte(big))
    print(__K2L_DoubleToString(big + 0.0))
    print(__K2L_DoubleToString(max + 0.0))
    print(__K2L_FloatToString(__K2L_Fround(min)))
    print(__K2L_FloatToString(__K2L_Fround(12345678901)))
    print(__K2L_DoubleToLong(1.0E19))
    print(-__K2L_DoubleToLong(1.0E19))
    print(__K2L_DoubleToLong(9.223372036854775E18))
    print(__K2L_DoubleToLong(4.611686018427388E18))
    print(__K2L_DoubleToLong(1.2345678901234568E18))
    print(__K2L_DoubleToLong(0.0 / 0.0))
    print(__K2L_DoubleToLong(3.99))
    print(__K2L_DoubleToLong(-3.99))
    print(__K2L_Str(__K2L_BigInteger.valueOf(123456789):multiply(__K2L_BigInteger.valueOf(1000000000000))))
    print(__K2L_Unsigned.toString(big))
    print(__K2L_Unsigned.toString(-1))
    print(__K2L_Num.toRadix(max, 16))
    print(__K2L_Num.toRadix(min, 2))
    print(__K2L_Num.toRadix(big, 36))
    print(__K2L_Num.toRadix(-big, 7))
    print(__K2L_StringToInt("9223372036854775807", nil, true))
    print(__K2L_StringToInt("-9223372036854775808", nil, true))
    print(__K2L_Str(__K2L_StringToIntOrNull("9223372036854775808", nil, true)))
    print(__K2L_Str(__K2L_StringToIntOrNull("-9223372036854775809", nil, true)))
    print(__K2L_Str(__K2L_StringToIntOrNull("12x", nil, true)))
    print(__K2L_Str(__K2L_StringToIntOrNull("", nil, true)))
    print(__K2L_StringToInt("+77", nil, true))
    print(__K2L_StringToInt("ff", 16, true))
    print(__K2L_StringToInt("7fffffffffffffff", 16, true))
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        __K2L_StringToInt("9223372036854775808", nil, true)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_NumberFormatException) then
            local e = ____error_2
            print(__K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    print(__K2L_StringToInt("-4611686018427387904", nil, true))
    print(__K2L_Num.mod(-big, 7))
    print(__K2L_FloorDiv(-big, 7))
    print(__K2L_Num.mod(-big, 7))
    print(__K2L_FloorDiv(-big, 7))
    print(math.abs(-big))
    print(math.abs(min))
    print(math.abs(-big))
    print(math.max(big, -big))
    print(math.min(big, -big, 0))
    print(math.max(big, max))
    print(math.max(-big, -7))
    print(math.min(big, 99))
    print(__K2L_Num.coerceIn(big, -5, max))
    print(__K2L_Compare(big, max))
    print(__K2L_Compare(max, big))
    print(__K2L_Compare(big, big))
    print(__K2L_Num.signInt(-big))
    print(__K2L_Num.signInt(big))
    print(big < max)
    print(big > max)
    print(big <= big)
    print(min < max)
    print(min < 0)
    print(0 < min)
    print(max >= big + big)
    print(big == 5000000000000000000)
    print(big ~= big + 1)
    print(big == big)
    print(big == 5000000000000000001)
    local boxed = big
    print(boxed == big)
    print(boxed == nil)
    print(larger(big, -big))
    print(larger(3, 4))
    print(__K2L_Str(__K2L_ReadOnlyListOf(max, min, 0, big, -big, 1):sorted()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(max, min, 0, big, -big, 1):sortedDescending()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(max, min, 0, big):maxOrNull()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(max, min, 0, big):minOrNull()))
    print("big=" .. big .. ", max=" .. max .. ", min=" .. min)
    print(#tostring(big))
    print(__K2L_StringFormat("%d|%5d|%x", 1, 22, __K2L_Text.sized(255, 64)))
    print(__K2L_StringFormat("%d", big))
    print(__K2L_StringFormat("%,d", max))
    print(__K2L_StringFormat("%x", __K2L_Text.sized(big, 64)))
    print(__K2L_StringFormat("%020d", min))
    print(__K2L_StringFormat("%d", min))
    print(__K2L_Hash(max))
    print(__K2L_Hash(min))
    print(__K2L_Hash(big))
    print(__K2L_Hash(1234567890123))
    local ids = __K2L_ReadOnlyListOf(big, max, 17, big + 1, min)
    print(__K2L_Str(ids))
    print(ids:sum())
    local ____sum = 0
    local ____items, ____n = ids:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum = ____sum + (it >= 0 and it // 2 or (it + 1) // 2)
    end
    print(____sum)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ids:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count = ____count + 1
        ____out[____count] = it >= 0 and it % 100 or (it % 100 - 100) % (-100)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ids:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        if it > 100 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(ids:indexOf(max))
    print(ids:contains(big))
    local ____result_3 = 0
    local ____items_3, ____n_3 = ids:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        if it < 0 then
            ____result_3 = ____result_3 + 1
        end
    end
    print(____result_3)
    print(ids:fold(1, ____lambda_1))
    print(ids:reduce(____lambda_2))
    print(ids:distinct().size)
    local ____list = ids:zip(ids:drop(1))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list:____array()
    for ____i_4 = 1, ____n_4 do
        local ____it = ____items_4[____i_4]
        local ____result_4
        do
            local a, b = ____it.first, ____it.second
            ____result_4 = b - a
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result_4
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local ____result_5 = __K2L_Map.new()
    local ____items_5, ____n_5 = ids:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        local ____value = __K2L_Bits.ones64(it)
        ____result_5:put(it, ____value)
    end
    print(__K2L_Str(____result_5))
    local counts = __K2L_HashMap.new()
    local ____list_1 = ids:plusAll(ids)
    local ____mod = ____list_1.____modCount
    for ____i_6 = 1, ____list_1.size do
        local x = ____list_1[____i_6]
        counts:set(x, (counts:get(x) or 0) + 1)
        if ____list_1.____modCount ~= ____mod and ____list_1:____comodified(____i_6) then
            break
        end
    end
    print(counts.size)
    print(__K2L_Str(counts:get(max)))
    print(__K2L_Str(counts:get(big + 1)))
    print(__K2L_Str(counts:get(12345)))
    local set = __K2L_HashSet.new()
    set:add(max)
    set:add(9223372036854775807)
    set:add(max - 1)
    set:add(3)
    print(set.size)
    print(set:contains(max))
    print(set:contains(max))
    local sorted = __K2L_SortedMap.new()
    sorted:set(big, "big")
    sorted:set(min, "min")
    sorted:set(3, "three")
    sorted:set(max, "max")
    print(__K2L_Str(sorted))
    print(__K2L_NotNull(sorted:firstKey()))
    print(__K2L_NotNull(sorted:lastKey()))
    local accounts = __K2L_ReadOnlyListOf(Account.new(max, big), Account.new(1, 2), Account.new(max, big))
    print(__K2L_Str(accounts:get(0)))
    print(accounts:get(0):equals(accounts:get(2)))
    print(accounts:get(0):equals(accounts:get(1)))
    print(accounts:toSet().size)
    print(accounts:get(0):hashCode() == accounts:get(2):hashCode())
    local ____result_6 = __K2L_Map.new()
    local ____items_6, ____n_6 = accounts:____array()
    for ____i_7 = 1, ____n_6 do
        local it = ____items_6[____i_7]
        local ____value_1 = it.id
        local ____group = ____result_6:get(____value_1)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_6:put(____value_1, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result_6:mapValues(____lambda_3)))
    local ____sum_1 = 0
    local ____items_7, ____n_7 = accounts:____array()
    for ____i_8 = 1, ____n_7 do
        local it = ____items_7[____i_8]
        ____sum_1 = ____sum_1 + it.balance
    end
    print(____sum_1)
    print(__K2L_Str(accounts:maxByOrNull(____lambda_4)))
    local arr = __K2L_TypedArrayOf("[J", big, 1, max, min)
    print(arr:sum())
    print(arr:max())
    print(arr:min())
    print(__K2L_Str(arr:sorted()))
    local ____value_2 = (arr[1] or __K2L_IndexError(0, arr.size, "array")) * 2
    if 1 < 0 or 1 >= arr.size then
        __K2L_IndexError(1, arr.size, "array")
    end
    arr[2] = ____value_2
    print(arr:contentToString())
    print(arr.size)
    local total = 0
    for i = 1, 100000 do
        total = total + i * i
    end
    print(total)
    for i = big, big - 2, -1 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 9, 4 do
        io.write(i .. " ")
    end
    print()
    for i = 10, 0, -5 do
        io.write(i .. " ")
    end
    print()
    print(3 >= 1 and 3 <= 5)
    print(big >= 1 and big <= max)
    print(not (big >= 1 and big < big))
    print(min >= min and min <= max)
    print(classify(0))
    print(classify(max))
    print(classify(min))
    print(classify(500))
    print(classify(big))
    print(classify(-5))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(function(it) return it * big end)))
    print(__K2L_IntRange.new(1, 5):sum())
    print(__K2L_GenerateSequence(1, ____lambda_5):take(45):last())
    print(__K2L_Str(__K2L_GenerateSequence(big, ____lambda_6):takeWhile(____lambda_7):toList()))
    print(describe(big))
    print(describe("x"))
    local anys = __K2L_ReadOnlyListOf(big, "s", max)
    print(__K2L_Str(anys))
    print(anys:filter(____lambda_8):sum())
    local anyBig = big
    print(__K2L_Equals(anyBig, big))
    print(__K2L_Equals(anyBig, 5000000000000000000))
    print(__K2L_Hash(anyBig))
    if math.type(anyBig) ~= "integer" then
        __K2L_CastFail(anyBig, "java.lang.Long", "kotlin.Long")
    end
    print(anyBig + 1)
    local ____table = __K2L_ListOfSize(5, function(it) return it * big end, "[J")
    print(__K2L_Str(____table:toList()))
    local m = __K2L_MapOf()
    for i = 0, 5 do
        m:getOrPut((i >= 0 and i % 3 or (i % 3 - 3) % (-3)) * big, ____lambda_9):add(i)
    end
    print(__K2L_Str(m))
end

__K2L_DeepMain(main)
return {Account = Account, fib = fib, collatz = collatz, larger = larger, describe = describe, classify = classify}
