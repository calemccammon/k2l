-- requires: Exceptions
-- java.lang.Math.addExact and friends without 64-bit integers: Int results outside 32 bits throw, and Long is a
-- double, so a Long result outside +-2^63 throws (the sum of two Longs above 2^53 is only approximately checked).
local __K2L_Exact = {}

do

local MIN_INT, MAX_INT = -2147483648, 2147483647
local TWO_63 = 9223372036854775808

local function overflow(kind)
    error(__K2L_ArithmeticException.new(kind .. " overflow"))
end

local function checked(r)
    if r < MIN_INT or r > MAX_INT then
        overflow("integer")
    end
    return r + 0 -- + 0: negateExact(0) and multiplyExact(0, -1) are -0.0 in doubles
end

local function checkedLong(r)
    if r >= TWO_63 or r < -TWO_63 then
        overflow("long")
    end
    return r + 0
end

function __K2L_Exact.add(a, b) return checked(a + b) end
function __K2L_Exact.sub(a, b) return checked(a - b) end
function __K2L_Exact.mul(a, b) return checked(a * b) end
function __K2L_Exact.neg(a) return checked(-a) end
function __K2L_Exact.inc(a) return checked(a + 1) end
function __K2L_Exact.dec(a) return checked(a - 1) end
function __K2L_Exact.toInt(a) return checked(a) end

function __K2L_Exact.abs(a)
    if a == MIN_INT then
        error(__K2L_ArithmeticException.new("Overflow to represent absolute value of Integer.MIN_VALUE"))
    end
    return a < 0 and -a or a
end

function __K2L_Exact.addLong(a, b) return checkedLong(a + b) end
function __K2L_Exact.subLong(a, b) return checkedLong(a - b) end
function __K2L_Exact.mulLong(a, b) return checkedLong(a * b) end
function __K2L_Exact.negLong(a) return checkedLong(-a) end
function __K2L_Exact.incLong(a) return checkedLong(a + 1) end
function __K2L_Exact.decLong(a) return checkedLong(a - 1) end

function __K2L_Exact.absLong(a)
    if a == -TWO_63 then
        error(__K2L_ArithmeticException.new("Overflow to represent absolute value of Long.MIN_VALUE"))
    end
    return a < 0 and -a or a
end

end
