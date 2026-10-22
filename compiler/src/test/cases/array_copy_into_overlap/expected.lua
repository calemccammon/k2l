local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local up = __K2L_ArrayOf(1, 2, 3, 4, 5, nil)
    up:copyInto(up, 1, 0, 5)
    print(__K2L_Str(up:toList()))
    local down = __K2L_ArrayOf(1, 2, 3, 4, 5)
    down:copyInto(down, 0, 1, 5)
    print(__K2L_Str(down:toList()))
    local ints = __K2L_ArrayOf(1, 2, 3, 4, 5, 6, 7)
    ints:copyInto(ints, 2, 0, 4)
    print(__K2L_Str(ints:toList()))
    local chars = __K2L_ArrayOf("a", "b", "c", "d")
    chars:copyInto(chars, 1, 0, 3)
    print(chars:joinToString(""))
    local grown = up:copyOfSize(8, nil)
    grown:copyInto(grown, 3, 1, 6)
    print(__K2L_Str(grown:toList()))
    local same = __K2L_ArrayOf("x", "y", "z")
    same:copyInto(same, 0, 0, 3)
    print(__K2L_Str(same:toList()))
end

__K2L_RunMain(main)
