local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function fnv(s)
    local h = 0xcbf29ce484222325
    for ____i = 1, #s do
        local c = s:sub(____i, ____i)
        h = h ~ c:byte()
        h = h * 1099511628211
    end
    return h
end

local function main()
    local max = 0xffffffffffffffff
    local big = 0x8ac7230489e80000
    local small = 12345
    print(__K2L_Unsigned.toString(max))
    print(__K2L_Unsigned.toString(0))
    print(__K2L_Unsigned.toString(big))
    print(__K2L_Unsigned.toString(big + small))
    print(__K2L_Unsigned.toString(max + 2))
    print(__K2L_Unsigned.toString(small - big))
    print(__K2L_Unsigned.toString(big * 3))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(big, 3)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.urem(big, 7)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(max, 10)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.urem(max, 10)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(max, big)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(big, max)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(max, 0x8000000000000000)))
    print(math.ult(small, big))
    print(math.ult(big, small))
    print(math.ult(big, max))
    print(not math.ult(max, big))
    print(not math.ult(big, big))
    print(__K2L_Unsigned.compare(big, small))
    print(__K2L_Unsigned.compare(small, big))
    print(__K2L_Equals(big, 0x8ac7230489e80000))
    print("big=" .. __K2L_Unsigned.toString(big))
    print(__K2L_Unsigned.toString(big))
    print(big)
    print(small)
    print(__K2L_Unsigned.toString(-1))
    print(__K2L_Unsigned.toString(-1))
    print(__K2L_Unsigned.toString(5))
    print(max & 0xFFFFFFFF)
    print(big & 0xFFFFFFFF)
    print(__K2L_ToInt32(max))
    print(__K2L_Str(__K2L_Unsigned.toDouble(big)))
    print(__K2L_Str(__K2L_Unsigned.toDouble(max)))
    print(__K2L_Str(__K2L_Unsigned.toDouble(small)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.fromDouble64(1.0E19)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.fromDouble64(1.8446744073709552E19)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.fromDouble64(-5.0)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.fromDouble64(3.9)))
    print(__K2L_Unsigned.toString(max >> 60))
    print(__K2L_Unsigned.toString(max << 4))
    print(__K2L_Unsigned.toString(1 << 63))
    print(__K2L_Unsigned.toString(big & 65535))
    print(__K2L_Unsigned.toString(small | 983040))
    print(__K2L_Unsigned.toString(max ~ 1))
    print(__K2L_Unsigned.toString(-1 - max))
    print(__K2L_Unsigned.toString(-1 - small))
    print(__K2L_Unsigned.toString(fnv("hello")))
    print(__K2L_Unsigned.toString(fnv("Kotlin to Lua")))
    local counter = 0
    counter = counter - 1
    print(__K2L_Unsigned.toString(counter))
    counter = counter + 1
    counter = counter + 1
    print(__K2L_Unsigned.toString(counter))
    for i = 1, 3 do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    print((small & 0xFFFFFFFF) + 1 & 0xFFFFFFFF)
    print(__K2L_Unsigned.toString(math.max(small, 7)))
    print(__K2L_ReadOnlyListOf(big, small, max).size)
end

main()
return {fnv = fnv}
