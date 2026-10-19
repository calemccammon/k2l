local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Entry = ____lualib.__K2L_Entry
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapBuilderOf = ____lualib.__K2L_MapBuilderOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SetBuilderOf = ____lualib.__K2L_SetBuilderOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local function t(name, f)
    local r
    local ____ok, ____result = pcall(function()
        r = f()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            r = __K2L_JavaClass(__K2L_KClassOfValue(e)).name .. ": " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    print(name .. " -> " .. __K2L_Str(r))
end

local function main()
    local ____builder = __K2L_ListBuilderOf()
    ____builder:add(1)
    ____builder:add(2)
    local l = ____builder:____build()
    t("list", function()
        return __K2L_Str(l) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(l)).name) .. " " .. l.size .. " " .. tostring(__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) .. " " .. tostring(__K2L_Equals(l, __K2L_ReadOnlyListOf(1, 2))) .. " " .. __K2L_Hash(l)
    end)
    t("add", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        return l:add(3)
    end)
    t("set", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        return l:set(0, 3)
    end)
    t("remove", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        return l:removeAt(0)
    end)
    t("clear", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        l:clear()
        return __K2L_Unit
    end)
    t("sort", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        l:sort()
        return __K2L_Unit
    end)
    t("empty", function()
        local ____builder_1 = __K2L_ListBuilderOf()
        local e = ____builder_1:____build()
        return __K2L_Str(e) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(e)).name)
    end)
    t("empty add", function()
        local ____builder_2 = __K2L_ListBuilderOf()
        local ____cast = ____builder_2:____build()
        if not (__K2L_InstanceOf(____cast, __K2L_List) and not ____cast.____readOnly) then
            __K2L_CastFail(____cast, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast:add(1)
    end)
    t("cap", function()
        local ____builder_3 = __K2L_ListBuilderOf()
        ____builder_3:add("x")
        return __K2L_JavaClass(__K2L_KClassOfValue(____builder_3:____build())).name
    end)
    t("sub", function()
        local s = l:subList(0, 1)
        return __K2L_Str(s) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(s)).name)
    end)
    t("iter", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(l))).name
    end)
    t("iter remove", function()
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        local it = __K2L_IteratorOf(l)
        it:next()
        it:remove()
        return __K2L_Unit
    end)
    t("listIterator", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(__K2L_JdkCollections.listIterator(l))).name
    end)
    t("map", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(l:map(function(it) return it * 2 end))).name
    end)
    t("toList", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(l:toList())).name
    end)
    t("toMutableList", function()
        local ____value = l:toMutableList()
        ____value:add(9)
        return ____value
    end)
    local ____builder_4 = __K2L_SetBuilderOf()
    ____builder_4:add(1)
    ____builder_4:add(2)
    ____builder_4:add(1)
    local s = ____builder_4:____build()
    t("set", function()
        return __K2L_Str(s) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(s)).name) .. " " .. s.size .. " " .. tostring(__K2L_Equals(s, __K2L_ReadOnlySetOf(1, 2))) .. " " .. __K2L_Hash(s)
    end)
    t("set add", function()
        if not (__K2L_InstanceOf(s, __K2L_Set) and not s.____readOnly) then
            __K2L_CastFail(s, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return s:add(3)
    end)
    t("set remove", function()
        if not (__K2L_InstanceOf(s, __K2L_Set) and not s.____readOnly) then
            __K2L_CastFail(s, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return s:remove(1)
    end)
    t("set iter", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(s))).name
    end)
    t("set empty", function()
        local ____builder_5 = __K2L_SetBuilderOf()
        local e = ____builder_5:____build()
        return __K2L_Str(e) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(e)).name)
    end)
    local ____builder_6 = __K2L_MapBuilderOf()
    ____builder_6:put(1, "a")
    ____builder_6:put(2, "b")
    local m = ____builder_6:____build()
    t("map", function()
        return __K2L_Str(m) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(m)).name) .. " " .. m.size .. " " .. tostring(__K2L_Equals(m, __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))) .. " " .. __K2L_Hash(m)
    end)
    t("map put", function()
        if not (__K2L_InstanceOf(m, __K2L_Map) and not m.____readOnly) then
            __K2L_CastFail(m, "java.util.Map", "kotlin.collections.MutableMap")
        end
        return m:put(3, "c")
    end)
    t("map remove", function()
        if not (__K2L_InstanceOf(m, __K2L_Map) and not m.____readOnly) then
            __K2L_CastFail(m, "java.util.Map", "kotlin.collections.MutableMap")
        end
        return m:remove(1)
    end)
    t("map keys", function()
        return __K2L_Str(m:getKeys()) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(m:getKeys())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(m:getValues())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(m:getEntries())).name)
    end)
    t("map keys remove", function()
        local ____cast_1 = m:getKeys()
        if not (__K2L_InstanceOf(____cast_1, __K2L_Set) and not ____cast_1.____readOnly) then
            __K2L_CastFail(____cast_1, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_1:remove(1)
    end)
    t("map entry set", function()
        local ____cast_2 = m:getEntries():first()
        if not __K2L_InstanceOf(____cast_2, __K2L_Entry) then
            __K2L_CastFail(____cast_2, "java.lang.collections.MutableMap.MutableEntry", "kotlin.collections.MutableMap.MutableEntry")
        end
        return ____cast_2:setValue("z")
    end)
    t("map entry class", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(m:getEntries():first())).name
    end)
    t("map empty", function()
        local ____builder_7 = __K2L_MapBuilderOf()
        local e = ____builder_7:____build()
        return __K2L_Str(e) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(e)).name)
    end)
    t("inside", function()
        local ____builder_8 = __K2L_ListBuilderOf()
        ____builder_8:add(1)
        print("in " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____builder_8)).name) .. " " .. __K2L_Str(____builder_8))
        ____builder_8:addAll(__K2L_ReadOnlyListOf(2, 3))
        ____builder_8:removeAt(0)
        ____builder_8:set(0, 5)
        return ____builder_8:____build()
    end)
    t("escape", function()
        local saved = nil
        local ____builder_9 = __K2L_ListBuilderOf()
        ____builder_9:add(1)
        saved = ____builder_9
        local r = ____builder_9:____build()
        return __K2L_NotNull(saved):add(2)
    end)
    t("is", function()
        return tostring(__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) .. " " .. tostring(__K2L_InstanceOf(s, __K2L_Set) and not s.____readOnly) .. " " .. tostring(__K2L_InstanceOf(m, __K2L_Map) and not m.____readOnly)
    end)
    local nm = nil
    local nl = nil
    local ns = nil
    local m2 = __K2L_SingletonMapOf(__K2L_Pair.new("a", 1))
    t("orEmpty", function()
        return __K2L_Str(nm or __K2L_ReadOnlyMapOf()) .. " " .. __K2L_Str(nl or __K2L_ReadOnlyListOf()) .. " " .. __K2L_Str(ns or __K2L_ReadOnlySetOf()) .. " " .. __K2L_Str(m2 or __K2L_ReadOnlyMapOf()) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(nm or __K2L_ReadOnlyMapOf())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(nl or __K2L_ReadOnlyListOf())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(ns or __K2L_ReadOnlySetOf())).name)
    end)
end

main()
return {t = t}
