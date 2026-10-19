local ____lualib = require("lualib_bundle")
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RandomLong = ____lualib.__K2L_RandomLong
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function main()
    local r = __K2L_Random.seeded(2024)
    print(__K2L_RandomLong.nextUInt(r))
    print(__K2L_RandomLong.nextUInt(r, nil, 10))
    print(__K2L_RandomLong.nextUInt(r, 4000000000, 4000000100))
    print(__K2L_RandomLong.nextUInt(r, 0, 4294967295))
    print(__K2L_RandomLong.nextLong(r, nil, 100))
    print(__K2L_RandomLong.nextLong(r, nil, 1048576))
    print(__K2L_RandomLong.nextLong(r, nil, 4294967296))
    print(__K2L_RandomLong.nextLong(r, nil, 1099511627776))
    print(__K2L_RandomLong.nextLong(r, nil, 1000000007))
    print(__K2L_RandomLong.nextLong(r, nil, 77777))
    print(__K2L_RandomLong.nextLong(r, -50, 50))
    print(__K2L_RandomLong.nextLong(r, 5000000000, 5000000100))
    local d = __K2L_Random.seededLong(7)
    for it = 0, 4 do
        io.write(__K2L_RandomLong.nextLong(d, nil, 1000) .. " ")
    end
    print()
    local ____ok, ____result = pcall(function()
        __K2L_RandomLong.nextUInt(r, 5, 5)
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
    local ____ok_1, ____result_1 = pcall(function()
        __K2L_RandomLong.nextLong(r, nil, 0)
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
end

main()
