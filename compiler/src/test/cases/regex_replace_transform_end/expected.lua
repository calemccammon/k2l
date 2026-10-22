local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local ____lambda_1 = function(it) return "-" end
local ____lambda_2 = function(it) return "-" end
local ____lambda_3 = function(it) return "<" .. it.value .. ">" end
local ____lambda_4 = function(it) return "!" end
local ____lambda_5 = function(it) return "[" .. it.value .. "]" end
local function main()
    print(__K2L_Regex.new("x*", "x*"):replace("abc", ____lambda_1))
    print(__K2L_Regex.new("c*", "c*"):replace("abc", ____lambda_2))
    print(__K2L_Regex.new("c*", "c*"):replace("abc", "-"))
    print(__K2L_Regex.new("[0-9.]*", "[0-9%.]*"):replace("1.0", ____lambda_3))
    print(__K2L_Regex.new("[0-9.]*", "[0-9%.]*"):replace("1.0", "<$0>"))
    print(__K2L_Regex.new("a*", "a*"):replace("", ____lambda_4))
    print(__K2L_Regex.new("\\d*", "%d*"):replace("a1b22", ____lambda_5))
    print(__K2L_Regex.new("\\d*", "%d*"):replace("a1b22", "[$0]"))
    print(__K2L_Regex.new("\\d*", "%d*"):replaceFirst("22b", "#"))
    local range = __K2L_Regex.new("([\\[(]?)\\s*(\\d*)\\s*(,?)\\s*(\\d*)\\s*([\\])]?)", "([%[%(]?)%s*(%d*)%s*(,?)%s*(%d*)%s*([%]%)]?)")
    local parts = __K2L_ListOf()
    local rest = range:replace("[1,2)", function(m)
        parts:add(m.groupValues:drop(1):joinToString("|"))
        return ""
    end)
    print(__K2L_Str(parts) .. " '" .. rest .. "'")
end

__K2L_RunMain(main)
