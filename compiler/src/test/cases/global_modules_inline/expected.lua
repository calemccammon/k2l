-- ==== main.lua ====
local ____lualib = {}

do
-- The hash code of an object that does not override hashCode(): a number per table, assigned on first use.
local __K2L_IdentityHash = (function()
    local ids = setmetatable({}, {__mode = "k"})
    local last = 0
    return function(value)
        local id = ids[value]
        if id == nil then
            last = last + 1
            id = last
            ids[value] = id
        end
        return id
    end
end)()
____lualib.__K2L_IdentityHash = __K2L_IdentityHash
end

do
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
-- toString() of any value: "null" for nil, an object's toString(), and Lua's tostring for numbers, booleans and the rest.
local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    if type(value) == "table" then
        if value.toString then
            return value:toString()
        end
        -- Any.toString() of an object of the program: its class name and hash code in hex, as in `app.Point@1b`
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        if type(cls) == "table" and rawget(cls, "____name") ~= nil then
            local hash = value.hashCode ~= nil and value:hashCode() or __K2L_IdentityHash(value)
            return cls.____name .. "@" .. string.format("%x", hash % 4294967296)
        end
    end
    return tostring(value)
end
____lualib.__K2L_Str = __K2L_Str
end

do
local __K2L_Str = ____lualib.__K2L_Str
-- Instances look keys up in their class (`cls.__index = cls`), except when the class (or a base) needs more:
-- * it overrides a library property such as Throwable.message with a custom getter: the field is not set on instances
--   (what the Throwable constructor stores goes to `____message`), so reading it reaches `__index`, which calls the getter;
-- * its elements are read and written by index through methods (`____at`/`____atPut`, see AbstractCollections): an
--   AbstractList's `list[i]` is get(i - 1), so generated loops and the lualib read it like any list.
-- Subclasses inherit this.
local function instanceIndex(cls)
    local accessors, at = cls.____accessors, cls.____at
    return function(self, key)
        if accessors ~= nil then
            local getter = accessors[key]
            if getter ~= nil then
                return cls[getter](self)
            end
        end
        if at ~= nil and type(key) == "number" then
            return at(self, key)
        end
        return cls[key]
    end
end

local function instanceNewIndex(self, key, value)
    local cls = getmetatable(self)
    local accessors = cls.____accessors
    if accessors ~= nil and accessors[key] ~= nil then
        rawset(self, "____" .. key, value)
    elseif type(key) == "number" and cls.____atPut ~= nil then
        cls.____atPut(self, key, value)
    else
        rawset(self, key, value)
    end
end

local function installIndex(cls)
    cls.__index = instanceIndex(cls)
    cls.__newindex = instanceNewIndex
end

-- Lua code calling tostring() or print() on an object of the program (a Lua host of Kotlin modules) sees its toString().
local function instanceToString(self)
    return __K2L_Str(self)
end

-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    cls.__tostring = instanceToString
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring") or instanceToString
        cls.__call = rawget(base, "__call")
    end
    local interfaces = {...}
    local indexed = base ~= nil and (base.____accessors ~= nil or base.____at ~= nil)
    for _, iface in ipairs(interfaces) do
        -- objects of a class implementing Comparator, Runnable or a function type are callable (see SamInterfaces)
        cls.__call = cls.__call or rawget(iface, "__call")
        -- a lualib collection base used as an interface (`class C : Base(), List<Int>`) brings its superclasses along
        local c = iface
        while c ~= nil do
            cls.____interfaces[c] = true
            for super in pairs(rawget(c, "____interfaces")) do
                cls.____interfaces[super] = true
            end
            c = rawget(c, "____super")
        end
        indexed = indexed or iface.____accessors ~= nil or iface.____at ~= nil
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    if indexed then
        installIndex(cls)
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end
____lualib.__K2L_Class = __K2L_Class
end

do
-- Wraps a Lua integer to Kotlin's 32-bit Int range, as Long.toInt() does.
local function __K2L_ToInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end
____lualib.__K2L_ToInt32 = __K2L_ToInt32
end

do
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
-- hashCode() of a value: a number by its value (an integral Double hashes like the Int it equals), a string by its bytes, a
-- boolean as 1231 or 1237, an object by its own hashCode() or else by identity. Hash codes are the same on every target.
local byte, floor = string.byte, math.floor

-- s[0] * 31^(n-1) + ... + s[n-1] of the bytes, four per step (h * 31^4 + ... stays below 2^53, so it is exact with doubles)
local function hashString(s)
    local h, i, n = 0, 1, #s
    while i + 3 <= n do
        local b1, b2, b3, b4 = byte(s, i, i + 3)
        h = (h * 923521 + b1 * 29791 + b2 * 961 + b3 * 31 + b4) % 4294967296
        i = i + 4
    end
    while i <= n do
        h = (31 * h + byte(s, i)) % 4294967296
        i = i + 1
    end
    return __K2L_ToInt32(h)
end

local function hashNumber(x)
    if x ~= x then
        return 0
    elseif x % 1 ~= 0 or x >= 9007199254740992 or x <= -9007199254740992 then
        -- a fraction, an infinity or a number beyond 2^53: by its text
        return hashString(string.format("%.17g", x))
    elseif x >= -2147483648 and x <= 2147483647 then
        return x == 0 and 0 or floor(x)
    end
    return __K2L_ToInt32(floor(x / 4294967296) * 31 + x % 4294967296)
end

local function __K2L_Hash(value)
    local t = type(value)
    if t == "number" then
        return hashNumber(value)
    elseif t == "string" then
        return hashString(value)
    elseif value == nil then
        return 0
    elseif t == "boolean" then
        return value and 1231 or 1237
    elseif t == "table" and value.hashCode ~= nil then
        return value:hashCode()
    end
    return __K2L_IdentityHash(value)
end
____lualib.__K2L_Hash = __K2L_Hash
end

do
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Hash = ____lualib.__K2L_Hash
-- Kotlin collections on Lua tables. Lists keep elements in the array part (1-based) with an explicit `size`, so null
-- elements are fine; maps and sets (HashMap and HashSet too) keep insertion order and honor equals()/hashCode() keys.
-- A collection changed while a loop or an iterator walks it is not detected: the loop sees whatever the change left.

------------------------------------------------------------------ Iterable
-- Shared operations; subclasses provide ____array(), returning a 1-based array and its length.
local __K2L_Iterable = __K2L_Class("kotlin.collections.Iterable")
-- tostring() shows Kotlin's toString(); subclasses inherit the metamethod from __K2L_Class.
function __K2L_Iterable:__tostring()
    return self:toString()
end

local __K2L_List

local function newList(arr, n)
    arr.size = n
    return setmetatable(arr, __K2L_List)
end

function __K2L_Iterable:joinToString(separator, prefix, postfix, limit, truncated, transform)
    separator = separator or ", "
    limit = limit or -1
    local arr, n = self:____array()
    local texts, k, cut = {}, 0, false
    for i = 1, n do
        if limit >= 0 and i > limit then
            cut = true
            break
        end
        local value = arr[i]
        if transform then
            value = transform(value)
        end
        k = k + 1
        texts[k] = type(value) == "string" and value or __K2L_Str(value)
    end
    local body = table.concat(texts, separator, 1, k)
    if cut then
        body = body .. separator .. (truncated or "...")
    end
    return (prefix or "") .. body .. (postfix or "")
end

function __K2L_Iterable:hashCode()
    local arr, n = self:____array()
    local h = 1
    for i = 1, n do
        h = __K2L_ToInt32(31 * h + __K2L_Hash(arr[i]))
    end
    return h
end

------------------------------------------------------------------ List
__K2L_List = __K2L_Class("java.util.ArrayList", __K2L_Iterable)

-- ArrayList(), ArrayList(capacity) and ArrayList(elements), as the constructor of a class extending ArrayList calls it
function __K2L_List:____init(elements)
    self.size = 0
    if type(elements) == "table" then
        __K2L_List.addAll(self, elements)
    end
end

function __K2L_List:____array()
    return self, self.size
end

function __K2L_List:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

function __K2L_List:add(value)
    local n = self.size + 1
    self.size = n
    self[n] = value
    return true
end

-- The bulk and convenience operations do not call add, addAt or removeAt, which a subclass may override.
function __K2L_List:addAll(elements)
    local arr, n = elements:____array()
    local size = self.size
    for i = 1, n do
        self[size + i] = arr[i]
    end
    self.size = size + n
    return n > 0
end

------------------------------------------------------------------ factories
-- listOf(...), mutableListOf(...) and emptyList(): a new list (read-only lists are mutable ones at run time).
local function __K2L_ListOf(...)
    return newList({...}, select("#", ...))
end
____lualib.__K2L_Iterable = __K2L_Iterable
____lualib.__K2L_List = __K2L_List
____lualib.__K2L_ListOf = __K2L_ListOf
end

do
local __K2L_List = ____lualib.__K2L_List
-- The ArrayList of the `n` elements of the 1-based table `arr`, which it takes over: `map { }`, `filter { }` and the like,
-- compiled to a loop, fill a plain table and make it a list at the end (as the lualib's own `map` does).
local function __K2L_ListWrap(arr, n)
    arr.size = n
    return setmetatable(arr, __K2L_List)
end
____lualib.__K2L_ListWrap = __K2L_ListWrap
end

do
-- Runs main. An uncaught error ends the program as the standalone interpreter ends it, the same on every target: its string
-- (tostring, so an exception's __tostring, its toString()) and the traceback of where it was raised on stderr, then exit
-- status 1. The interpreters themselves print an exception differently ("(error object is not a string)" on Lua 5.1, no
-- traceback on 5.2 to 5.4), and their tracebacks do not go through debug.traceback, which --source-map rewrites to Kotlin
-- positions.
local function __K2L_RunMain(main, ...)
    local args, n = {...}, select("#", ...)
    local unpack = table.unpack or unpack
    local ok, report = xpcall(function()
        return main(unpack(args, 1, n))
    end, function(e)
        return debug.traceback(tostring(e), 2)
    end)
    if not ok then
        io.stderr:write(tostring(report), "\n")
        os.exit(1)
    end
end
____lualib.__K2L_RunMain = __K2L_RunMain
end
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    print(shout("hey"))
    words:add("gamma")
    print(joined())
    print(#joined())
    print(calls)
    local ____object = Settings
    ____object.verbose = true
    print(Settings.verbose)
    local ____list = words
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = #it
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
end

__K2L_RunMain(main)
-- ==== util/text.lua ====
local ____lualib = {}

do
-- The hash code of an object that does not override hashCode(): a number per table, assigned on first use.
local __K2L_IdentityHash = (function()
    local ids = setmetatable({}, {__mode = "k"})
    local last = 0
    return function(value)
        local id = ids[value]
        if id == nil then
            last = last + 1
            id = last
            ids[value] = id
        end
        return id
    end
end)()
____lualib.__K2L_IdentityHash = __K2L_IdentityHash
end

do
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
-- toString() of any value: "null" for nil, an object's toString(), and Lua's tostring for numbers, booleans and the rest.
local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    if type(value) == "table" then
        if value.toString then
            return value:toString()
        end
        -- Any.toString() of an object of the program: its class name and hash code in hex, as in `app.Point@1b`
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        if type(cls) == "table" and rawget(cls, "____name") ~= nil then
            local hash = value.hashCode ~= nil and value:hashCode() or __K2L_IdentityHash(value)
            return cls.____name .. "@" .. string.format("%x", hash % 4294967296)
        end
    end
    return tostring(value)
end
____lualib.__K2L_Str = __K2L_Str
end

do
local __K2L_Str = ____lualib.__K2L_Str
-- Instances look keys up in their class (`cls.__index = cls`), except when the class (or a base) needs more:
-- * it overrides a library property such as Throwable.message with a custom getter: the field is not set on instances
--   (what the Throwable constructor stores goes to `____message`), so reading it reaches `__index`, which calls the getter;
-- * its elements are read and written by index through methods (`____at`/`____atPut`, see AbstractCollections): an
--   AbstractList's `list[i]` is get(i - 1), so generated loops and the lualib read it like any list.
-- Subclasses inherit this.
local function instanceIndex(cls)
    local accessors, at = cls.____accessors, cls.____at
    return function(self, key)
        if accessors ~= nil then
            local getter = accessors[key]
            if getter ~= nil then
                return cls[getter](self)
            end
        end
        if at ~= nil and type(key) == "number" then
            return at(self, key)
        end
        return cls[key]
    end
end

local function instanceNewIndex(self, key, value)
    local cls = getmetatable(self)
    local accessors = cls.____accessors
    if accessors ~= nil and accessors[key] ~= nil then
        rawset(self, "____" .. key, value)
    elseif type(key) == "number" and cls.____atPut ~= nil then
        cls.____atPut(self, key, value)
    else
        rawset(self, key, value)
    end
end

local function installIndex(cls)
    cls.__index = instanceIndex(cls)
    cls.__newindex = instanceNewIndex
end

-- Lua code calling tostring() or print() on an object of the program (a Lua host of Kotlin modules) sees its toString().
local function instanceToString(self)
    return __K2L_Str(self)
end

-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    cls.__tostring = instanceToString
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring") or instanceToString
        cls.__call = rawget(base, "__call")
    end
    local interfaces = {...}
    local indexed = base ~= nil and (base.____accessors ~= nil or base.____at ~= nil)
    for _, iface in ipairs(interfaces) do
        -- objects of a class implementing Comparator, Runnable or a function type are callable (see SamInterfaces)
        cls.__call = cls.__call or rawget(iface, "__call")
        -- a lualib collection base used as an interface (`class C : Base(), List<Int>`) brings its superclasses along
        local c = iface
        while c ~= nil do
            cls.____interfaces[c] = true
            for super in pairs(rawget(c, "____interfaces")) do
                cls.____interfaces[super] = true
            end
            c = rawget(c, "____super")
        end
        indexed = indexed or iface.____accessors ~= nil or iface.____at ~= nil
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    if indexed then
        installIndex(cls)
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end
____lualib.__K2L_Class = __K2L_Class
end

do
-- Wraps a Lua integer to Kotlin's 32-bit Int range, as Long.toInt() does.
local function __K2L_ToInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end
____lualib.__K2L_ToInt32 = __K2L_ToInt32
end

do
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
-- hashCode() of a value: a number by its value (an integral Double hashes like the Int it equals), a string by its bytes, a
-- boolean as 1231 or 1237, an object by its own hashCode() or else by identity. Hash codes are the same on every target.
local byte, floor = string.byte, math.floor

-- s[0] * 31^(n-1) + ... + s[n-1] of the bytes, four per step (h * 31^4 + ... stays below 2^53, so it is exact with doubles)
local function hashString(s)
    local h, i, n = 0, 1, #s
    while i + 3 <= n do
        local b1, b2, b3, b4 = byte(s, i, i + 3)
        h = (h * 923521 + b1 * 29791 + b2 * 961 + b3 * 31 + b4) % 4294967296
        i = i + 4
    end
    while i <= n do
        h = (31 * h + byte(s, i)) % 4294967296
        i = i + 1
    end
    return __K2L_ToInt32(h)
end

local function hashNumber(x)
    if x ~= x then
        return 0
    elseif x % 1 ~= 0 or x >= 9007199254740992 or x <= -9007199254740992 then
        -- a fraction, an infinity or a number beyond 2^53: by its text
        return hashString(string.format("%.17g", x))
    elseif x >= -2147483648 and x <= 2147483647 then
        return x == 0 and 0 or floor(x)
    end
    return __K2L_ToInt32(floor(x / 4294967296) * 31 + x % 4294967296)
end

local function __K2L_Hash(value)
    local t = type(value)
    if t == "number" then
        return hashNumber(value)
    elseif t == "string" then
        return hashString(value)
    elseif value == nil then
        return 0
    elseif t == "boolean" then
        return value and 1231 or 1237
    elseif t == "table" and value.hashCode ~= nil then
        return value:hashCode()
    end
    return __K2L_IdentityHash(value)
end
____lualib.__K2L_Hash = __K2L_Hash
end

do
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Hash = ____lualib.__K2L_Hash
-- Kotlin collections on Lua tables. Lists keep elements in the array part (1-based) with an explicit `size`, so null
-- elements are fine; maps and sets (HashMap and HashSet too) keep insertion order and honor equals()/hashCode() keys.
-- A collection changed while a loop or an iterator walks it is not detected: the loop sees whatever the change left.

------------------------------------------------------------------ Iterable
-- Shared operations; subclasses provide ____array(), returning a 1-based array and its length.
local __K2L_Iterable = __K2L_Class("kotlin.collections.Iterable")
-- tostring() shows Kotlin's toString(); subclasses inherit the metamethod from __K2L_Class.
function __K2L_Iterable:__tostring()
    return self:toString()
end

local __K2L_List

local function newList(arr, n)
    arr.size = n
    return setmetatable(arr, __K2L_List)
end

function __K2L_Iterable:joinToString(separator, prefix, postfix, limit, truncated, transform)
    separator = separator or ", "
    limit = limit or -1
    local arr, n = self:____array()
    local texts, k, cut = {}, 0, false
    for i = 1, n do
        if limit >= 0 and i > limit then
            cut = true
            break
        end
        local value = arr[i]
        if transform then
            value = transform(value)
        end
        k = k + 1
        texts[k] = type(value) == "string" and value or __K2L_Str(value)
    end
    local body = table.concat(texts, separator, 1, k)
    if cut then
        body = body .. separator .. (truncated or "...")
    end
    return (prefix or "") .. body .. (postfix or "")
end

function __K2L_Iterable:hashCode()
    local arr, n = self:____array()
    local h = 1
    for i = 1, n do
        h = __K2L_ToInt32(31 * h + __K2L_Hash(arr[i]))
    end
    return h
end

------------------------------------------------------------------ List
__K2L_List = __K2L_Class("java.util.ArrayList", __K2L_Iterable)

-- ArrayList(), ArrayList(capacity) and ArrayList(elements), as the constructor of a class extending ArrayList calls it
function __K2L_List:____init(elements)
    self.size = 0
    if type(elements) == "table" then
        __K2L_List.addAll(self, elements)
    end
end

function __K2L_List:____array()
    return self, self.size
end

function __K2L_List:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

function __K2L_List:add(value)
    local n = self.size + 1
    self.size = n
    self[n] = value
    return true
end

-- The bulk and convenience operations do not call add, addAt or removeAt, which a subclass may override.
function __K2L_List:addAll(elements)
    local arr, n = elements:____array()
    local size = self.size
    for i = 1, n do
        self[size + i] = arr[i]
    end
    self.size = size + n
    return n > 0
end

------------------------------------------------------------------ factories
-- listOf(...), mutableListOf(...) and emptyList(): a new list (read-only lists are mutable ones at run time).
local function __K2L_ListOf(...)
    return newList({...}, select("#", ...))
end
____lualib.__K2L_Iterable = __K2L_Iterable
____lualib.__K2L_List = __K2L_List
____lualib.__K2L_ListOf = __K2L_ListOf
end
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf

function shout(s)
    return s:upper() .. "!"
end

words = __K2L_ListOf("alpha", "beta")
calls = 0

function joined()
    calls = calls + 1
    return words:joinToString(", ")
end

Settings = __K2L_Class("util.Settings")

function Settings:____init()
    self.verbose = false
end

Settings:____init()
