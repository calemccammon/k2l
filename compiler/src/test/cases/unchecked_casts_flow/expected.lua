local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local Holder = __K2L_Class("Holder")

function Holder:____init(s)
    self.s = s
end

function Holder.new(s)
    return setmetatable({s = s}, Holder)
end

local GHolder = __K2L_Class("GHolder")

function GHolder:____init(v)
    self.v = v
end

function GHolder.new(v)
    return setmetatable({v = v}, GHolder)
end

local Box = __K2L_Class("Box")

function Box:____init(items)
    self.items = items
end

function Box.new(items)
    return setmetatable({items = items}, Box)
end

local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.names = __K2L_ReadOnlyListOf()
    local ____cast = __K2L_SingletonMapOf(__K2L_Pair.new("a", "x"))
    if not __K2L_InstanceOf(____cast, __K2L_Map) then
        __K2L_CastFail(____cast, "java.util.Map", "kotlin.collections.Map")
    end
    self.sorted = ____cast
end

function Registry:load(raw)
    if not __K2L_InstanceOf(raw, __K2L_List) then
        __K2L_CastFail(raw, "java.util.List", "kotlin.collections.List")
    end
    local l = raw
    self.names = l
end

function Registry:total()
    local ____list = self.names
    local ____sum = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it ~= nil and type(it) ~= "string" then
            __K2L_CastFail(it, "java.lang.String", "kotlin.String")
        end
        ____sum = ____sum + #it
    end
    return ____sum
end

function Registry:first()
    local ____value = self.names:first()
    if ____value ~= nil and type(____value) ~= "string" then
        __K2L_CastFail(____value, "java.lang.String", "kotlin.String")
    end
    return ____value
end

function Registry:count()
    local ____list_1 = self.sorted:getValues()
    local ____result = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it ~= nil and type(it) ~= "number" then
            __K2L_CastFail(it, "java.lang.Number", "kotlin.Number")
        end
        if it > 0 then
            ____result = ____result + 1
        end
    end
    return ____result
end

local function each(self, f)
    local ____mod = self.____modCount
    for ____i_2 = 1, self.size do
        local x = self[____i_2]
        f(x)
        if self.____modCount ~= ____mod and self:____comodified(____i_2) then
            break
        end
    end
end

local function attempt(label, block)
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_ClassCastException) then
            local e = ____error
            print(label .. ": CCE " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    local raw = __K2L_ReadOnlyListOf(1, "b")
    if not __K2L_InstanceOf(raw, __K2L_List) then
        __K2L_CastFail(raw, "java.util.List", "kotlin.collections.List")
    end
    local l = raw
    attempt("map it", function()
        local ____out = {}
        local ____count = 0
        local ____items_2, ____n_2 = l:____array()
        for ____i_3 = 1, ____n_2 do
            local it = ____items_2[____i_3]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count = ____count + 1
            ____out[____count] = it
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    attempt("map length", function()
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_3, ____n_3 = l:____array()
        for ____i_4 = 1, ____n_3 do
            local it = ____items_3[____i_4]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = #it
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)
    attempt("map toString", function()
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_4, ____n_4 = l:____array()
        for ____i_5 = 1, ____n_4 do
            local it = ____items_4[____i_5]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
        return __K2L_ListWrap(____out_2, ____count_2)
    end)
    attempt("forEach println", function()
        for ____i_6 = 1, l.size do
            local it = l[____i_6]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            print(it)
        end
        return __K2L_Unit
    end)
    attempt("forEach typed", function()
        for ____i_7 = 1, l.size do
            local x = l[____i_7]
            if x ~= nil and type(x) ~= "string" then
                __K2L_CastFail(x, "java.lang.String", "kotlin.String")
            end
            print(x)
        end
        return __K2L_Unit
    end)
    attempt("filter true", function()
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_5, ____n_5 = l:____array()
        for ____i_8 = 1, ____n_5 do
            local it = ____items_5[____i_8]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            if true then
                ____count_3 = ____count_3 + 1
                ____out_3[____count_3] = it
            end
        end
        return __K2L_ListWrap(____out_3, ____count_3)
    end)
    attempt("filter ==", function()
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_6, ____n_6 = l:____array()
        for ____i_9 = 1, ____n_6 do
            local it = ____items_6[____i_9]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            if it == "b" then
                ____count_4 = ____count_4 + 1
                ____out_4[____count_4] = it
            end
        end
        return __K2L_ListWrap(____out_4, ____count_4)
    end)
    attempt("joinToString", function() return l:joinToString() end)
    attempt("sortedBy", function()
        local ____cast_1 = __K2L_ReadOnlyListOf("a", 2)
        if not __K2L_InstanceOf(____cast_1, __K2L_List) then
            __K2L_CastFail(____cast_1, "java.util.List", "kotlin.collections.List")
        end
        return ____cast_1:sortedBy(function(it)
            local ____value_1 = it
            if ____value_1 ~= nil and type(____value_1) ~= "string" then
                __K2L_CastFail(____value_1, "java.lang.String", "kotlin.String")
            end
            return it
        end, true)
    end)
    attempt("any", function()
        local ____result_2 = false
        local ____items_7, ____n_7 = l:____array()
        for ____i_10 = 1, ____n_7 do
            local it = ____items_7[____i_10]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            if #it == 0 then
                ____result_2 = true
                break
            end
        end
        return ____result_2
    end)
    attempt("associateWith", function()
        local ____result_3 = __K2L_Map.new()
        local ____items_8, ____n_8 = l:____array()
        for ____i_11 = 1, ____n_8 do
            local it = ____items_8[____i_11]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____result_3:put(it, 1)
        end
        return ____result_3
    end)
    attempt("mapIndexed", function()
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_9, ____n_9 = l:____array()
        for ____i_12 = 1, ____n_9 do
            local _ = ____items_9[____i_12]
            local i = ____i_12 - 1
            if i ~= nil and type(i) ~= "number" then
                __K2L_CastFail(i, "java.lang.Number", "kotlin.Number")
            end
            if _ ~= nil and type(_) ~= "string" then
                __K2L_CastFail(_, "java.lang.String", "kotlin.String")
            end
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = i
        end
        return __K2L_ListWrap(____out_5, ____count_5)
    end)
    attempt("fold", function()
        return l:fold(0, function(acc, _)
            local ____value_2 = acc
            if ____value_2 ~= nil and type(____value_2) ~= "number" then
                __K2L_CastFail(____value_2, "java.lang.Number", "kotlin.Number")
            end
            local ____value_3 = _
            if ____value_3 ~= nil and type(____value_3) ~= "string" then
                __K2L_CastFail(____value_3, "java.lang.String", "kotlin.String")
            end
            return acc + 1
        end)
    end)
    attempt("fold length", function()
        return l:fold(0, function(acc, s)
            local ____value_4 = acc
            if ____value_4 ~= nil and type(____value_4) ~= "number" then
                __K2L_CastFail(____value_4, "java.lang.Number", "kotlin.Number")
            end
            local ____value_5 = s
            if ____value_5 ~= nil and type(____value_5) ~= "string" then
                __K2L_CastFail(____value_5, "java.lang.String", "kotlin.String")
            end
            return acc + #s
        end)
    end)
    attempt("sequence map", function()
        return __K2L_AsSequence(l):map(function(it)
            local ____value_6 = it
            if ____value_6 ~= nil and type(____value_6) ~= "string" then
                __K2L_CastFail(____value_6, "java.lang.String", "kotlin.String")
            end
            return it
        end):toList()
    end)
    attempt("sequence map length", function()
        return __K2L_AsSequence(l):map(function(it)
            local ____value_7 = it
            if ____value_7 ~= nil and type(____value_7) ~= "string" then
                __K2L_CastFail(____value_7, "java.lang.String", "kotlin.String")
            end
            return #it
        end):toList()
    end)
    attempt("program function", function()
        each(l, function(it)
            local ____value_8 = it
            if ____value_8 ~= nil and type(____value_8) ~= "string" then
                __K2L_CastFail(____value_8, "java.lang.String", "kotlin.String")
            end
            print(it)
        end)
        return __K2L_Unit
    end)
    attempt("chain", function()
        local ____out_6 = {}
        local ____count_6 = 0
        local ____items_10, ____n_10 = l:____array()
        for ____i_13 = 1, ____n_10 do
            local it = ____items_10[____i_13]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            if it ~= nil then
                ____count_6 = ____count_6 + 1
                ____out_6[____count_6] = it
            end
        end
        local ____list_2 = __K2L_ListWrap(____out_6, ____count_6)
        local ____out_7 = {}
        local ____count_7 = 0
        local ____items_11, ____n_11 = ____list_2:____array()
        for ____i_14 = 1, ____n_11 do
            local it = ____items_11[____i_14]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count_7 = ____count_7 + 1
            ____out_7[____count_7] = 0
        end
        return __K2L_ListWrap(____out_7, ____count_7)
    end)
    attempt("with", function()
        local ____mod_1 = l.____modCount
        for ____i_15 = 1, l.size do
            local it = l[____i_15]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            print(it)
            if l.____modCount ~= ____mod_1 and l:____comodified(____i_15) then
                break
            end
        end
        return __K2L_Unit
    end)
    attempt("nullable", function()
        local ____cast_2 = __K2L_ReadOnlyListOf(nil, 1)
        if not __K2L_InstanceOf(____cast_2, __K2L_List) then
            __K2L_CastFail(____cast_2, "java.util.List", "kotlin.collections.List")
        end
        local ____out_8 = {}
        local ____count_8 = 0
        local ____items_12, ____n_12 = ____cast_2:____array()
        for ____i_16 = 1, ____n_12 do
            local it = ____items_12[____i_16]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count_8 = ____count_8 + 1
            ____out_8[____count_8] = it
        end
        return __K2L_ListWrap(____out_8, ____count_8)
    end)
    attempt("ok after filter", function()
        local ____cast_3 = __K2L_ReadOnlyListOf("x", "yy")
        if not __K2L_InstanceOf(____cast_3, __K2L_List) then
            __K2L_CastFail(____cast_3, "java.util.List", "kotlin.collections.List")
        end
        local ____out_9 = {}
        local ____count_9 = 0
        local ____items_13, ____n_13 = ____cast_3:____array()
        for ____i_17 = 1, ____n_13 do
            local it = ____items_13[____i_17]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            if #it > 1 then
                ____count_9 = ____count_9 + 1
                ____out_9[____count_9] = it
            end
        end
        return __K2L_ListWrap(____out_9, ____count_9)
    end)
    attempt("cast index", function()
        local ____value_9 = raw:get(0)
        if ____value_9 ~= nil and type(____value_9) ~= "string" then
            __K2L_CastFail(____value_9, "java.lang.String", "kotlin.String")
        end
        return #____value_9
    end)
    attempt("cast for", function()
        for ____i_18 = 1, raw.size do
            local s = raw[____i_18]
            local ____value_10 = s
            if ____value_10 ~= nil and type(____value_10) ~= "string" then
                __K2L_CastFail(____value_10, "java.lang.String", "kotlin.String")
            end
            print(#s)
        end
        return __K2L_Unit
    end)
    attempt("cast first Any", function() return raw:first() end)
    attempt("field", function()
        local ____value_11 = raw:get(0)
        if ____value_11 ~= nil and type(____value_11) ~= "string" then
            __K2L_CastFail(____value_11, "java.lang.String", "kotlin.String")
        end
        return Holder.new(____value_11)
    end)
    attempt("generic field", function() return GHolder.new(l:get(0)).v end)
    attempt("box", function() return "size " .. Box.new(l).items.size end)
    attempt("box index", function()
        local ____value_12 = Box.new(l).items:get(0)
        if ____value_12 ~= nil and type(____value_12) ~= "string" then
            __K2L_CastFail(____value_12, "java.lang.String", "kotlin.String")
        end
        return #____value_12
    end)
    attempt("box index Any", function()
        local x = Box.new(l).items:get(0)
        return x
    end)
    attempt("box first", function() return Box.new(l).items:first() end)
    attempt("box first length", function()
        local ____value_13 = Box.new(l).items:first()
        if ____value_13 ~= nil and type(____value_13) ~= "string" then
            __K2L_CastFail(____value_13, "java.lang.String", "kotlin.String")
        end
        return #____value_13
    end)
    attempt("box for", function()
        local ____list_3 = Box.new(l).items
        for ____i_19 = 1, ____list_3.size do
            local s = ____list_3[____i_19]
            local ____value_14 = s
            if ____value_14 ~= nil and type(____value_14) ~= "string" then
                __K2L_CastFail(____value_14, "java.lang.String", "kotlin.String")
            end
            print(#s)
        end
        return __K2L_Unit
    end)
    attempt("box map", function()
        local ____list_4 = Box.new(l).items
        local ____out_10 = {}
        local ____count_10 = 0
        local ____items_14, ____n_14 = ____list_4:____array()
        for ____i_20 = 1, ____n_14 do
            local it = ____items_14[____i_20]
            if it ~= nil and type(it) ~= "string" then
                __K2L_CastFail(it, "java.lang.String", "kotlin.String")
            end
            ____count_10 = ____count_10 + 1
            ____out_10[____count_10] = it
        end
        return __K2L_ListWrap(____out_10, ____count_10)
    end)
    attempt("generic holder", function()
        local ____cast_4 = GHolder.new(1)
        if getmetatable(____cast_4) ~= GHolder then
            __K2L_CastFail(____cast_4, "GHolder", "GHolder")
        end
        local ____value_15 = ____cast_4.v
        if ____value_15 ~= nil and type(____value_15) ~= "string" then
            __K2L_CastFail(____value_15, "java.lang.String", "kotlin.String")
        end
        return #____value_15
    end)
    attempt("generic holder println", function()
        local ____cast_5 = GHolder.new(1)
        if getmetatable(____cast_5) ~= GHolder then
            __K2L_CastFail(____cast_5, "GHolder", "GHolder")
        end
        print(____cast_5.v)
        return __K2L_Unit
    end)
    local registry = Registry.new()
    registry:load(raw)
    attempt("assigned field", function() return registry:total() end)
    attempt("assigned field first", function() return registry:first() end)
    attempt("cast field", function() return registry:count() end)
end

__K2L_DeepMain(main)
return {Holder = Holder, GHolder = GHolder, Box = Box, Registry = Registry, each = each, attempt = attempt}
