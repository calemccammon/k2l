local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NullPointerException = ____lualib.__K2L_NullPointerException
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Animal = __K2L_Class("Animal")

function Animal:____init(name)
    self.name = name
end

local Dog = __K2L_Class("Dog", Animal)

function Dog:____init(name)
    Animal.____init(self, name)
end

function Dog:bark()
    return "woof from " .. self.name
end

local Cat = __K2L_Class("Cat", Animal)

function Cat:____init(name)
    Animal.____init(self, name)
end

local Shape = __K2L_Class("Shape")
local Square = __K2L_Class("Square", nil, Shape)
local Single = __K2L_Class("Single")

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ClassCastException) then
            local e = ____error
            print(label .. ": ClassCastException")
        elseif __K2L_InstanceOf(____error, __K2L_NullPointerException) then
            local e = ____error
            print(label .. ": NullPointerException")
        else
            error(____error, 0)
        end
    end
end

local function unchecked(x)
    return x
end

local function describe(x)
    if type(x) == "string" then
        local s = x
        return s:upper()
    end
    return "other"
end

local function main()
    local animal = Dog.new("rex")
    if not __K2L_InstanceOf(animal, Dog) then
        __K2L_CastFail(animal, "Dog", "Dog")
    end
    print(animal:bark())
    attempt("cat", function()
        if not __K2L_InstanceOf(animal, Cat) then
            __K2L_CastFail(animal, "Cat", "Cat")
        end
        return animal.name
    end)
    local any = "text"
    if type(any) ~= "string" then
        __K2L_CastFail(any, "java.lang.String", "kotlin.String")
    end
    print(any)
    attempt("string as Int", function()
        if math.type(any) ~= "integer" then
            __K2L_CastFail(any, "java.lang.Integer", "kotlin.Int")
        end
        return any
    end)
    local number = 42
    if math.type(number) ~= "integer" then
        __K2L_CastFail(number, "java.lang.Integer", "kotlin.Int")
    end
    print(number)
    attempt("int as String", function()
        if type(number) ~= "string" then
            __K2L_CastFail(number, "java.lang.String", "kotlin.String")
        end
        return number
    end)
    attempt("int as Boolean", function()
        if type(number) ~= "boolean" then
            __K2L_CastFail(number, "java.lang.Boolean", "kotlin.Boolean")
        end
        return number
    end)
    local flag = true
    if type(flag) ~= "boolean" then
        __K2L_CastFail(flag, "java.lang.Boolean", "kotlin.Boolean")
    end
    print(flag)
    attempt("boolean as String", function()
        if type(flag) ~= "string" then
            __K2L_CastFail(flag, "java.lang.String", "kotlin.String")
        end
        return flag
    end)
    local nothing = nil
    if not (nothing == nil or type(nothing) == "string") then
        __K2L_CastFail(nothing, "java.lang.String", "kotlin.String")
    end
    print(__K2L_Str(nothing))
    if not (nothing == nil or math.type(nothing) == "integer") then
        __K2L_CastFail(nothing, "java.lang.Integer", "kotlin.Int")
    end
    print(__K2L_Str(nothing))
    attempt("null as String", function()
        if type(nothing) ~= "string" then
            __K2L_CastFail(nothing, "java.lang.String", "kotlin.String")
        end
        return nothing
    end)
    attempt("null as Dog", function()
        if not __K2L_InstanceOf(nothing, Dog) then
            __K2L_CastFail(nothing, "Dog", "Dog")
        end
        return nothing
    end)
    local shape = Square.new()
    print(__K2L_InstanceOf(shape, Shape))
    if not __K2L_InstanceOf(shape, Shape) then
        __K2L_CastFail(shape, "Shape", "Shape")
    end
    print(shape == shape)
    attempt("square as Animal", function()
        if not __K2L_InstanceOf(shape, Animal) then
            __K2L_CastFail(shape, "Animal", "Animal")
        end
        return shape
    end)
    attempt("object", function() return Single == Single end)
    attempt("string as Single", function()
        if "x" ~= Single then
            __K2L_CastFail("x", "Single", "Single")
        end
        return "x"
    end)
    local list = __K2L_ReadOnlyListOf(1, 2, 3)
    if not __K2L_InstanceOf(list, __K2L_List) then
        __K2L_CastFail(list, "java.util.List", "kotlin.collections.List")
    end
    print(list.size)
    if not __K2L_InstanceOf(list, __K2L_List) then
        __K2L_CastFail(list, "java.util.List", "kotlin.collections.List")
    end
    print(list.size)
    attempt("list as Map", function()
        if not __K2L_InstanceOf(list, __K2L_Map) then
            __K2L_CastFail(list, "java.util.Map", "kotlin.collections.Map")
        end
        return list
    end)
    attempt("string as List", function()
        if not __K2L_InstanceOf(any, __K2L_List) then
            __K2L_CastFail(any, "java.util.List", "kotlin.collections.List")
        end
        return any
    end)
    print(unchecked("fine"))
    print(describe("abc"))
    print(describe(1))
    local upcast = Dog.new("up")
    print(upcast.name)
    local d = 2.5
    local anyD = d
    if math.type(anyD) ~= "float" then
        __K2L_CastFail(anyD, "java.lang.Double", "kotlin.Double")
    end
    print(__K2L_Str(anyD))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", 1):map(function(it) return type(it) == "string" and it or "n" end)))
    attempt("in args", function()
        local ____arg = 1 + 1
        if math.type(any) ~= "integer" then
            __K2L_CastFail(any, "java.lang.Integer", "kotlin.Int")
        end
        return __K2L_ReadOnlyListOf(____arg, any + 1)
    end)
    local ____ok_1, ____result_1 = pcall(function()
        if math.type(any) ~= "integer" then
            __K2L_CastFail(any, "java.lang.Integer", "kotlin.Int")
        end
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_ClassCastException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = pcall(function()
        if not __K2L_InstanceOf(animal, Cat) then
            __K2L_CastFail(animal, "Cat", "Cat")
        end
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_ClassCastException) then
            local e = ____error_2
            local ____receiver = e.message
            print(__K2L_Str(____receiver and __K2L_Text.substringBefore(____receiver, " (")))
        else
            error(____error_2, 0)
        end
    end
end

main()
return {Animal = Animal, Dog = Dog, Cat = Cat, Shape = Shape, Square = Square, Single = Single, attempt = attempt, unchecked = unchecked, describe = describe}
