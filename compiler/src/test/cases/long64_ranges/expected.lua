local ____lualib = require("lualib_bundle")
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function main()
    local max = 9223372036854775807
    local min = -9223372036854775807 - 1
    local big = 5000000000000000000
    for i = max - 2, max do
        io.write(i .. " ")
    end
    print()
    for i = min, min + 2 do
        io.write(i .. " ")
    end
    print()
    for i = max, max - 2, -1 do
        io.write(i .. " ")
    end
    print()
    for i = min + 2, min, -1 do
        io.write(i .. " ")
    end
    print()
    for i = max - 10, max, 4 do
        io.write(i .. " ")
    end
    print()
    for i = min, min + 3 - 1 do
        io.write(i .. " ")
    end
    print()
    for i = max, max - 1 do
        io.write(i .. " ")
    end
    print("empty")
    for i = 5, 4 do
        io.write(i .. " ")
    end
    print("empty")
    local firstBig = 0
    for i = 1, max, 1000000000 do
        if i * i > big then
            firstBig = i
            break
        end
    end
    print(firstBig)
    local count = 0
    for i = 1, max do
        if i > 5 then
            break
        end
        count = count + 1
    end
    print(count)
    local last = 0
    for i = big - 3, max do
        last = i
        if i == big then
            break
        end
    end
    print(last)
    print(max >= max - 1 and max <= max)
    print(not (min >= min + 1 and min <= max))
    for i = 1, 3 do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    for i = 0xffffffffffffffff - 2, 0xffffffffffffffff do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    for i = 0xffffffffffffffff, 0xffffffffffffffff - 1, -1 do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    local top = 0xffffffffffffffff
    local half = 1 << 63
    local ____first = top - 8
    local ____first_1 = top - 8
    local ____value = top - 1
    local ____first_2 = half - 3
    local ____value_1 = half + 3
    print(tostring(not math.ult(top, ____first) and not math.ult(top, top) and __K2L_Unsigned.urem(top - ____first, 2) == 0) .. " " .. tostring(not math.ult(____value, ____first_1) and not math.ult(top, ____value) and __K2L_Unsigned.urem(____value - ____first_1, 2) == 0) .. " " .. tostring(not math.ult(____value_1, ____first_2) and not math.ult(half + 9, ____value_1) and __K2L_Unsigned.urem(____value_1 - ____first_2, 3) == 0))
    local ____first_3 = half + 5
    local ____value_2 = half - 1
    local ____first_4 = top - 9
    print(tostring(not math.ult(____value_2, half - 7) and not math.ult(____first_3, ____value_2) and __K2L_Unsigned.urem(____first_3 - ____value_2, 3) == 0) .. " " .. tostring(not (not math.ult(top, ____first_4) and math.ult(top, top) and __K2L_Unsigned.urem(top - ____first_4, 1) == 0)) .. " " .. tostring(not math.ult(half, 1) and not math.ult(9, half) and __K2L_Unsigned.urem(half - 1, 2) == 0))
    local ____first_5 = max - 10
    local ____value_3 = max - 2
    local ____first_6 = max - 10
    local ____value_4 = max - 1
    local ____first_7 = big + 9
    local ____value_5 = big + 3
    print(tostring(____value_3 >= ____first_5 and ____value_3 <= max and (____value_3 - ____first_5) % 2 == 0) .. " " .. tostring(____value_4 >= ____first_6 and ____value_4 <= max and (____value_4 - ____first_6) % 2 == 0) .. " " .. tostring(____value_5 >= big and ____value_5 <= ____first_7 and (____first_7 - ____value_5) % 3 == 0))
    local ____first_8 = 4294967295 - 10 & 0xFFFFFFFF
    print(tostring(5 >= 1 and 5 <= 10 and (5 - 1) % 2 == 0) .. " " .. tostring(6 >= 1 and 6 <= 10 and (6 - 1) % 2 == 0) .. " " .. tostring(4294967295 >= ____first_8 and 4294967295 <= 4294967295 and (4294967295 - ____first_8) % 5 == 0))
end

main()
