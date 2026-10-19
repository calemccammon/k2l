local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Person = __K2L_Class("Person")

function Person:____init(name)
    self.name = name
end

function Person:toString()
    return "Person(name=" .. self.name .. ")"
end

function Person:hashCode()
    return __K2L_Hash(self.name)
end

function Person:equals(other)
    return getmetatable(other) == Person and self.name == other.name
end

local function kind(x)
    if math.type(x) == "integer" then
        return "int"
    elseif x == nil or type(x) == "string" then
        return "string or null"
    else
        return "other"
    end
end

local function main()
    local none = nil
    local text = "t"
    local num = 4
    print(tostring(none == nil or type(none) == "string") .. " " .. tostring(type(none) == "string") .. " " .. tostring(text == nil or type(text) == "string") .. " " .. tostring(num == nil or type(num) == "string") .. " " .. tostring(not (num == nil or math.type(num) == "integer")))
    print(kind(nil) .. " " .. kind("s") .. " " .. kind(1) .. " " .. kind(Person.new("p")))
    local ____result
    ____result = nil == nil or type(nil) == "string"
    local ____arg = ____result
    local ____result_1
    ____result_1 = type(nil) == "string"
    local ____arg_1 = ____result_1
    local ____result_2
    ____result_2 = "s" == nil or type("s") == "string"
    local ____arg_2 = ____result_2
    local ____result_3
    ____result_3 = 1 == nil or type(1) == "string"
    local ____arg_3 = ____result_3
    local ____result_4
    do
        local ____this = Person.new("a")
        ____result_4 = ____this == nil or __K2L_InstanceOf(____this, Person)
    end
    print(tostring(____arg) .. " " .. tostring(____arg_1) .. " " .. tostring(____arg_2) .. " " .. tostring(____arg_3) .. " " .. tostring(____result_4))
    local ____result_5
    do
        local ____this_1 = __K2L_ReadOnlyListOf(1, "x", Person.new("p"))
        local ____cast = ____this_1:firstOrNull(function(it) return __K2L_InstanceOf(it, Person) end)
        if not (____cast == nil or __K2L_InstanceOf(____cast, Person)) then
            __K2L_CastFail(____cast, "Person", "Person")
        end
        ____result_5 = ____cast
    end
    local ____arg_4 = ____result_5
    local ____result_6
    do
        local ____this_2 = __K2L_SingletonListOf(1)
        local ____cast_1 = ____this_2:firstOrNull(function(it) return __K2L_InstanceOf(it, Person) end)
        if not (____cast_1 == nil or __K2L_InstanceOf(____cast_1, Person)) then
            __K2L_CastFail(____cast_1, "Person", "Person")
        end
        ____result_6 = ____cast_1
    end
    local ____arg_5 = ____result_6
    local ____result_7
    do
        local ____this_3 = __K2L_ReadOnlyListOf(nil, 2)
        local ____cast_2 = ____this_3:firstOrNull(function(it) return math.type(it) == "integer" end)
        if not (____cast_2 == nil or math.type(____cast_2) == "integer") then
            __K2L_CastFail(____cast_2, "java.lang.Integer", "kotlin.Int")
        end
        ____result_7 = ____cast_2
    end
    print(__K2L_Str(____arg_4) .. " " .. __K2L_Str(____arg_5) .. " " .. __K2L_Str(____result_7))
    local ____result_8
    do
        local ____this_4 = __K2L_ReadOnlyListOf(nil, "a", 1, nil)
        ____result_8 = ____this_4:count(function(it) return it == nil or type(it) == "string" end)
    end
    local ____arg_6 = ____result_8
    local ____result_9
    do
        local ____this_5 = __K2L_ReadOnlyListOf(1, 2)
        ____result_9 = ____this_5:count(function(it) return it == nil or type(it) == "string" end)
    end
    print(____arg_6 .. " " .. ____result_9)
    if not (none == nil or type(none) == "string") then
        __K2L_CastFail(none, "java.lang.String", "kotlin.String")
    end
    local s = none
    local p = (text == nil or math.type(text) == "integer") and text or nil
    print(__K2L_Str(s) .. " " .. __K2L_Str(p) .. " " .. __K2L_Str((num == nil or math.type(num) == "integer") and num or nil))
    local ____ok, ____result_10 = pcall(function()
        if not (num == nil or type(num) == "string") then
            __K2L_CastFail(num, "java.lang.String", "kotlin.String")
        end
        print(__K2L_Str(num))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_10)
        if __K2L_InstanceOf(____error, __K2L_ClassCastException) then
            local e = ____error
            print("ClassCastException")
        else
            error(____error, 0)
        end
    end
end

main()
return {Person = Person, kind = kind}
