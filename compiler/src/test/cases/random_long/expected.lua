local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RandomLong = ____lualib.__K2L_RandomLong
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function main()
    local r = __K2L_Random.seeded(42)
    print(__K2L_RandomLong.nextLong(r, nil, 100))
    print(__K2L_RandomLong.nextLong(r, nil, 1 << 40))
    print(__K2L_RandomLong.nextLong(r, nil, 1 << 32))
    print(__K2L_RandomLong.nextLong(r, nil, 1 << 20))
    print(__K2L_RandomLong.nextLong(r, nil, 1000000007))
    print(__K2L_RandomLong.nextLong(r, nil, 1 << 50 | 12345))
    print(__K2L_RandomLong.nextLong(r, -50, 50))
    print(__K2L_RandomLong.nextLong(r, 10000000000, 10000000100))
    print(__K2L_RandomLong.nextLong(r, -9223372036854775807 - 1, 9223372036854775807))
    print(r:nextLong())
    print(__K2L_RandomLong.nextUInt(r))
    print(__K2L_RandomLong.nextUInt(r, nil, 10))
    print(__K2L_RandomLong.nextUInt(r, 4000000000, 4000000100))
    print(__K2L_RandomLong.nextUInt(r, 0, 4294967295))
    print(__K2L_Unsigned.toString(__K2L_RandomLong.nextULong(r)))
    print(__K2L_Unsigned.toString(__K2L_RandomLong.nextULong(r, nil, 1000)))
    print(__K2L_Unsigned.toString(__K2L_RandomLong.nextULong(r, 0xfffffffffffffd98, 0xffffffffffffffff)))
    local d = __K2L_Random.seededLong(7)
    for it = 0, 4 do
        io.write(__K2L_RandomLong.nextLong(d, nil, 1000) .. " ")
    end
    print()
    local ____ok, ____result = __K2L_DeepPcall(function()
        __K2L_RandomLong.nextLong(r, nil, 0)
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
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        __K2L_RandomLong.nextUInt(r, 5, 5)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____value = __K2L_RandomLong.nextLong(__K2L_Random.default(), nil, 10)
    print(____value >= 0 and ____value < 10)
end

__K2L_DeepMain(main)
