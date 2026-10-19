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
end

main()
