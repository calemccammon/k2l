-- requires: Class, Str, Equals, Hash, ToInt32
local __K2L_Pair = __K2L_Class("kotlin.Pair")

function __K2L_Pair:____init(first, second)
    self.first = first
    self.second = second
end

function __K2L_Pair:toString()
    return "(" .. __K2L_Str(self.first) .. ", " .. __K2L_Str(self.second) .. ")"
end

function __K2L_Pair:equals(other)
    return getmetatable(other) == __K2L_Pair and __K2L_Equals(self.first, other.first) and __K2L_Equals(self.second, other.second)
end

function __K2L_Pair:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.first) + __K2L_Hash(self.second))
end

local __K2L_Triple = __K2L_Class("kotlin.Triple")

function __K2L_Triple:____init(first, second, third)
    self.first = first
    self.second = second
    self.third = third
end

function __K2L_Triple:toString()
    return "(" .. __K2L_Str(self.first) .. ", " .. __K2L_Str(self.second) .. ", " .. __K2L_Str(self.third) .. ")"
end

function __K2L_Triple:equals(other)
    return getmetatable(other) == __K2L_Triple and __K2L_Equals(self.first, other.first) and
        __K2L_Equals(self.second, other.second) and __K2L_Equals(self.third, other.third)
end
