local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Unit = ____lualib.__K2L_Unit

local ____exports = {}
local convertedReferences
____exports.calls = 0

local function u()
    ____exports.calls = ____exports.calls + 1
end

local function id(x)
    return x
end

local function twice(f)
    return __K2L_ReadOnlyListOf(f(), f())
end

local function describe(x)
    if x == nil then
        return "null"
    elseif x == __K2L_Unit then
        return "the Unit object"
    elseif type(x) == "string" then
        return "a String"
    else
        return "something else"
    end
end

local function asAny()
    u()
    return __K2L_Unit
end

local function returnsUnitCall()
    return u()
end

local function returnsUnitObject()
    local ____subject = ____exports.calls
    if ____subject == 0 then
    else
        u()
    end
    return __K2L_Unit
end

local function expanded(limit)
    local ____list = __K2L_ReadOnlyListOf(1, 2)
    local ____result = __K2L_ListOf()
    for _, it in ipairs(____list) do
        if it > limit then
            return "stopped"
        end
        u()
        ____result:add(__K2L_Unit)
    end
    local units = ____result
    local ____result_1 = __K2L_Result.success(1)
    local ____result_2 = ____result_1
    if ____result_1.exception == nil then
        do
            local it = ____result_1.value
            if it > limit then
                return "stopped"
            end
            u()
        end
        ____result_2 = __K2L_Result.success(__K2L_Unit)
    end
    local result = ____result_2
    return __K2L_Str(units) .. " " .. __K2L_Str(result)
end

local function maybe(c)
    if c then
        u()
        return __K2L_Unit
    else
        return nil
    end
end

local Holder = __K2L_Class("Holder")
__K2L_ClassInfo(Holder, "Holder", "Holder", "class")

function Holder:getP()
    u()
end

local Box = __K2L_Class("Box")
__K2L_ClassInfo(Box, "Box", "Box", "class")

function Box:____init(value)
    self.value = value
end

function Box.new(value)
    return setmetatable({value = value}, Box)
end

function Box:toString()
    return "Box(" .. __K2L_Str(self.value) .. ")"
end

local ____lambda_1 = function() return #"text" end
local function main()
    u()
    print("kotlin.Unit")
    u()
    print("kotlin.Unit")
    u()
    print("value: " .. "kotlin.Unit")
    print("kotlin.Unit")
    print("kotlin.Unit")
    local a = __K2L_Unit
    print(__K2L_Str(a))
    u()
    local b = __K2L_Unit
    print("kotlin.Unit")
    local ____arg = __K2L_Unit
    u()
    print(__K2L_Str(__K2L_ReadOnlyListOf(____arg, __K2L_Unit, 1)))
    print(__K2L_Str(__K2L_RunCatching(function()
        u()
        return __K2L_Unit
    end)))
    print(__K2L_Str(__K2L_RunCatching(____lambda_1)))
    u()
    id(__K2L_Unit)
    print("kotlin.Unit")
    print(__K2L_Str(twice(function()
        u()
        return __K2L_Unit
    end)))
    u()
    print(describe(__K2L_Unit))
    print(describe(__K2L_Unit))
    print(describe(nil))
    print(__K2L_Str(asAny()))
    returnsUnitCall()
    returnsUnitObject()
    print("kotlin.Unit")
    u()
    print(__K2L_Unit == __K2L_Unit)
    print(__K2L_Equals(__K2L_Unit, a))
    print(__K2L_Hash(__K2L_Unit) == __K2L_Hash(a))
    u()
    print(__K2L_Str(Box.new(__K2L_Unit)))
    print(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new(1, __K2L_Unit))))
    local ____list_1 = __K2L_ReadOnlyListOf(1, 2)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        u()
        ____count = ____count + 1
        ____out[____count] = __K2L_Unit
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local x = "x"
    local y = nil
    local ____result_3
    if x ~= nil then
        u()
        ____result_3 = __K2L_Unit
    end
    print(__K2L_Str(____result_3))
    local ____result_4
    if y ~= nil then
        u()
        ____result_4 = __K2L_Unit
    end
    print(__K2L_Str(____result_4))
    if ____exports.calls > 0 then
        u()
    end
    print("kotlin.Unit")
    local f = function()
        u()
        return __K2L_Unit
    end
    print(__K2L_Str(f()))
    local r = __K2L_Result.success(__K2L_Unit)
    print(__K2L_Str(r))
    print(__K2L_Str(r:getOrNull()))
    print(__K2L_SingletonListOf(__K2L_Unit):contains(__K2L_Unit))
    print(__K2L_ReadOnlySetOf(__K2L_Unit, __K2L_Unit).size)
    local ____lazyUnit_delegate = __K2L_Lazy(function()
        u()
        return __K2L_Unit
    end)
    print(__K2L_Str(____lazyUnit_delegate:getValue()))
    u()
    print("kotlin.Unit" .. "!")
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Unit").simpleName))
    local block = function()
        u()
    end
    __K2L_StartCoroutine(function(...)
        block(...)
        return __K2L_Unit
    end, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(it)
        print("completed: " .. __K2L_Str(it))
    end))
    local v
    local ____subject_1 = ____exports.calls
    if ____subject_1 == 0 then
        v = "none"
    else
        u()
        v = __K2L_Unit
    end
    print(__K2L_Str(v))
    print(__K2L_Str(__K2L_RunCatching(function(...)
        u(...)
        return __K2L_Unit
    end)))
    local g = function(it)
        u()
    end
    print(__K2L_Str(__K2L_SingletonListOf(1):map(function(...)
        g(...)
        return __K2L_Unit
    end)))
    print(__K2L_Str(maybe(true)))
    print(__K2L_Str(maybe(false)))
    Holder.new():getP()
    print("kotlin.Unit")
    local m = __K2L_MapOf()
    m:set(1, __K2L_Unit)
    m:getOrPut(2, function()
        u()
        return __K2L_Unit
    end)
    print("kotlin.Unit")
    print(__K2L_Str(m))
    print(__K2L_Str(__K2L_SequenceOf(1):map(function(it)
        u()
        return __K2L_Unit
    end):toList()))
    local ____list_2 = __K2L_SingletonListOf(1)
    local ____result_5 = __K2L_Map.new()
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        u()
        local ____value = __K2L_Unit
        ____result_5:put(it, ____value)
    end
    print(__K2L_Str(____result_5))
    print(expanded(5))
    print(expanded(0))
    print("calls: " .. ____exports.calls)
    convertedReferences()
end

local Hooks = __K2L_Class("Hooks")
__K2L_ClassInfo(Hooks, "Hooks", "Hooks", "class")

function Hooks:____init(onStart)
    self.onStart = onStart
end

function Hooks.new(onStart)
    return setmetatable({onStart = onStart}, Hooks)
end

local function pick()
    return function(...)
        u(...)
        return __K2L_Unit
    end
end

local ____lambda_2 = function() return "lambda" end
local ____lambda_3 = function() return 1 end
function convertedReferences()
    local h = function(...)
        u(...)
        return __K2L_Unit
    end
    print(__K2L_Str(h()))
    print(__K2L_Str(pick()()))
    local plain = u
    local widened = function(...)
        plain(...)
        return __K2L_Unit
    end
    print(__K2L_Str(widened()))
    local ____list_3 = __K2L_ReadOnlyListOf(function(...)
        u(...)
        return __K2L_Unit
    end, ____lambda_2)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local hooks = Hooks.new(u)
    local ____fn = hooks.onStart
    local started = function(...)
        ____fn(...)
        return __K2L_Unit
    end
    print(__K2L_Str(started()))
    local late = ____lambda_3
    late = function(...)
        plain(...)
        return __K2L_Unit
    end
    late()
    print("kotlin.Unit")
end

____exports.u = u
____exports.id = id
____exports.twice = twice
____exports.describe = describe
____exports.asAny = asAny
____exports.returnsUnitCall = returnsUnitCall
____exports.returnsUnitObject = returnsUnitObject
____exports.expanded = expanded
____exports.maybe = maybe
____exports.Holder = Holder
____exports.Box = Box
____exports.Hooks = Hooks
____exports.pick = pick
____exports.convertedReferences = convertedReferences
__K2L_DeepMain(main)
return ____exports
