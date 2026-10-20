local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LocaleFormat = ____lualib.__K2L_LocaleFormat
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Point = __K2L_Class("Point")
__K2L_ClassInfo(Point, "Point", "Point", "class")

function Point:____init(x)
    self.x = x
end

function Point.new(x)
    return setmetatable({x = x}, Point)
end

function Point:toString()
    return "Point(" .. self.x .. ")"
end

local function attempt(label, block)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. ": " .. block())
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. " " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    local i = 5
    local l = 7
    local d = 2.0
    local f = 1.5
    local c = "x"
    local s = "y"
    local b = true
    local sh = 3
    local by = 4
    local bi = __K2L_BigInteger.TEN
    local bd = __K2L_BigDecimal.parse("1234.5")
    local u = 5
    local p = Point.new(1)
    local none = nil
    local some = 6
    attempt("%f Int", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("%e Int", function()
        return __K2L_StringFormat("%e", __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("%g Long", function()
        return __K2L_StringFormat("%g", __K2L_Text.typed(l, nil, "java.lang.Long"))
    end)
    attempt("%c Long", function()
        return __K2L_StringFormat("%c", __K2L_Text.typed(l, nil, "java.lang.Long"))
    end)
    attempt("%d Double", function()
        return __K2L_StringFormat("%d", __K2L_Text.typed(d, nil, "java.lang.Double"))
    end)
    attempt("%x Double", function()
        return __K2L_StringFormat("%x", __K2L_Text.typed(d, nil, "java.lang.Double"))
    end)
    attempt("%c Double", function()
        return __K2L_StringFormat("%c", __K2L_Text.typed(d, nil, "java.lang.Double"))
    end)
    attempt("%d Float", function()
        return __K2L_StringFormat("%d", __K2L_Text.typed(f, nil, "java.lang.Float"))
    end)
    attempt("%x Char", function()
        return __K2L_StringFormat("%x", __K2L_Text.typed(c, nil, "java.lang.Character"))
    end)
    attempt("%f Char", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(c, nil, "java.lang.Character"))
    end)
    attempt("%c String", function()
        return __K2L_StringFormat("%c", __K2L_Text.typed(s, nil, "java.lang.String"))
    end)
    attempt("%d String", function()
        return __K2L_StringFormat("%d", __K2L_Text.typed(s, nil, "java.lang.String"))
    end)
    attempt("%c Boolean", function()
        return __K2L_StringFormat("%c", __K2L_Text.typed(b, nil, "java.lang.Boolean"))
    end)
    attempt("%e Short", function()
        return __K2L_StringFormat("%e", __K2L_Text.typed(sh, nil, "java.lang.Short"))
    end)
    attempt("%f Byte", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(by, nil, "java.lang.Byte"))
    end)
    attempt("%d BigDecimal", function()
        return __K2L_StringFormat("%d", __K2L_Text.typed(bd, nil, "java.math.BigDecimal"))
    end)
    attempt("%f BigInteger", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(bi, nil, "java.math.BigInteger"))
    end)
    attempt("%d UInt", function()
        return __K2L_StringFormat("%d", __K2L_Text.typed(u, nil, "kotlin.UInt"))
    end)
    attempt("%d Point", function() return __K2L_StringFormat("%d", p) end)
    attempt("%f null", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(none, nil, "java.lang.Integer"))
    end)
    attempt("%f Int?", function()
        return __K2L_StringFormat("%f", __K2L_Text.typed(some, nil, "java.lang.Integer"))
    end)
    attempt("%X Int?", function() return __K2L_StringFormat("%X", some) end)
    attempt("taken", function()
        return __K2L_StringFormat("%d %s %c %.1f %x %c %c %e %o", i, s, c, d, __K2L_Text.sized(by, 8), sh, 65, f, __K2L_Text.sized(l, 64))
    end)
    attempt("BigDecimal", function()
        return __K2L_StringFormat("%f|%.1f|%,.3f|%12.0f|%(.2f", bd, bd, bd, bd, bd:negate())
    end)
    attempt("BigInteger", function()
        return __K2L_StringFormat("%d %x %,d", bi, bi, bi:pow(4))
    end)
    attempt("strings", function()
        return __K2L_StringFormat("%s %s %s %b %h", i, __K2L_DoubleToString(d), c, i, s)
    end)
    attempt("locale", function()
        return __K2L_LocaleFormat.format("de_DE", nil, "%,.2f %f", bd, __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("locale ok", function()
        return __K2L_LocaleFormat.format("de_DE", nil, "%,.2f %d", bd, i)
    end)
    attempt("second", function()
        return __K2L_StringFormat("%s %f", i, __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("indexed", function()
        return __K2L_StringFormat("%1$s %1$d %1$f", __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("previous", function()
        return __K2L_StringFormat("%d %<f", __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("before missing", function()
        return __K2L_StringFormat("%f %s", __K2L_Text.typed(i, nil, "java.lang.Integer"))
    end)
    attempt("missing before", function()
        return __K2L_StringFormat("%s %s %f", __K2L_DoubleToString(d), __K2L_DoubleToString(d))
    end)
    local formats = __K2L_ReadOnlyListOf("%f", "%d", "%c")
    local ____mod = formats.____modCount
    for ____i = 1, formats.size do
        local format = formats[____i]
        attempt("dynamic " .. format .. " Int", function()
            return __K2L_StringFormat(format, __K2L_Text.typed(i, nil, "java.lang.Integer"))
        end)
        attempt("dynamic " .. format .. " Double", function()
            return __K2L_StringFormat(format, __K2L_Text.typed(d, nil, "java.lang.Double"))
        end)
        attempt("dynamic " .. format .. " Char", function()
            return __K2L_StringFormat(format, __K2L_Text.typed(c, nil, "java.lang.Character"))
        end)
        if formats.____modCount ~= ____mod and formats:____comodified(____i) then
            break
        end
    end
    local values = __K2L_ReadOnlyListOf(true, p, bd, bi, 2.5, "text")
    local ____mod_1 = values.____modCount
    for ____i_1 = 1, values.size do
        local v = values[____i_1]
        attempt("Any %c " .. __K2L_Str(v), function() return __K2L_StringFormat("%c", v) end)
        if values.____modCount ~= ____mod_1 and values:____comodified(____i_1) then
            break
        end
    end
    local ____mod_2 = values.____modCount
    for ____i_2 = 1, values.size do
        local v = values[____i_2]
        attempt("Any %d " .. __K2L_Str(v), function() return __K2L_StringFormat("%d", v) end)
        if values.____modCount ~= ____mod_2 and values:____comodified(____i_2) then
            break
        end
    end
end

__K2L_DeepMain(main)
return {Point = Point, attempt = attempt}
