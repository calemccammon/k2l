local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClosedRange = ____lualib.__K2L_ClosedRange
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple

local Version = __K2L_Class("Version")

function Version:____init(major, minor, patch, pre)
    if minor == nil then
        minor = 0
    end
    if patch == nil then
        patch = 0
    end
    if pre == nil then
        pre = nil
    end
    self.major = major
    self.minor = minor
    self.patch = patch
    self.pre = pre
end

function Version:compareTo(other)
    local ____value = __K2L_CompareBy(function(it) return it.major end, function(it) return it.minor end, function(it) return it.patch end)(self, other)
    local ____value_1 = ____value ~= 0 and ____value or nil
    if ____value_1 == nil then
        local ____temp
        if self.pre == other.pre then
            ____temp = 0
        elseif self.pre == nil then
            ____temp = 1
        elseif other.pre == nil then
            ____temp = -1
        else
            ____temp = __K2L_Text.compare(self.pre, other.pre)
        end
        ____value_1 = ____temp
    end
    return ____value_1
end

function Version:bump(part)
    if part == Version.Part.MAJOR then
        return Version.new(self.major + 1)
    elseif part == Version.Part.MINOR then
        return Version.new(self.major, self.minor + 1)
    elseif part == Version.Part.PATCH then
        return Version.new(self.major, self.minor, self.patch + 1, nil)
    end
end

function Version:toString()
    local ____arg = self.major .. "." .. self.minor .. "." .. self.patch
    local ____receiver = self.pre
    return ____arg .. (____receiver and "-" .. ____receiver or "")
end

Version.Part = __K2L_Class("Version$Part")

function Version.Part:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Version.Part:toString()
    return self.name
end

function Version.Part:compareTo(other)
    return self.ordinal - other.ordinal
end

Version.Part.MAJOR = Version.Part.new("MAJOR", 0)
Version.Part.MINOR = Version.Part.new("MINOR", 1)
Version.Part.PATCH = Version.Part.new("PATCH", 2)
Version.Part.____values = {Version.Part.MAJOR, Version.Part.MINOR, Version.Part.PATCH}

function Version:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.major) + __K2L_Hash(self.minor)) + __K2L_Hash(self.patch)) + __K2L_Hash(self.pre))
end

function Version:equals(other)
    return getmetatable(other) == Version and self.major == other.major and self.minor == other.minor and self.patch == other.patch and self.pre == other.pre
end

function Version:parse(s)
    local ____value_2 = self.PATTERN:matchEntire(__K2L_StringTrim(s))
    if ____value_2 == nil then
        error(__K2L_IllegalArgumentException.new("invalid version '" .. s .. "'"))
    end
    local m = ____value_2
    local ____destructured = m.destructured
    local a, b, c, pre = ____destructured[1], ____destructured[2], ____destructured[3], ____destructured[4]
    return Version.new(__K2L_StringToInt(a), __K2L_StringToIntOrNull(b) or 0, __K2L_StringToIntOrNull(c) or 0, __K2L_Text.ifEmpty(pre, function() return nil end))
end

function Version:____initCompanion()
    self.PATTERN = __K2L_Regex.new("(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?(?:-([\\w.]+))?")
end

__K2L_LazyObject(Version, "____initCompanion")

local function toVersion(self)
    return Version:parse(self)
end

local Constraint = __K2L_Class("Constraint")
Constraint.Exact = __K2L_Class("Constraint$Exact", nil, Constraint)

function Constraint.Exact:____init(v)
    self.v = v
end

function Constraint.Exact:allows(v)
    return v:equals(self.v)
end

function Constraint.Exact:toString()
    return "=" .. __K2L_Str(self.v)
end

function Constraint.Exact:hashCode()
    return __K2L_Hash(self.v)
end

function Constraint.Exact:equals(other)
    return getmetatable(other) == Constraint.Exact and self.v:equals(other.v)
end

Constraint.Range = __K2L_Class("Constraint$Range", nil, Constraint)

function Constraint.Range:____init(range, upperExclusive)
    self.range = range
    self.upperExclusive = upperExclusive
end

function Constraint.Range:allows(v)
    return self.range:contains(v) and not (self.upperExclusive and v:equals(self.range.last)) and v.pre == nil
end

function Constraint.Range:toString()
    return "[" .. __K2L_Str(self.range.first) .. ", " .. __K2L_Str(self.range.last) .. (self.upperExclusive and ")" or "]")
end

function Constraint.Range:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.range) + __K2L_Hash(self.upperExclusive))
end

function Constraint.Range:equals(other)
    return getmetatable(other) == Constraint.Range and __K2L_Equals(self.range, other.range) and self.upperExclusive == other.upperExclusive
end

Constraint.AnyOf = __K2L_Class("Constraint$AnyOf", nil, Constraint)

function Constraint.AnyOf:____init(options)
    self.options = options
end

function Constraint.AnyOf:allows(v)
    return self.options:any(function(it) return it:allows(v) end)
end

function Constraint.AnyOf:toString()
    return self.options:joinToString(" || ")
end

function Constraint.AnyOf:hashCode()
    return __K2L_Hash(self.options)
end

function Constraint.AnyOf:equals(other)
    return getmetatable(other) == Constraint.AnyOf and __K2L_Equals(self.options, other.options)
end

Constraint.Any = __K2L_Class("Constraint$Any", nil, Constraint)

function Constraint.Any:allows(v)
    return v.pre == nil
end

function Constraint.Any:toString()
    return "*"
end

function Constraint:parse(text)
    local alternatives = __K2L_StringSplit(text, "||"):map(function(it) return __K2L_StringTrim(it) end)
    if alternatives.size > 1 then
        return Constraint.AnyOf.new(alternatives:map(function(...) return self:parse(...) end))
    end
    local s = alternatives:single()
    if s == "*" then
        return Constraint.Any
    elseif __K2L_StringStartsWith(s, "^") then
        local ____value_5 = toVersion(__K2L_Text.drop(s, 1))
        return Constraint.Range.new(__K2L_ClosedRange.new(____value_5, ____value_5:bump(Version.Part.MAJOR)), true)
    elseif __K2L_StringStartsWith(s, "~") then
        local ____value_4 = toVersion(__K2L_Text.drop(s, 1))
        return Constraint.Range.new(__K2L_ClosedRange.new(____value_4, ____value_4:bump(Version.Part.MINOR)), true)
    elseif __K2L_StringStartsWith(s, ">=") then
        return Constraint.Range.new(__K2L_ClosedRange.new(toVersion(__K2L_Text.removePrefix(s, ">=")), Version.new(2147483647)), false)
    elseif __K2L_StringContains(s, " - ") then
        local ____value_3 = __K2L_StringSplit(s, " - ")
        local ____result
        do
            local lo, hi = ____value_3[1], ____value_3[2]
            ____result = Constraint.Range.new(__K2L_ClosedRange.new(toVersion(lo), toVersion(hi)), false)
        end
        return ____result
    else
        return Constraint.Exact.new(toVersion(__K2L_Text.removePrefix(s, "=")))
    end
end

local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.packages = __K2L_HashMap.new()
end

function Registry:publish(name, version, ...)
    local deps = __K2L_ArrayOf(...)
    local versions = self.packages:getOrPut(name, function() return __K2L_SortedMap.new() end)
    local v = toVersion(version)
    if versions:containsKey(v) then
        error(__K2L_IllegalStateException.new(name .. "@" .. __K2L_Str(v) .. " already published"))
    end
    versions:set(v, deps:associate(function(____destructured_1)
        local n, c = ____destructured_1.first, ____destructured_1.second
        return __K2L_Pair.new(n, Constraint:parse(c))
    end))
end

function Registry:candidates(name, c)
    local ____receiver_1 = self.packages:get(name)
    local ____receiver_2 = ____receiver_1 and ____receiver_1:descendingKeySet()
    local ____value_6 = ____receiver_2 and ____receiver_2:filter(function(...) return c:allows(...) end)
    if ____value_6 == nil then
        error(__K2L_NoSuchElementException.new("unknown package '" .. name .. "'"))
    end
    return ____value_6
end

function Registry:deps(name, v)
    return self.packages:getValue(name):getValue(v)
end

function Registry:latest(name)
    local ____receiver_3 = self.packages:get(name)
    return ____receiver_3 and ____receiver_3:lastKey()
end

function Registry:before(name, v)
    local ____receiver_4 = self.packages:get(name)
    return ____receiver_4 and ____receiver_4:lowerKey(v)
end

local ResolutionException = __K2L_Class("ResolutionException", __K2L_RuntimeException)

function ResolutionException:____init(msg)
    __K2L_RuntimeException.____init(self, msg)
end

local Resolver = __K2L_Class("Resolver")

function Resolver:____init(registry)
    self.registry = registry
    self.attempts = 0
end

function Resolver:resolve(root)
    local pending = root:map(function(____destructured_2)
        local n, c = ____destructured_2.key, ____destructured_2.value
        return __K2L_Triple.new("<root>", n, Constraint:parse(c))
    end)
    local ____value_7 = self:solve(__K2L_SortedMapOf(), pending)
    if ____value_7 == nil then
        error(ResolutionException.new("no solution for " .. __K2L_Str(root) .. " after " .. self.attempts .. " attempts"))
    end
    return ____value_7
end

function Resolver:solve(chosen, pending)
    self.attempts = self.attempts + 1
    local ____value_8 = pending:firstOrNull()
    if ____value_8 == nil then
        return chosen
    end
    local from, name, constraint = ____value_8.first, ____value_8.second, ____value_8.third
    local rest = pending:drop(1)
    local ____receiver_5 = chosen:get(name)
    if ____receiver_5 ~= nil then
        local ____result_1
        if constraint:allows(____receiver_5) then
            return self:solve(chosen, rest)
        else
            return nil
        end
    end
    for _, v in ipairs(self.registry:candidates(name, constraint)) do
        local newDeps = self.registry:deps(name, v):map(function(____destructured_3)
            local n, c = ____destructured_3.key, ____destructured_3.value
            return __K2L_Triple.new(name .. "@" .. __K2L_Str(v), n, c)
        end)
        local result = self:solve(chosen:plus(__K2L_Pair.new(name, v)), rest:plusAll(newDeps))
        if result ~= nil then
            return result
        end
    end
    if from == "<root>" then
        return nil
    end
    return nil
end

local function lockFile(solution, registry)
    local ____builder = __K2L_StringBuilder.new()
    ____builder:appendLine("# generated lock file")
    for name, v in solution:iter() do
        ____builder:appendLine(name .. " = \"" .. __K2L_Str(v) .. "\"")
        for _, ____entry in ipairs(registry:deps(name, v):toSortedMap():getEntries()) do
            do
                local dep, c = ____entry.key, ____entry.value
                ____builder:appendLine("  " .. __K2L_Str(dep) .. " " .. __K2L_Str(c) .. " -> " .. __K2L_Str(solution:get(dep)))
            end
        end
    end
    return __K2L_StringTrimEnd(____builder:toString())
end

local function main()
    local versions = __K2L_ReadOnlyListOf("1.0.0", "1.0.0-alpha", "1.0.0-beta", "0.9", "1.2", "1.10.0", "1.2.3", "2"):map(toVersion)
    print("sorted: " .. __K2L_Str(versions:sorted()))
    print("max=" .. __K2L_Str(versions:max()) .. " min=" .. __K2L_Str(versions:min()) .. " distinct majors=" .. __K2L_Str(versions:map(function(it) return it.major end):toSortedSet()))
    local ____bound = toVersion("1.0")
    local ____bound_1 = toVersion("2.0")
    local ____value_9 = toVersion("1.2.3")
    print("1.2.3 in 1.0..2.0: " .. tostring(__K2L_Compare(____value_9, ____bound) >= 0 and __K2L_Compare(____value_9, ____bound_1) <= 0))
    print("bumps: " .. __K2L_Str(__K2L_EnumValues(Version.Part):map(function(it) return toVersion("1.4.7"):bump(it) end)))
    print(__K2L_Str(__K2L_RunCatching(function() return toVersion("1.x") end):exceptionOrNull()))
    for _, c in ipairs(__K2L_ReadOnlyListOf("^1.2.0", "~1.2.0", ">=1.10", "1.0 - 1.2", "=2.0.0", "*", "^0.9 || ^2.0")) do
        local parsed = Constraint:parse(c)
        print(__K2L_StringPadEnd(c, 12) .. " " .. __K2L_Str(parsed) .. " allows " .. __K2L_Str(versions:filter(function(...) return parsed:allows(...) end):sorted()))
    end
    local reg = Registry.new()
    reg:publish("app-core", "1.0.0", __K2L_Pair.new("log", "^1.0"), __K2L_Pair.new("json", "^2.1"))
    reg:publish("app-core", "1.1.0", __K2L_Pair.new("log", "^1.2"), __K2L_Pair.new("json", "^2.3"), __K2L_Pair.new("http", "~0.4"))
    reg:publish("log", "1.0.0")
    reg:publish("log", "1.2.0")
    reg:publish("log", "1.3.0", __K2L_Pair.new("fmt", "^3.0"))
    reg:publish("log", "2.0.0", __K2L_Pair.new("fmt", "^4.0"))
    reg:publish("fmt", "3.1.0")
    reg:publish("fmt", "4.0.0")
    reg:publish("json", "2.1.0")
    reg:publish("json", "2.3.1", __K2L_Pair.new("fmt", "^3.0"))
    reg:publish("json", "2.4.0-rc.1")
    reg:publish("http", "0.4.2", __K2L_Pair.new("log", ">=1.3"), __K2L_Pair.new("json", "2.1.0 - 2.9.9"))
    reg:publish("http", "0.5.0", __K2L_Pair.new("log", "^2.0"))
    local ____ok, ____result_2 = pcall(function()
        reg:publish("log", "1.2")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("publish failed: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("latest log=" .. __K2L_Str(reg:latest("log")) .. " before 1.3.0=" .. __K2L_Str(reg:before("log", toVersion("1.3.0"))) .. " latest nope=" .. __K2L_Str(reg:latest("nope")))
    print("json candidates for ^2.0: " .. __K2L_Str(reg:candidates("json", Constraint:parse("^2.0"))))
    local resolver = Resolver.new(reg)
    local solution = resolver:resolve(__K2L_ReadOnlyMapOf(__K2L_Pair.new("app-core", "^1.0"), __K2L_Pair.new("log", __K2L_Text.substringAfter("<1.3 || ^1.0", "|| "))))
    print("solution after " .. resolver.attempts .. " attempts: " .. __K2L_Str(solution))
    print(lockFile(solution, reg))
    local strict = Resolver.new(reg)
    local failure = __K2L_RunCatching(function()
        return strict:resolve(__K2L_ReadOnlyMapOf(__K2L_Pair.new("app-core", "=1.1.0"), __K2L_Pair.new("fmt", "^4.0")))
    end)
    local ____receiver_6 = failure:exceptionOrNull()
    print("strict: " .. __K2L_Str(____receiver_6 and ____receiver_6.message))
    print(__K2L_Str(__K2L_RunCatching(function()
        return Resolver.new(reg):resolve(__K2L_SingletonMapOf(__K2L_Pair.new("left-pad", "*")))
    end):exceptionOrNull()))
    local usage = reg:candidates("log", Constraint.Any):associateWith(function(v)
        return reg:deps("log", v):getKeys():ifEmpty(function() return __K2L_ReadOnlySetOf("-") end)
    end)
    print("log deps by version: " .. __K2L_Str(usage))
    local grouped = versions:groupBy(function(it)
        if it.pre ~= nil then
            return "pre"
        else
            return it.major == 0 and "unstable" or "stable"
        end
    end)
    print("grouped: " .. __K2L_Str(grouped:toSortedMap()))
end

main()
return {Version = Version, toVersion = toVersion, Constraint = Constraint, Registry = Registry, ResolutionException = ResolutionException, Resolver = Resolver, lockFile = lockFile}
