local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_IsArray = ____lualib.__K2L_IsArray
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function kind(x)
    if __K2L_IsArray(x, "[C") then
        return "CharArray"
    elseif __K2L_IsArray(x, "[I") then
        return "IntArray"
    elseif __K2L_IsArray(x, "[J") then
        return "LongArray"
    elseif __K2L_IsArray(x, "[D") then
        return "DoubleArray"
    elseif __K2L_IsArray(x, "[F") then
        return "FloatArray"
    elseif __K2L_IsArray(x, "[Z") then
        return "BooleanArray"
    elseif __K2L_IsArray(x, "[B") then
        return "ByteArray"
    elseif __K2L_IsArray(x, "[S") then
        return "ShortArray"
    else
        return "other"
    end
end

local function main()
    local list = __K2L_ReadOnlyListOf("a", "b", "c")
    local ca = list:toCharArray()
    print(kind(ca) .. " " .. ca:joinToString("") .. " " .. ca.size)
    local col = __K2L_ReadOnlySetOf("x", "y")
    print(col:toCharArray():joinToString())
    print(kind(__K2L_ReadOnlyListOf(1, 2, 3):toIntArray()) .. " " .. __K2L_ReadOnlyListOf(1, 2, 3):toIntArray():sum())
    print(kind(__K2L_ReadOnlyListOf(1, 2):toLongArray()) .. " " .. __K2L_ReadOnlyListOf(1, 2):toLongArray():sum())
    print(kind(__K2L_ReadOnlyListOf(1.5, 2.0):toDoubleArray()) .. " " .. __K2L_DoubleToString(__K2L_ReadOnlyListOf(1.5, 2.0):toDoubleArray():sum()))
    print(kind(__K2L_ReadOnlyListOf(1.5, 2.0):toFloatArray()) .. " " .. __K2L_FloatToString(__K2L_ReadOnlyListOf(1.5, 2.0):toFloatArray():sum()))
    print(kind(__K2L_ReadOnlyListOf(true, false):toBooleanArray()) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(true, false):toBooleanArray():toList()))
    print(kind(__K2L_ReadOnlyListOf(1, 2):toByteArray()) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2):toByteArray():toList()))
    print(kind(__K2L_ReadOnlyListOf(1, 2):toShortArray()) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2):toShortArray():toList()))
    local dq = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf("c", "a", "b"))
    print(__K2L_Str(dq:toCharArray():sorted()))
    local jdq = __K2L_Deque.new(__K2L_ReadOnlyListOf("z", "y"))
    print(jdq:toCharArray():contentToString())
    print(__K2L_LinkedList.new(__K2L_ReadOnlyListOf(3, 4)):toIntArray():contentToString())
    local m = __K2L_ReadOnlyMapOf(__K2L_Pair.new("k", 1.5), __K2L_Pair.new("j", 2.5))
    print(m:getKeys():toCharArray():joinToString("") .. " " .. __K2L_DoubleToString(m:getValues():toDoubleArray():sum()))
    print(__K2L_ReadOnlyListOf("a", "b", "c", "d"):subList(1, 3):toCharArray():joinToString(""))
    print(__K2L_HashSetOf(1, 2):toLongArray():sum())
    print(__K2L_ListOf(true):toBooleanArray():contentToString())
    print(__K2L_SingletonListOf(1.25):toFloatArray():contentToString())
    print(__K2L_ReadOnlyListOf():toCharArray().size)
    print(__K2L_TypedArrayOf("[Ljava.lang.Character;", "q", "r"):toCharArray():joinToString(""))
    print(kind(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2):toIntArray()) .. " " .. __K2L_Str(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2):toIntArray():toList()))
    print(__K2L_TypedArrayOf("[Ljava.lang.Double;", 1.5, 2.5):toDoubleArray():contentToString())
    print(__K2L_TypedArrayOf("[Ljava.lang.Boolean;", true):toBooleanArray():contentToString())
    print(__K2L_TypedArrayOf("[Ljava.lang.Long;", 7):toLongArray():contentToString())
    print(__K2L_TypedArrayOf("[Ljava.lang.Byte;", 7):toByteArray():contentToString())
    local chars = __K2L_StringToList("hello"):sortedDescending():toCharArray()
    print(__K2L_Text.string(chars))
    print(chars:contentEquals(__K2L_TypedArrayOf("[C", "o", "l", "l", "h", "e")))
    print(chars:contains("l"))
    print(chars:toHashSet().size)
    print(chars:toList():joinToString(""))
    local ____value = chars:toMutableList()
    ____value:add("!")
    print(__K2L_Str(____value))
    print(__K2L_Str(chars:toSet()))
    print(__K2L_Str(chars:asList(8)))
    print(__K2L_Str(chars:reversed()))
    local boxed = chars:toTypedArray("[Ljava.lang.Character;")
    print(boxed:toCharArray():contentToString())
    print(chars:indexOf("h"))
    print(chars:copyOfSize(2, "\000"):joinToString(""))
    print(__K2L_Str(__K2L_TypedArrayOf("[I", 1, 2):toList()))
    print(__K2L_Str(__K2L_TypedArrayOf("[I", 1, 2):toTypedArray("[Ljava.lang.Integer;"):toList()))
    print(__K2L_Str(__K2L_ReadOnlySetOf(1, 2):toIntArray():toList()))
    print(__K2L_SingletonListOf("a"):toTypedArray("[Ljava.lang.Character;"):toCharArray():joinToString(""))
    print(__K2L_SequenceOf("a", "b"):toList():toCharArray().size)
    print(__K2L_StringToList("abc"):toCharArray():joinToString(""))
end

__K2L_Main(main)
return {kind = kind}
