local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local function main(args)
    print(args:isEmpty())
    print(args.size)
    print(args:joinToString(nil, "[", "]"))
    print(__K2L_Str(args:toList()))
    print(args:firstOrNull() or "no arguments")
    for ____i = 1, args.size do
        local a = args[____i]
        print(a)
    end
    local verbose = args:contains("-v")
    print(verbose)
end

__K2L_RunMain(main, __K2L_ArrayOf(...))
