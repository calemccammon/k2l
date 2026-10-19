local ____lualib = require("lualib_bundle")
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IsCharSequence = ____lualib.__K2L_IsCharSequence
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_NumberTo = ____lualib.__K2L_NumberTo
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_Text = ____lualib.__K2L_Text

local Name = __K2L_Class("Name")

function Name:____init(s)
    self.s = s
end

function Name:getLength()
    return #self.s
end

function Name:get(index)
    return __K2L_StringCharAt(self.s, index)
end

function Name:subSequence(startIndex, endIndex)
    return __K2L_Text.substring(self.s, startIndex, endIndex)
end

function Name:toString()
    return self.s
end

__K2L_PropertyOverride(Name, "length", "getLength")
local Score = __K2L_Class("Score")

function Score:____init(n)
    self.n = n
end

function Score:compareTo(other)
    return self.n - other.n
end

function Score:toString()
    return "Score(n=" .. self.n .. ")"
end

function Score:hashCode()
    return __K2L_Hash(self.n)
end

function Score:equals(other)
    return getmetatable(other) == Score and self.n == other.n
end

local Dir = __K2L_Class("Dir")

function Dir:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Dir:toString()
    return self.name
end

function Dir:compareTo(other)
    return self.ordinal - other.ordinal
end

Dir.N = Dir.new("N", 0)
Dir.S = Dir.new("S", 1)
Dir.____values = {Dir.N, Dir.S}

local function kind(x)
    if x == nil then
        return "null"
    elseif __K2L_IsNumber(x) then
        return "number"
    elseif __K2L_IsCharSequence(x) then
        return "text(" .. #__K2L_CharSequenceText(x) .. ")"
    elseif __K2L_IsComparable(x) then
        return "comparable"
    else
        return "other"
    end
end

local function main()
    local values = __K2L_ReadOnlyListOf(1, 2.5, 3, "abc", __K2L_StringBuilder.new("xy"), __K2L_CharSequenceText(Name.new("name")), Score.new(1), Dir.S, true, __K2L_SingletonListOf(1), __K2L_Pair.new(1, 2), nil, __K2L_BigInteger.TEN)
    print(__K2L_Str(values:map(kind)))
    print(values:filter(function(x) return __K2L_IsComparable(x) end).size)
    print(values:filter(function(x) return __K2L_IsCharSequence(x) end):joinToString("|"))
    print(__K2L_Str(values:filter(function(x) return __K2L_IsNumber(x) end):sumOf(function(it) return __K2L_NumberTo(it, "toDouble") end, 0.0)))
    local any = "text"
    if not __K2L_IsCharSequence(any) then
        __K2L_CastFail(any, "java.lang.CharSequence", "kotlin.CharSequence")
    end
    local cs = any
    print(#__K2L_CharSequenceText(cs))
    local ____cast = Score.new(2)
    print((__K2L_IsComparable(____cast) and ____cast or nil) ~= nil)
    local ____cast_1 = __K2L_SingletonListOf(1)
    print((__K2L_IsComparable(____cast_1) and ____cast_1 or nil) == nil)
    local numbers = __K2L_ReadOnlyListOf(2.7, -3, 10, __K2L_BigInteger.valueOf(300), -3.3000000005E9)
    print(__K2L_Str(numbers:map(function(it)
        return __K2L_NumberTo(it, "toInt") .. " " .. __K2L_NumberTo(it, "toLong") .. " " .. __K2L_NumberTo(it, "toShort") .. " " .. __K2L_NumberTo(it, "toByte") .. " " .. __K2L_Str(__K2L_NumberTo(it, "toDouble"))
    end)))
end

main()
return {Name = Name, Score = Score, Dir = Dir, kind = kind}
