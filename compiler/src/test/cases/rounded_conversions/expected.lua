local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Truncate = ____lualib.__K2L_Truncate

local function scaled(x, r)
    return math.floor(x * r)
end

local function main()
    local ____list = __K2L_ListOf(2.5, -2.5, 3.5, -0.4, 0.0, -0.0, 7.0)
    for ____i = 1, ____list.size do
        local v = ____list[____i]
        print(v .. ": " .. math.floor(v) .. " " .. math.ceil(v) .. " " .. __K2L_Num.round(v) .. " " .. __K2L_Truncate(v) .. " " .. __K2L_Truncate(v))
        print(math.floor(v) + 1)
    end
    local ____list_1 = __K2L_ListOf(1.0E15 + 0.75, -1.0E15 - 0.75, 4.5)
    for ____i_1 = 1, ____list_1.size do
        local v = ____list_1[____i_1]
        print(math.floor(v) .. " " .. math.ceil(v) .. " " .. __K2L_Num.round(v) .. " " .. __K2L_Truncate(v) .. " " .. __K2L_Truncate(v))
    end
    print(scaled(1.75, 4.0))
    print(scaled(-1.75, 3.0))
    local n = math.floor(-2.25)
    print(__K2L_Truncate(n))
    print(__K2L_Truncate(math.floor(9.5) * 2))
end

__K2L_RunMain(main)
return {scaled = scaled}
