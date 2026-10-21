local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local P = __K2L_Class("P")

function P:____init(a, b)
    self.a = a
    self.b = b
end

function P.new(a, b)
    return setmetatable({a = a, b = b}, P)
end

function P:toString()
    return "P(a=" .. self.a .. ", b=" .. __K2L_Str(self.b) .. ")"
end

function P:hashCode()
    return (31 * __K2L_Hash(self.a) + __K2L_Hash(self.b) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function P:equals(other)
    return getmetatable(other) == P and self.a == other.a and self.b == other.b
end

local function sum3(a, b)
    if a ~= nil then
        return a + b
    end
    return b
end

local ____lambda_1 = function(it) return tostring(it) end
local ____lambda_2 = function(it) return "<" .. it .. ">" end
local ____lambda_3 = function(it) return -it end
local ____lambda_4 = function(it)
    return it >= 0 and it % 1000 or (it % 1000 - 1000) % (-1000)
end
local ____lambda_5 = function(it) return it end
local function main()
    local big = 5000000000000000000
    local max = 9223372036854775807
    local sb = __K2L_StringBuilder.new()
    sb:append(tostring(big)):append(" "):append(tostring(max)):append("x"):append(tostring(-big))
    print(__K2L_Str(sb))
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append(tostring(big))
    ____builder:append(tostring(1))
    ____builder:append(tostring(max))
    print(____builder:toString())
    print(__K2L_ReadOnlyListOf(big, max):joinToString(","))
    print(__K2L_ReadOnlyListOf(big, max):joinToString(nil, nil, nil, nil, nil, ____lambda_1))
    print(__K2L_ReadOnlyListOf(big, max):joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    print(__K2L_Str(__K2L_Pair.new(big, max)))
    print(__K2L_Str(__K2L_ReadOnlyMapOf(__K2L_Pair.new(big, max), __K2L_Pair.new(1, 2))))
    print(__K2L_Str(P.new(big, nil)))
    print(__K2L_Str(P.new(big, max)))
    print(P.new(big, max):equals(P.new(big, max)))
    print(P.new(big, max):hashCode() == P.new(big, max):hashCode())
    print(__K2L_StringFormat("%s|%10s|%-12s|", big, max, 5))
    print(__K2L_StringFormat("%s", big))
    print(__K2L_StringPadStart(tostring(big), 25, "0"))
    print(sum3(nil, big))
    print(sum3(max - 1, 1))
    print(sum3(max, 1))
    local n = big
    if n ~= nil then
        print(n + 1)
    end
    local m = big > 0 and max or nil
    print((m or 0) + 1)
    print(__K2L_NotNull(m) - 1)
    print(__K2L_Str(__K2L_ReadOnlyListOf(big, max, 5):average()))
    print(__K2L_Str(__K2L_TypedArrayOf("[J", big, max):average()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, 1, 2):sortedBy(____lambda_3, true)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(big, max, 5):maxByOrNull(____lambda_4)))
    local ____list = __K2L_ReadOnlyListOf(big, max, 5)
    local ____best
    local ____has = false
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____key = it >= 0 and it % 1000 or (it % 1000 - 1000) % (-1000)
        if not ____has or ____best < ____key then
            ____best = ____key
            ____has = true
        end
    end
    if not ____has then
        error(__K2L_NoSuchElementException.new(nil))
    end
    print(____best)
    local ____list_1 = __K2L_ReadOnlyListOf(big, max, 5)
    local ____best_1
    local ____has_1 = false
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if not ____has_1 or ____best_1 > it then
            ____best_1 = it
            ____has_1 = true
        end
    end
    if not ____has_1 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    print(____best_1)
    print(__K2L_Str(__K2L_ReadOnlyListOf(big, 1):sortedByDescending(____lambda_5, true)))
    local ____list_2 = __K2L_ReadOnlyListOf(big, max)
    local ____sum = 0.0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum = ____sum + (it + 0.0)
    end
    print(__K2L_Str(____sum))
    local ms = __K2L_Num.currentTimeMillis()
    local elapsed = __K2L_Num.currentTimeMillis() - ms
    print(elapsed >= 0)
    print(elapsed < 1000)
    local arr = __K2L_ListOfSize(3, 0, "[J")
    if 0 < 0 or 0 >= arr.size then
        __K2L_IndexError(0, arr.size, "array")
    end
    arr[1] = max
    local ____dividend = arr[1] or __K2L_IndexError(0, arr.size, "array")
    local ____value = ____dividend >= 0 and ____dividend // 2 or (____dividend + 1) // 2
    if 1 < 0 or 1 >= arr.size then
        __K2L_IndexError(1, arr.size, "array")
    end
    arr[2] = ____value
    arr[3] = (arr[3] or __K2L_IndexError(2, arr.size, "array")) + big
    arr[3] = (arr[3] or __K2L_IndexError(2, arr.size, "array")) - 1
    print(__K2L_Str(arr:toList()))
    arr:fill(big)
    print(__K2L_Str(arr:toList()))
    local list = __K2L_ListOf(1, 2)
    list:set(0, list:get(0) + big)
    list:set(1, list:get(1) * big)
    print(__K2L_Str(list))
    local counter = 0
    local inc = function()
        counter = counter + big
    end
    inc()
    inc()
    print(counter)
    local ____lazyBig_delegate = __K2L_Lazy(function() return big * 2 end)
    print(____lazyBig_delegate:getValue())
    local e
    if big == 5000000000000000000 then
        e = "match"
    else
        e = "no"
    end
    print(e)
    print(__K2L_Num.coerceIn(max, 0, big))
    print(tostring(9223372036854775807):reverse())
    print(__K2L_Num.toRadix(big, 10) == "5000000000000000000")
    print(__K2L_NotNull(big))
    print(__K2L_Str(__K2L_BigInteger.valueOf(big):multiply(__K2L_BigInteger.valueOf(big))))
    print(__K2L_BigInteger.valueOf(max):add(__K2L_BigInteger.ONE):toLong())
    print(__K2L_BigInteger.parse("123456789012345678901"):toLong())
    print(__K2L_BigInteger.parse("-9223372036854775808"):longValueExact())
    print(__K2L_Str(__K2L_BigDecimal.valueOf(big):toPlainString()))
end

__K2L_Main(main)
return {P = P, sum3 = sum3}
