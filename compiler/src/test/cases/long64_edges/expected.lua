local ____lualib = require("lualib_bundle")
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function main()
    local min = -9223372036854775807 - 1
    local max = 9223372036854775807
    local big = 5000000000000000000
    local ____list = __K2L_ReadOnlyListOf(0, 1, 31, 32, 33, 62, 63, 64, 65, 127, 128, -1, -63)
    for ____i = 1, ____list.size do
        local n = ____list[____i]
        print(n .. ": " .. (1 << n) .. " " .. min // (1 << n) .. " " .. (min >> n) .. " " .. -big // (1 << n) .. " " .. (big >> n) .. " " .. (max << n))
    end
    print(1 << 64)
    print(1 << 65)
    print(min // (1 << 63))
    print(min // (1 << 62))
    print(-1 // (1 << 70))
    print(-2 // (1 << 1))
    print(1 << 100)
    print(__K2L_Hash(-1))
    print(__K2L_Hash(-2))
    print(__K2L_Hash(-5000000000))
    for i = 9223372036854775806, 0x8000000000000002 do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    local ____ok, ____result = pcall(function()
        for i = 1, 5, __K2L_CheckStep(0) do
            io.write(tostring(i))
        end
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local r = __K2L_IntRange.new(max - 6, max)
    print(__K2L_Str(r))
    print(__K2L_Str(r:toList()))
    print(r.first)
    print(r.last)
    print(r:contains(max))
    print(r:contains(max - 7))
    print(__K2L_Str(r:reversed():toList()))
    print(__K2L_Str(r:withStep(3):toList()))
    print(r:withStep(3).last)
    print(r:count())
    print(r:sum())
    print(r:isEmpty())
    print(__K2L_IntRange.new(max, max - 1):isEmpty())
    print(__K2L_Str(__K2L_IntRange.new(min, min - 1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(min, min + 3 - 1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(max, max - 3, -1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(max, max - 6, -1):withStep(3):toList()))
    local ____range = r:reversed()
    for i = ____range.first, ____range.last, ____range.step do
        io.write(i .. " ")
    end
    print()
end

main()
