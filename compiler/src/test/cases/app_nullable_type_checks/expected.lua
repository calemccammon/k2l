local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
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

function Person.new(name)
    return setmetatable({name = name}, Person)
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
    local ____arg = tostring(____result)
    local ____result_1
    ____result_1 = type(nil) == "string"
    local ____arg_1 = tostring(____result_1)
    local ____result_2
    ____result_2 = "s" == nil or type("s") == "string"
    local ____arg_2 = tostring(____result_2)
    local ____result_3
    ____result_3 = 1 == nil or type(1) == "string"
    local ____arg_3 = tostring(____result_3)
    local ____result_4
    do
        local ____this = Person.new("a")
        ____result_4 = ____this == nil or getmetatable(____this) == Person
    end
    print(____arg .. " " .. ____arg_1 .. " " .. ____arg_2 .. " " .. ____arg_3 .. " " .. tostring(____result_4))
    local ____result_5
    do
        local ____this_1 = __K2L_ReadOnlyListOf(1, "x", Person.new("p"))
        local ____result_6
        local ____items, ____n = ____this_1:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if getmetatable(it) == Person then
                ____result_6 = it
                break
            end
        end
        if not (____result_6 == nil or getmetatable(____result_6) == Person) then
            __K2L_CastFail(____result_6, "Person", "Person")
        end
        ____result_5 = ____result_6
    end
    local ____arg_4 = __K2L_Str(____result_5)
    local ____result_7
    do
        local ____this_2 = __K2L_SingletonListOf(1)
        local ____result_8
        local ____items_1, ____n_1 = ____this_2:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            if getmetatable(it) == Person then
                ____result_8 = it
                break
            end
        end
        if not (____result_8 == nil or getmetatable(____result_8) == Person) then
            __K2L_CastFail(____result_8, "Person", "Person")
        end
        ____result_7 = ____result_8
    end
    local ____arg_5 = __K2L_Str(____result_7)
    local ____result_9
    do
        local ____this_3 = __K2L_ReadOnlyListOf(nil, 2)
        local ____result_10
        local ____items_2, ____n_2 = ____this_3:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            if math.type(it) == "integer" then
                ____result_10 = it
                break
            end
        end
        if not (____result_10 == nil or math.type(____result_10) == "integer") then
            __K2L_CastFail(____result_10, "java.lang.Integer", "kotlin.Int")
        end
        ____result_9 = ____result_10
    end
    print(____arg_4 .. " " .. ____arg_5 .. " " .. __K2L_Str(____result_9))
    local ____result_11
    do
        local ____this_4 = __K2L_ReadOnlyListOf(nil, "a", 1, nil)
        local ____result_12 = 0
        local ____items_3, ____n_3 = ____this_4:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            if it == nil or type(it) == "string" then
                ____result_12 = ____result_12 + 1
            end
        end
        ____result_11 = ____result_12
    end
    local ____arg_6 = ____result_11
    local ____result_13
    do
        local ____this_5 = __K2L_ReadOnlyListOf(1, 2)
        local ____result_14 = 0
        local ____items_4, ____n_4 = ____this_5:____array()
        for ____i_4 = 1, ____n_4 do
            local it = ____items_4[____i_4]
            if it == nil or type(it) == "string" then
                ____result_14 = ____result_14 + 1
            end
        end
        ____result_13 = ____result_14
    end
    print(____arg_6 .. " " .. ____result_13)
    if not (none == nil or type(none) == "string") then
        __K2L_CastFail(none, "java.lang.String", "kotlin.String")
    end
    local s = none
    local p = (text == nil or math.type(text) == "integer") and text or nil
    print(__K2L_Str(s) .. " " .. __K2L_Str(p) .. " " .. __K2L_Str((num == nil or math.type(num) == "integer") and num or nil))
    local ____ok, ____result_15 = __K2L_DeepPcall(function()
        if not (num == nil or type(num) == "string") then
            __K2L_CastFail(num, "java.lang.String", "kotlin.String")
        end
        print(__K2L_Str(num))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_15)
        if __K2L_InstanceOf(____error, __K2L_ClassCastException) then
            local e = ____error
            print("ClassCastException")
        else
            error(____error, 0)
        end
    end
end

__K2L_DeepMain(main)
return {Person = Person, kind = kind}
