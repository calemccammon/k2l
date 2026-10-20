local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unpack = ____lualib.__K2L_Unpack

local function unsafeCast(x)
    return x
end

local function firstOf(x)
    if not __K2L_InstanceOf(x, __K2L_List) then
        __K2L_CastFail(x, "java.util.List", "kotlin.collections.List")
    end
    return x:get(0)
end

local Box = __K2L_Class("Box")

function Box:____init(value)
    self.value = value
end

function Box.new(value)
    return setmetatable({value = value}, Box)
end

function Box:get()
    return self.value
end

function Box:getCurrent()
    return self.value
end

local Slots = __K2L_Class("Slots")

function Slots:____init(...)
    local values = __K2L_ArrayOf(...)
    self.items = __K2L_ArrayOf(__K2L_Unpack(values))
end

function Slots:get(i)
    return self.items:get(i)
end

local Stack = __K2L_Class("Stack")

function Stack:____init()
    self.items = __K2L_List.new()
end

function Stack:push(x)
    return self.items:add(x)
end

function Stack:pop()
    return self.items:removeAt(self.items.size - 1)
end

local function returnsString()
    local ____value = unsafeCast(5)
    if ____value ~= nil and type(____value) ~= "string" then
        __K2L_CastFail(____value, "java.lang.String", "kotlin.String")
    end
    return ____value
end

local function returnsAny()
    return unsafeCast(5)
end

local function takesString(s)
    return "takes " .. s
end

local function takesAny(a)
    return "any " .. __K2L_Str(a)
end

local function generic(t)
    return "generic " .. __K2L_Str(t)
end

local function attempt(label, block)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ClassCastException) then
            local e = ____error
            print(label .. ": CCE " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_RuntimeException) then
            local e = ____error
            print(label .. ": NPE " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function() return unsafeCast(5) end
local ____lambda_2 = function() return takesAny(unsafeCast(5)) end
local ____lambda_3 = function() return generic(unsafeCast(5)) end
local ____lambda_4 = function() return returnsString() end
local ____lambda_5 = function() return returnsAny() end
local ____lambda_6 = function() return unsafeCast(5) == "5" end
local function main()
    attempt("val typed", function()
        local ____value_1 = unsafeCast(5)
        if ____value_1 ~= nil and type(____value_1) ~= "string" then
            __K2L_CastFail(____value_1, "java.lang.String", "kotlin.String")
        end
        local s = ____value_1
        return "ok"
    end)
    attempt("val inferred", function()
        local ____value_2 = unsafeCast(5)
        if ____value_2 ~= nil and type(____value_2) ~= "string" then
            __K2L_CastFail(____value_2, "java.lang.String", "kotlin.String")
        end
        local s = ____value_2
        return "ok"
    end)
    attempt("val inferred used", function()
        local ____value_3 = unsafeCast(5)
        if ____value_3 ~= nil and type(____value_3) ~= "string" then
            __K2L_CastFail(____value_3, "java.lang.String", "kotlin.String")
        end
        local s = ____value_3
        return s
    end)
    attempt("println arg", function()
        print(unsafeCast(5))
        return "printed"
    end)
    attempt("template", ____lambda_1)
    attempt("length", function()
        local ____value_4 = unsafeCast(5)
        if ____value_4 ~= nil and type(____value_4) ~= "string" then
            __K2L_CastFail(____value_4, "java.lang.String", "kotlin.String")
        end
        return #____value_4
    end)
    attempt("concrete param", function()
        local ____value_5 = unsafeCast(5)
        if ____value_5 ~= nil and type(____value_5) ~= "string" then
            __K2L_CastFail(____value_5, "java.lang.String", "kotlin.String")
        end
        return takesString(____value_5)
    end)
    attempt("any param", ____lambda_2)
    attempt("generic param", ____lambda_3)
    attempt("return as String", function()
        local f = function()
            local ____value_6 = unsafeCast(5)
            if ____value_6 ~= nil and type(____value_6) ~= "string" then
                __K2L_CastFail(____value_6, "java.lang.String", "kotlin.String")
            end
            return ____value_6
        end
        return f()
    end)
    attempt("lambda result", function()
        local ____list = __K2L_SingletonListOf(1)
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            local ____result_1
            do
                local ____value_7 = unsafeCast(it)
                if ____value_7 ~= nil and type(____value_7) ~= "string" then
                    __K2L_CastFail(____value_7, "java.lang.String", "kotlin.String")
                end
                ____result_1 = ____value_7
            end
            ____count = ____count + 1
            ____out[____count] = ____result_1
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    attempt("int", function()
        local ____value_8 = unsafeCast("x")
        if ____value_8 ~= nil and type(____value_8) ~= "number" then
            __K2L_CastFail(____value_8, "java.lang.Number", "kotlin.Number")
        end
        local i = ____value_8
        return i
    end)
    attempt("int plus", function()
        local ____value_9 = unsafeCast("x")
        if ____value_9 ~= nil and type(____value_9) ~= "number" then
            __K2L_CastFail(____value_9, "java.lang.Number", "kotlin.Number")
        end
        return ____value_9 + 1
    end)
    attempt("null to String", function()
        local ____value_10 = unsafeCast(nil)
        if ____value_10 ~= nil and type(____value_10) ~= "string" then
            __K2L_CastFail(____value_10, "java.lang.String", "kotlin.String")
        end
        local s = ____value_10
        return s
    end)
    attempt("null to String?", function()
        local ____value_11 = unsafeCast(nil)
        if ____value_11 ~= nil and type(____value_11) ~= "string" then
            __K2L_CastFail(____value_11, "java.lang.String", "kotlin.String")
        end
        local s = ____value_11
        return s
    end)
    attempt("reified", function()
        local ____result_2
        if type(5) ~= "string" then
            __K2L_CastFail(5, "java.lang.String", "kotlin.String")
        end
        ____result_2 = 5
        return ____result_2
    end)
    attempt("reified to Any", function()
        local ____result_3
        if type(5) ~= "string" then
            __K2L_CastFail(5, "java.lang.String", "kotlin.String")
        end
        ____result_3 = 5
        local a = ____result_3
        return a
    end)
    attempt("reified println", function()
        local ____result_4
        if type(5) ~= "string" then
            __K2L_CastFail(5, "java.lang.String", "kotlin.String")
        end
        ____result_4 = 5
        print(____result_4)
        return "printed"
    end)
    attempt("reified null", function()
        local ____result_5
        if type(nil) ~= "string" then
            __K2L_CastFail(nil, "java.lang.String", "kotlin.String")
        end
        ____result_5 = nil
        return ____result_5
    end)
    attempt("reified nullable", function()
        local ____result_6
        if not (nil == nil or type(nil) == "string") then
            __K2L_CastFail(nil, "java.lang.String", "kotlin.String")
        end
        ____result_6 = nil
        return ____result_6
    end)
    attempt("reified list", function()
        local ____result_7
        do
            local x = __K2L_SingletonListOf(1)
            if not __K2L_InstanceOf(x, __K2L_List) then
                __K2L_CastFail(x, "java.util.List", "kotlin.collections.List")
            end
            ____result_7 = x
        end
        return ____result_7
    end)
    attempt("list cast elem println", function()
        local ____cast = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast, __K2L_List) then
            __K2L_CastFail(____cast, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast
        print(l:get(0))
        return "printed"
    end)
    attempt("list cast elem length", function()
        local ____cast_1 = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast_1, __K2L_List) then
            __K2L_CastFail(____cast_1, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast_1
        local ____value_12 = l:get(0)
        if ____value_12 ~= nil and type(____value_12) ~= "string" then
            __K2L_CastFail(____value_12, "java.lang.String", "kotlin.String")
        end
        return #____value_12
    end)
    attempt("list cast elem val", function()
        local ____cast_2 = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast_2, __K2L_List) then
            __K2L_CastFail(____cast_2, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast_2
        local ____value_13 = l:get(0)
        if ____value_13 ~= nil and type(____value_13) ~= "string" then
            __K2L_CastFail(____value_13, "java.lang.String", "kotlin.String")
        end
        local s = ____value_13
        return s
    end)
    attempt("list cast elem first", function()
        local ____cast_3 = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast_3, __K2L_List) then
            __K2L_CastFail(____cast_3, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast_3
        local ____value_14 = l:first()
        if ____value_14 ~= nil and type(____value_14) ~= "string" then
            __K2L_CastFail(____value_14, "java.lang.String", "kotlin.String")
        end
        return #____value_14
    end)
    attempt("list cast for", function()
        local ____cast_4 = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast_4, __K2L_List) then
            __K2L_CastFail(____cast_4, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast_4
        local n = 0
        for ____i_1 = 1, l.size do
            local s = l[____i_1]
            local ____value_15 = s
            if ____value_15 ~= nil and type(____value_15) ~= "string" then
                __K2L_CastFail(____value_15, "java.lang.String", "kotlin.String")
            end
            n = n + #s
        end
        return n
    end)
    attempt("list cast for print", function()
        local ____cast_5 = __K2L_SingletonListOf(1)
        if not __K2L_InstanceOf(____cast_5, __K2L_List) then
            __K2L_CastFail(____cast_5, "java.util.List", "kotlin.collections.List")
        end
        local l = ____cast_5
        for ____i_2 = 1, l.size do
            local s = l[____i_2]
            local ____value_16 = s
            if ____value_16 ~= nil and type(____value_16) ~= "string" then
                __K2L_CastFail(____value_16, "java.lang.String", "kotlin.String")
            end
            print(s)
        end
        return "done"
    end)
    attempt("firstOf", function()
        local ____value_17 = firstOf(__K2L_SingletonListOf(1))
        if ____value_17 ~= nil and type(____value_17) ~= "string" then
            __K2L_CastFail(____value_17, "java.lang.String", "kotlin.String")
        end
        return #____value_17
    end)
    attempt("box", function()
        local ____value_18 = Box.new(5):get()
        if ____value_18 ~= nil and type(____value_18) ~= "string" then
            __K2L_CastFail(____value_18, "java.lang.String", "kotlin.String")
        end
        return #____value_18
    end)
    attempt("box val", function()
        local ____value_19 = Box.new(5):get()
        if ____value_19 ~= nil and type(____value_19) ~= "string" then
            __K2L_CastFail(____value_19, "java.lang.String", "kotlin.String")
        end
        local s = ____value_19
        return s
    end)
    attempt("map get", function()
        local ____cast_6 = __K2L_SingletonMapOf(__K2L_Pair.new("a", 1))
        if not __K2L_InstanceOf(____cast_6, __K2L_Map) then
            __K2L_CastFail(____cast_6, "java.util.Map", "kotlin.collections.Map")
        end
        local m = ____cast_6
        local ____value_20 = m:get("a")
        if ____value_20 ~= nil and type(____value_20) ~= "string" then
            __K2L_CastFail(____value_20, "java.lang.String", "kotlin.String")
        end
        return #__K2L_NotNull(____value_20)
    end)
    attempt("box property", function()
        local ____value_21 = Box.new(5):getCurrent()
        if ____value_21 ~= nil and type(____value_21) ~= "string" then
            __K2L_CastFail(____value_21, "java.lang.String", "kotlin.String")
        end
        return ____value_21:upper()
    end)
    attempt("if branch", function()
        local s
        if true then
            local ____value_22 = unsafeCast(5)
            if ____value_22 ~= nil and type(____value_22) ~= "string" then
                __K2L_CastFail(____value_22, "java.lang.String", "kotlin.String")
            end
            s = ____value_22
        else
            s = "x"
        end
        return s
    end)
    attempt("if statement", function()
        if true then
            local ____value_23 = unsafeCast(5)
            if ____value_23 ~= nil and type(____value_23) ~= "string" then
                __K2L_CastFail(____value_23, "java.lang.String", "kotlin.String")
            end
        end
        return "unused"
    end)
    attempt("when branch", function()
        local s
        if 2 == 1 then
            s = "one"
        else
            local ____value_24 = unsafeCast(5)
            if ____value_24 ~= nil and type(____value_24) ~= "string" then
                __K2L_CastFail(____value_24, "java.lang.String", "kotlin.String")
            end
            s = ____value_24
        end
        return s
    end)
    attempt("elvis", function()
        local ____value_25 = unsafeCast(5)
        if ____value_25 ~= nil and type(____value_25) ~= "string" then
            __K2L_CastFail(____value_25, "java.lang.String", "kotlin.String")
        end
        local s = ____value_25 or "none"
        return s
    end)
    attempt("not null", function()
        local ____value_26 = unsafeCast(5)
        if ____value_26 ~= nil and type(____value_26) ~= "string" then
            __K2L_CastFail(____value_26, "java.lang.String", "kotlin.String")
        end
        local s = __K2L_NotNull(____value_26)
        return s
    end)
    attempt("statement", function()
        unsafeCast(5)
        return "unused"
    end)
    attempt("return", ____lambda_4)
    attempt("return Any", ____lambda_5)
    attempt("stack", function()
        local st = Stack.new()
        st:push("a")
        return #st:pop()
    end)
    attempt("if any", function()
        local x
        if true then
            local ____value_27 = unsafeCast(5)
            if ____value_27 ~= nil and type(____value_27) ~= "string" then
                __K2L_CastFail(____value_27, "java.lang.String", "kotlin.String")
            end
            x = ____value_27
        else
            x = "x"
        end
        return x
    end)
    attempt("if println", function()
        local ____temp
        if true then
            local ____value_28 = unsafeCast(5)
            if ____value_28 ~= nil and type(____value_28) ~= "string" then
                __K2L_CastFail(____value_28, "java.lang.String", "kotlin.String")
            end
            ____temp = ____value_28
        else
            ____temp = "x"
        end
        print(____temp)
        return "p"
    end)
    attempt("if stmt no else", function()
        if true then
            unsafeCast(5)
        end
        return "u"
    end)
    attempt("when stmt", function()
        if 1 == 1 then
            local ____value_29 = unsafeCast(5)
            if ____value_29 ~= nil and type(____value_29) ~= "string" then
                __K2L_CastFail(____value_29, "java.lang.String", "kotlin.String")
            end
        end
        return "u"
    end)
    attempt("elvis any", function()
        local ____value_30 = unsafeCast(5)
        if ____value_30 ~= nil and type(____value_30) ~= "string" then
            __K2L_CastFail(____value_30, "java.lang.String", "kotlin.String")
        end
        local x = ____value_30 or "n"
        return x
    end)
    attempt("elvis stmt", function()
        local ____value_31 = unsafeCast(5)
        if ____value_31 ~= nil and type(____value_31) ~= "string" then
            __K2L_CastFail(____value_31, "java.lang.String", "kotlin.String")
        end
        local _ = ____value_31 or "n"
        return "u"
    end)
    attempt("notnull stmt", function()
        __K2L_NotNull(unsafeCast(5))
        return "u"
    end)
    attempt("notnull any", function()
        local x = __K2L_NotNull(unsafeCast(5))
        return x
    end)
    attempt("let", function()
        local ____value_32 = unsafeCast(5)
        if ____value_32 ~= nil and type(____value_32) ~= "string" then
            __K2L_CastFail(____value_32, "java.lang.String", "kotlin.String")
        end
        return #____value_32
    end)
    attempt("let print", function()
        local ____value_33 = unsafeCast(5)
        if ____value_33 ~= nil and type(____value_33) ~= "string" then
            __K2L_CastFail(____value_33, "java.lang.String", "kotlin.String")
        end
        print(____value_33)
        return "u"
    end)
    attempt("also", function()
        local ____value_34 = unsafeCast(5)
        if ____value_34 ~= nil and type(____value_34) ~= "string" then
            __K2L_CastFail(____value_34, "java.lang.String", "kotlin.String")
        end
        print(____value_34)
        return "u"
    end)
    attempt("operator get", function()
        local ____value_35 = Slots.new(1, "b"):get(0)
        if ____value_35 ~= nil and type(____value_35) ~= "string" then
            __K2L_CastFail(____value_35, "java.lang.String", "kotlin.String")
        end
        return #____value_35
    end)
    attempt("operator get ok", function()
        local ____value_36 = Slots.new(1, "b"):get(1)
        if ____value_36 ~= nil and type(____value_36) ~= "string" then
            __K2L_CastFail(____value_36, "java.lang.String", "kotlin.String")
        end
        return #____value_36
    end)
    attempt("operator get Int", function()
        local ____value_37 = Slots.new("x"):get(0)
        if ____value_37 ~= nil and type(____value_37) ~= "number" then
            __K2L_CastFail(____value_37, "java.lang.Number", "kotlin.Number")
        end
        local n = ____value_37
        return n
    end)
    attempt("compare", ____lambda_6)
    attempt("is", function()
        local ____value_38 = unsafeCast(5)
        return type(____value_38) == "string"
    end)
    attempt("string plus", function()
        local ____value_39 = unsafeCast(5)
        if ____value_39 ~= nil and type(____value_39) ~= "string" then
            __K2L_CastFail(____value_39, "java.lang.String", "kotlin.String")
        end
        return ____value_39 .. "!"
    end)
end

__K2L_DeepMain(main)
return {unsafeCast = unsafeCast, firstOf = firstOf, Box = Box, Slots = Slots, Stack = Stack, returnsString = returnsString, returnsAny = returnsAny, takesString = takesString, takesAny = takesAny, generic = generic, attempt = attempt}
