local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IsArray = ____lualib.__K2L_IsArray
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local function kind(x)
    return __K2L_IsArray(x) and "array" or "other"
end

local function main()
    local list = __K2L_ListOf("a", "b", "c")
    local ca = list:toCharArray()
    print(kind(ca) .. " " .. ca:joinToString("") .. " " .. ca.size)
    local col = __K2L_SetOf("x", "y")
    print(col:toCharArray():joinToString())
    print(kind(__K2L_ListOf(1, 2, 3):toIntArray()) .. " " .. __K2L_ListOf(1, 2, 3):toIntArray():sum())
    print(kind(__K2L_ListOf(1, 2):toLongArray()) .. " " .. __K2L_ListOf(1, 2):toLongArray():sum())
    print(kind(__K2L_ListOf(1.5, 2.0):toDoubleArray()) .. " " .. __K2L_ListOf(1.5, 2.0):toDoubleArray():sum())
    print(kind(__K2L_ListOf(1.5, 2.0):toFloatArray()) .. " " .. __K2L_ListOf(1.5, 2.0):toFloatArray():sum())
    print(kind(__K2L_ListOf(true, false):toBooleanArray()) .. " " .. __K2L_Str(__K2L_ListOf(true, false):toBooleanArray():toList()))
    print(kind(__K2L_ListOf(1, 2):toByteArray()) .. " " .. __K2L_Str(__K2L_ListOf(1, 2):toByteArray():toList()))
    print(kind(__K2L_ListOf(1, 2):toShortArray()) .. " " .. __K2L_Str(__K2L_ListOf(1, 2):toShortArray():toList()))
    local dq = __K2L_ArrayDeque.new(__K2L_ListOf("c", "a", "b"))
    print(__K2L_Str(dq:toCharArray():sorted()))
    print(__K2L_ListOf(3, 4):toIntArray():contentToString())
    local m = __K2L_MapOf(__K2L_Pair.new("k", 1.5), __K2L_Pair.new("j", 2.5))
    print(m:getKeys():toCharArray():joinToString("") .. " " .. m:getValues():toDoubleArray():sum())
    print(__K2L_ListOf("a", "b", "c", "d"):subList(1, 3):toCharArray():joinToString(""))
    print(__K2L_SetOf(1, 2):toLongArray():sum())
    print(__K2L_ListOf(true):toBooleanArray():contentToString())
    print(__K2L_ListOf(1.25):toFloatArray():contentToString())
    print(__K2L_ListOf():toCharArray().size)
    print(__K2L_ArrayOf("q", "r"):toCharArray():joinToString(""))
    print(kind(__K2L_ArrayOf(1, 2):toIntArray()) .. " " .. __K2L_Str(__K2L_ArrayOf(1, 2):toIntArray():toList()))
    print(__K2L_ArrayOf(1.5, 2.5):toDoubleArray():contentToString())
    print(__K2L_ArrayOf(true):toBooleanArray():contentToString())
    print(__K2L_ArrayOf(7):toLongArray():contentToString())
    print(__K2L_ArrayOf(7):toByteArray():contentToString())
    local chars = __K2L_StringToList("hello"):sortedDescending():toCharArray()
    print(__K2L_Text.string(chars))
    print(chars:contentEquals(__K2L_ArrayOf("o", "l", "l", "h", "e")))
    print(chars:contains("l"))
    print(chars:toHashSet().size)
    print(chars:toList():joinToString(""))
    local ____value = chars:toMutableList()
    ____value:add("!")
    print(__K2L_Str(____value))
    print(__K2L_Str(chars:toSet()))
    print(__K2L_Str(chars:asList()))
    print(__K2L_Str(chars:reversed()))
    local boxed = chars:toTypedArray()
    print(boxed:toCharArray():contentToString())
    print(chars:indexOf("h"))
    print(chars:copyOfSize(2, "\000"):joinToString(""))
    print(__K2L_Str(__K2L_ArrayOf(1, 2):toList()))
    print(__K2L_Str(__K2L_ArrayOf(1, 2):toTypedArray():toList()))
    print(__K2L_Str(__K2L_SetOf(1, 2):toIntArray():toList()))
    print(__K2L_ListOf("a"):toTypedArray():toCharArray():joinToString(""))
    print(__K2L_SequenceOf("a", "b"):toList():toCharArray().size)
    print(__K2L_StringToList("abc"):toCharArray():joinToString(""))
    local arr = __K2L_ArrayOf(1, 2)
    print(__K2L_Str(arr) .. " " .. __K2L_Str(__K2L_ArrayOf("x")) .. " " .. tostring(__K2L_Equals(arr, __K2L_ArrayOf(1, 2))) .. " " .. tostring(arr:contentEquals(__K2L_ArrayOf(1, 2))))
end

__K2L_RunMain(main)
return {kind = kind}
