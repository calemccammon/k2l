local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IsArray = ____lualib.__K2L_IsArray
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function describe(x)
    return __K2L_Str(__K2L_KClassOfValue(x).simpleName) .. " " .. __K2L_Str(__K2L_KClassOfValue(x).qualifiedName) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(x)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(x)).simpleName or "") .. " " .. __K2L_Str(__K2L_KClassOfValue(x))
end

local function generic(x)
    if x == nil then
        __K2L_CastFail(x, "java.lang.Object", "kotlin.Any")
    end
    return __K2L_JavaClass(__K2L_KClassOfValue(x)).name
end

local ____lambda_1 = function(it) return it end
local ____lambda_2 = function(it) return "x" .. it end
local function main()
    local items = __K2L_ReadOnlyListOf(__K2L_TypedArrayOf("[I", 1), __K2L_ListOfSize(2, 0, "[I"), __K2L_ListOfSize(2, ____lambda_1, "[I"), __K2L_TypedArrayOf("[J", 1), __K2L_TypedArrayOf("[D", 1.0), __K2L_TypedArrayOf("[Z", true), __K2L_TypedArrayOf("[C", "a"), __K2L_TypedArrayOf("[S", 1), __K2L_TypedArrayOf("[B", 1), __K2L_TypedArrayOf("[F", 1.0), __K2L_TypedArrayOf("[Ljava.lang.String;", "a"), __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2), __K2L_ListOfSize(2, ____lambda_2, "[Ljava.lang.String;"), __K2L_ListOfSize(2, nil, "[Ljava.lang.String;"), __K2L_TypedArrayOf("[Ljava.lang.Integer;"), __K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1)), __K2L_SingletonListOf("a"):toTypedArray("[Ljava.lang.String;"), __K2L_Text.toCharArray("ab"), __K2L_ReadOnlyListOf(1, 2):toIntArray(), __K2L_ArrayOf(1), __K2L_TypedArrayOf("[I", 3, 1):sortedArray(), __K2L_TypedArrayOf("[I", 1):copyOfSize(3, 0), __K2L_TypedArrayOf("[Ljava.lang.String;", "b", "a"):copyOfRange(0, 1), __K2L_TypedArrayOf("kotlin.UIntArray", 1))
    local ____mod = items.____modCount
    for ____i = 1, items.size do
        local x = items[____i]
        print(describe(x))
        if items.____modCount ~= ____mod and items:____comodified(____i) then
            break
        end
    end
    print(generic(__K2L_TypedArrayOf("[I", 1)))
    print(generic(__K2L_TypedArrayOf("[Ljava.lang.String;", "a")))
    local s = __K2L_Str(__K2L_TypedArrayOf("[I", 1))
    print(__K2L_StringStartsWith(s, "[I@"))
    print(__K2L_StringStartsWith(__K2L_Str(__K2L_TypedArrayOf("[Ljava.lang.String;", "a")), "[Ljava.lang.String;@"))
    print(__K2L_StringStartsWith(__K2L_Str(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 1)), "[Ljava.lang.Integer;@"))
    print(__K2L_StringStartsWith(__K2L_Str(__K2L_TypedArrayOf("[D", 1.0)), "[D@"))
    print(__K2L_StringStartsWith(__K2L_Str(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1))), "[[I@"))
    local a = __K2L_TypedArrayOf("[I", 1)
    local b = __K2L_TypedArrayOf("[Ljava.lang.String;", "a")
    print(tostring(__K2L_IsArray(a, "[I")) .. " " .. tostring(__K2L_IsArray(a)) .. " " .. tostring(__K2L_IsArray(b, "[I")) .. " " .. tostring(__K2L_IsArray(b)) .. " " .. tostring(__K2L_IsArray(a, "[J")) .. " " .. tostring(__K2L_IsArray(b)))
    print(__K2L_TypedArrayOf("[I", 1):contentToString() .. " " .. __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2):contentToString())
    print(__K2L_StringStartsWith(__K2L_Str(__K2L_SingletonListOf(__K2L_TypedArrayOf("[I", 1))), "[[I@"))
    print(__K2L_Hash(a) == __K2L_Hash(a))
    print(__K2L_Equals(a, __K2L_TypedArrayOf("[I", 1)))
end

main()
return {describe = describe, generic = generic}
