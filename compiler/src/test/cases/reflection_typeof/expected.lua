local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfArray = ____lualib.__K2L_KClassOfArray
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypeOf = ____lualib.__K2L_TypeOf

local Outer = __K2L_Class("Outer")
__K2L_ClassInfo(Outer, "Outer", "Outer", "class")
Outer.Nested = __K2L_Class("Outer$Nested")
__K2L_ClassInfo(Outer.Nested, "Outer.Nested", "Outer$Nested", "class")
local Box = __K2L_Class("Box")
__K2L_ClassInfo(Box, "Box", "Box", "class")

function Box:____init(v)
    self.v = v
end

function Box.new(v)
    return setmetatable({v = v}, Box)
end

function Box:toString()
    return "Box(v=" .. __K2L_Str(self.v) .. ")"
end

function Box:hashCode()
    return __K2L_Hash(self.v)
end

function Box:equals(other)
    return getmetatable(other) == Box and __K2L_Equals(self.v, other.v)
end

local function main()
    do
        local t = __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})
        local ____arg = __K2L_Str(t)
        local ____arg_1 = tostring(t.isMarkedNullable)
        local ____arg_2 = __K2L_Str(t.classifier)
        local ____arg_3 = __K2L_Str(t.arguments)
        local ____list = t.arguments
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = it.type
        end
        print(____arg .. " | " .. ____arg_1 .. " | " .. ____arg_2 .. " | " .. ____arg_3 .. " | " .. __K2L_Str(__K2L_ListWrap(____out, ____count)))
    end
    print(__K2L_Str(__K2L_TypeOf("java.lang.Integer?", true, __K2L_KClassNamed("kotlin.Int"), {})) .. " " .. tostring(__K2L_TypeOf("java.lang.Integer?", true, __K2L_KClassNamed("kotlin.Int"), {}).isMarkedNullable))
    do
        local t = __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})
        local ____arg_4 = __K2L_Str(t)
        local ____arg_5 = tostring(t.isMarkedNullable)
        local ____arg_6 = __K2L_Str(t.classifier)
        local ____arg_7 = __K2L_Str(t.arguments)
        local ____list_1 = t.arguments
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it.type
        end
        print(____arg_4 .. " | " .. ____arg_5 .. " | " .. ____arg_6 .. " | " .. ____arg_7 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    end
    do
        local t = __K2L_TypeOf("java.lang.Object", false, __K2L_KClassNamed("kotlin.Any"), {})
        local ____arg_8 = __K2L_Str(t)
        local ____arg_9 = tostring(t.isMarkedNullable)
        local ____arg_10 = __K2L_Str(t.classifier)
        local ____arg_11 = __K2L_Str(t.arguments)
        local ____list_2 = t.arguments
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_2, ____n_2 = ____list_2:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it.type
        end
        print(____arg_8 .. " | " .. ____arg_9 .. " | " .. ____arg_10 .. " | " .. ____arg_11 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    end
    do
        local t = __K2L_TypeOf("java.util.List<java.lang.Integer>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})
        local ____arg_12 = __K2L_Str(t)
        local ____arg_13 = tostring(t.isMarkedNullable)
        local ____arg_14 = __K2L_Str(t.classifier)
        local ____arg_15 = __K2L_Str(t.arguments)
        local ____list_3 = t.arguments
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_3, ____n_3 = ____list_3:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it.type
        end
        print(____arg_12 .. " | " .. ____arg_13 .. " | " .. ____arg_14 .. " | " .. ____arg_15 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
    end
    do
        local t = __K2L_TypeOf("java.util.List<java.lang.String?>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("java.lang.String?", true, __K2L_KClassNamed("kotlin.String"), {})}})
        local ____arg_16 = __K2L_Str(t)
        local ____arg_17 = tostring(t.isMarkedNullable)
        local ____arg_18 = __K2L_Str(t.classifier)
        local ____arg_19 = __K2L_Str(t.arguments)
        local ____list_4 = t.arguments
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_4, ____n_4 = ____list_4:____array()
        for ____i_4 = 1, ____n_4 do
            local it = ____items_4[____i_4]
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it.type
        end
        print(____arg_16 .. " | " .. ____arg_17 .. " | " .. ____arg_18 .. " | " .. ____arg_19 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    end
    do
        local t = __K2L_TypeOf("java.util.Map<java.lang.String, java.util.List<Box<java.lang.Integer>>>", false, __K2L_KClassNamed("kotlin.collections.Map"), {{"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}, {"", __K2L_TypeOf("java.util.List<Box<java.lang.Integer>>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("Box<java.lang.Integer>", false, __K2L_KClassOf(Box), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})}})}})
        local ____arg_20 = __K2L_Str(t)
        local ____arg_21 = tostring(t.isMarkedNullable)
        local ____arg_22 = __K2L_Str(t.classifier)
        local ____arg_23 = __K2L_Str(t.arguments)
        local ____list_5 = t.arguments
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_5, ____n_5 = ____list_5:____array()
        for ____i_5 = 1, ____n_5 do
            local it = ____items_5[____i_5]
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = it.type
        end
        print(____arg_20 .. " | " .. ____arg_21 .. " | " .. ____arg_22 .. " | " .. ____arg_23 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_5)))
    end
    do
        local t = __K2L_TypeOf("kotlin.Array<java.lang.String>", false, __K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array"), {{"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}})
        local ____arg_24 = __K2L_Str(t)
        local ____arg_25 = tostring(t.isMarkedNullable)
        local ____arg_26 = __K2L_Str(t.classifier)
        local ____arg_27 = __K2L_Str(t.arguments)
        local ____list_6 = t.arguments
        local ____out_6 = {}
        local ____count_6 = 0
        local ____items_6, ____n_6 = ____list_6:____array()
        for ____i_6 = 1, ____n_6 do
            local it = ____items_6[____i_6]
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = it.type
        end
        print(____arg_24 .. " | " .. ____arg_25 .. " | " .. ____arg_26 .. " | " .. ____arg_27 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_6, ____count_6)))
    end
    do
        local t = __K2L_TypeOf("kotlin.IntArray", false, __K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray"), {})
        local ____arg_28 = __K2L_Str(t)
        local ____arg_29 = tostring(t.isMarkedNullable)
        local ____arg_30 = __K2L_Str(t.classifier)
        local ____arg_31 = __K2L_Str(t.arguments)
        local ____list_7 = t.arguments
        local ____out_7 = {}
        local ____count_7 = 0
        local ____items_7, ____n_7 = ____list_7:____array()
        for ____i_7 = 1, ____n_7 do
            local it = ____items_7[____i_7]
            ____count_7 = ____count_7 + 1
            ____out_7[____count_7] = it.type
        end
        print(____arg_28 .. " | " .. ____arg_29 .. " | " .. ____arg_30 .. " | " .. ____arg_31 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_7, ____count_7)))
    end
    do
        local t = __K2L_TypeOf("Outer$Nested", false, __K2L_KClassOf(Outer.Nested), {})
        local ____arg_32 = __K2L_Str(t)
        local ____arg_33 = tostring(t.isMarkedNullable)
        local ____arg_34 = __K2L_Str(t.classifier)
        local ____arg_35 = __K2L_Str(t.arguments)
        local ____list_8 = t.arguments
        local ____out_8 = {}
        local ____count_8 = 0
        local ____items_8, ____n_8 = ____list_8:____array()
        for ____i_8 = 1, ____n_8 do
            local it = ____items_8[____i_8]
            ____count_8 = ____count_8 + 1
            ____out_8[____count_8] = it.type
        end
        print(____arg_32 .. " | " .. ____arg_33 .. " | " .. ____arg_34 .. " | " .. ____arg_35 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_8, ____count_8)))
    end
    do
        local t = __K2L_TypeOf("Box<*>", false, __K2L_KClassOf(Box), {false})
        local ____arg_36 = __K2L_Str(t)
        local ____arg_37 = tostring(t.isMarkedNullable)
        local ____arg_38 = __K2L_Str(t.classifier)
        local ____arg_39 = __K2L_Str(t.arguments)
        local ____list_9 = t.arguments
        local ____out_9 = {}
        local ____count_9 = 0
        local ____items_9, ____n_9 = ____list_9:____array()
        for ____i_9 = 1, ____n_9 do
            local it = ____items_9[____i_9]
            ____count_9 = ____count_9 + 1
            ____out_9[____count_9] = it.type
        end
        print(____arg_36 .. " | " .. ____arg_37 .. " | " .. ____arg_38 .. " | " .. ____arg_39 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_9, ____count_9)))
    end
    do
        local t = __K2L_TypeOf("Box<out java.lang.Number>", false, __K2L_KClassOf(Box), {{"out ", __K2L_TypeOf("java.lang.Number", false, __K2L_KClassNamed("kotlin.Number"), {})}})
        local ____arg_40 = __K2L_Str(t)
        local ____arg_41 = tostring(t.isMarkedNullable)
        local ____arg_42 = __K2L_Str(t.classifier)
        local ____arg_43 = __K2L_Str(t.arguments)
        local ____list_10 = t.arguments
        local ____out_10 = {}
        local ____count_10 = 0
        local ____items_10, ____n_10 = ____list_10:____array()
        for ____i_10 = 1, ____n_10 do
            local it = ____items_10[____i_10]
            ____count_10 = ____count_10 + 1
            ____out_10[____count_10] = it.type
        end
        print(____arg_40 .. " | " .. ____arg_41 .. " | " .. ____arg_42 .. " | " .. ____arg_43 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_10, ____count_10)))
    end
    do
        local t = __K2L_TypeOf("Box<in java.lang.Integer>", false, __K2L_KClassOf(Box), {{"in ", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})
        local ____arg_44 = __K2L_Str(t)
        local ____arg_45 = tostring(t.isMarkedNullable)
        local ____arg_46 = __K2L_Str(t.classifier)
        local ____arg_47 = __K2L_Str(t.arguments)
        local ____list_11 = t.arguments
        local ____out_11 = {}
        local ____count_11 = 0
        local ____items_11, ____n_11 = ____list_11:____array()
        for ____i_11 = 1, ____n_11 do
            local it = ____items_11[____i_11]
            ____count_11 = ____count_11 + 1
            ____out_11[____count_11] = it.type
        end
        print(____arg_44 .. " | " .. ____arg_45 .. " | " .. ____arg_46 .. " | " .. ____arg_47 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_11, ____count_11)))
    end
    do
        local t = __K2L_TypeOf("java.util.Map$Entry<java.lang.String, java.lang.Integer>", false, __K2L_KClassNamed("kotlin.collections.Map.Entry"), {{"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}, {"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})
        local ____arg_48 = __K2L_Str(t)
        local ____arg_49 = tostring(t.isMarkedNullable)
        local ____arg_50 = __K2L_Str(t.classifier)
        local ____arg_51 = __K2L_Str(t.arguments)
        local ____list_12 = t.arguments
        local ____out_12 = {}
        local ____count_12 = 0
        local ____items_12, ____n_12 = ____list_12:____array()
        for ____i_12 = 1, ____n_12 do
            local it = ____items_12[____i_12]
            ____count_12 = ____count_12 + 1
            ____out_12[____count_12] = it.type
        end
        print(____arg_48 .. " | " .. ____arg_49 .. " | " .. ____arg_50 .. " | " .. ____arg_51 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_12, ____count_12)))
    end
    do
        local t = __K2L_TypeOf("kotlin.jvm.functions.Function1<java.lang.Integer, java.lang.String>", false, __K2L_KClassNamed("kotlin.Function1"), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}, {"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}})
        local ____arg_52 = __K2L_Str(t)
        local ____arg_53 = tostring(t.isMarkedNullable)
        local ____arg_54 = __K2L_Str(t.classifier)
        local ____arg_55 = __K2L_Str(t.arguments)
        local ____list_13 = t.arguments
        local ____out_13 = {}
        local ____count_13 = 0
        local ____items_13, ____n_13 = ____list_13:____array()
        for ____i_13 = 1, ____n_13 do
            local it = ____items_13[____i_13]
            ____count_13 = ____count_13 + 1
            ____out_13[____count_13] = it.type
        end
        print(____arg_52 .. " | " .. ____arg_53 .. " | " .. ____arg_54 .. " | " .. ____arg_55 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_13, ____count_13)))
    end
    do
        local t = __K2L_TypeOf("kotlin.Unit", false, __K2L_KClassNamed("kotlin.Unit"), {})
        local ____arg_56 = __K2L_Str(t)
        local ____arg_57 = tostring(t.isMarkedNullable)
        local ____arg_58 = __K2L_Str(t.classifier)
        local ____arg_59 = __K2L_Str(t.arguments)
        local ____list_14 = t.arguments
        local ____out_14 = {}
        local ____count_14 = 0
        local ____items_14, ____n_14 = ____list_14:____array()
        for ____i_14 = 1, ____n_14 do
            local it = ____items_14[____i_14]
            ____count_14 = ____count_14 + 1
            ____out_14[____count_14] = it.type
        end
        print(____arg_56 .. " | " .. ____arg_57 .. " | " .. ____arg_58 .. " | " .. ____arg_59 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_14, ____count_14)))
    end
    do
        local t = __K2L_TypeOf("long", false, __K2L_KClassNamed("kotlin.Long"), {})
        local ____arg_60 = __K2L_Str(t)
        local ____arg_61 = tostring(t.isMarkedNullable)
        local ____arg_62 = __K2L_Str(t.classifier)
        local ____arg_63 = __K2L_Str(t.arguments)
        local ____list_15 = t.arguments
        local ____out_15 = {}
        local ____count_15 = 0
        local ____items_15, ____n_15 = ____list_15:____array()
        for ____i_15 = 1, ____n_15 do
            local it = ____items_15[____i_15]
            ____count_15 = ____count_15 + 1
            ____out_15[____count_15] = it.type
        end
        print(____arg_60 .. " | " .. ____arg_61 .. " | " .. ____arg_62 .. " | " .. ____arg_63 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_15, ____count_15)))
    end
    do
        local t = __K2L_TypeOf("double", false, __K2L_KClassNamed("kotlin.Double"), {})
        local ____arg_64 = __K2L_Str(t)
        local ____arg_65 = tostring(t.isMarkedNullable)
        local ____arg_66 = __K2L_Str(t.classifier)
        local ____arg_67 = __K2L_Str(t.arguments)
        local ____list_16 = t.arguments
        local ____out_16 = {}
        local ____count_16 = 0
        local ____items_16, ____n_16 = ____list_16:____array()
        for ____i_16 = 1, ____n_16 do
            local it = ____items_16[____i_16]
            ____count_16 = ____count_16 + 1
            ____out_16[____count_16] = it.type
        end
        print(____arg_64 .. " | " .. ____arg_65 .. " | " .. ____arg_66 .. " | " .. ____arg_67 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_16, ____count_16)))
    end
    do
        local t = __K2L_TypeOf("char", false, __K2L_KClassNamed("kotlin.Char"), {})
        local ____arg_68 = __K2L_Str(t)
        local ____arg_69 = tostring(t.isMarkedNullable)
        local ____arg_70 = __K2L_Str(t.classifier)
        local ____arg_71 = __K2L_Str(t.arguments)
        local ____list_17 = t.arguments
        local ____out_17 = {}
        local ____count_17 = 0
        local ____items_17, ____n_17 = ____list_17:____array()
        for ____i_17 = 1, ____n_17 do
            local it = ____items_17[____i_17]
            ____count_17 = ____count_17 + 1
            ____out_17[____count_17] = it.type
        end
        print(____arg_68 .. " | " .. ____arg_69 .. " | " .. ____arg_70 .. " | " .. ____arg_71 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_17, ____count_17)))
    end
    do
        local t = __K2L_TypeOf("boolean", false, __K2L_KClassNamed("kotlin.Boolean"), {})
        local ____arg_72 = __K2L_Str(t)
        local ____arg_73 = tostring(t.isMarkedNullable)
        local ____arg_74 = __K2L_Str(t.classifier)
        local ____arg_75 = __K2L_Str(t.arguments)
        local ____list_18 = t.arguments
        local ____out_18 = {}
        local ____count_18 = 0
        local ____items_18, ____n_18 = ____list_18:____array()
        for ____i_18 = 1, ____n_18 do
            local it = ____items_18[____i_18]
            ____count_18 = ____count_18 + 1
            ____out_18[____count_18] = it.type
        end
        print(____arg_72 .. " | " .. ____arg_73 .. " | " .. ____arg_74 .. " | " .. ____arg_75 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_18, ____count_18)))
    end
    do
        local t = __K2L_TypeOf("java.util.Set<Outer>", false, __K2L_KClassNamed("kotlin.collections.Set"), {{"", __K2L_TypeOf("Outer", false, __K2L_KClassOf(Outer), {})}})
        local ____arg_76 = __K2L_Str(t)
        local ____arg_77 = tostring(t.isMarkedNullable)
        local ____arg_78 = __K2L_Str(t.classifier)
        local ____arg_79 = __K2L_Str(t.arguments)
        local ____list_19 = t.arguments
        local ____out_19 = {}
        local ____count_19 = 0
        local ____items_19, ____n_19 = ____list_19:____array()
        for ____i_19 = 1, ____n_19 do
            local it = ____items_19[____i_19]
            ____count_19 = ____count_19 + 1
            ____out_19[____count_19] = it.type
        end
        print(____arg_76 .. " | " .. ____arg_77 .. " | " .. ____arg_78 .. " | " .. ____arg_79 .. " | " .. __K2L_Str(__K2L_ListWrap(____out_19, ____count_19)))
    end
    local ____result
    ____result = __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})
    local ____arg_80 = __K2L_Pair.new(____result, "int")
    local ____result_1
    ____result_1 = __K2L_TypeOf("java.util.List<java.lang.String>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}})
    local m = __K2L_ReadOnlyMapOf(____arg_80, __K2L_Pair.new(____result_1, "list of string"))
    print(__K2L_Str(m:get(__K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {}))))
    print(__K2L_Str(m:get(__K2L_TypeOf("java.util.List<java.lang.String>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("java.lang.String", false, __K2L_KClassNamed("kotlin.String"), {})}}))))
    print(__K2L_Str(m:get(__K2L_TypeOf("java.util.List<java.lang.Integer>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}}))))
    local ____result_2
    ____result_2 = __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})
    local ____arg_81 = ____result_2
    local ____result_3
    ____result_3 = __K2L_TypeOf("java.lang.Integer?", true, __K2L_KClassNamed("kotlin.Int"), {})
    print(__K2L_Equals(____arg_81, ____result_3))
    local ____result_4
    ____result_4 = __K2L_TypeOf("java.util.List<java.lang.Integer>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})
    print(__K2L_Hash(____result_4) == __K2L_Hash(__K2L_TypeOf("java.util.List<java.lang.Integer>", false, __K2L_KClassNamed("kotlin.collections.List"), {{"", __K2L_TypeOf("int", false, __K2L_KClassNamed("kotlin.Int"), {})}})))
end

__K2L_Main(main)
return {Outer = Outer, Box = Box}
