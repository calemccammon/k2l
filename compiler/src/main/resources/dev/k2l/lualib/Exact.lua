-- requires: Exceptions
-- java.lang.Math.addExact and friends on Lua 5.3/5.4: Int results outside 32 bits and Long results outside 64 bits throw.
local __K2L_Exact = {}

do

local MIN_INT, MAX_INT = -2147483648, 2147483647
local MIN_LONG, MAX_LONG = math.mininteger, math.maxinteger

local function overflow(kind)
    error(__K2L_ArithmeticException.new(kind .. " overflow"))
end

local function checked(r)
    if r < MIN_INT or r > MAX_INT then
        overflow("integer")
    end
    return r
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

function __K2L_Exact.addLong(a, b)
    local r = a + b
    if ((a ~ r) & (b ~ r)) < 0 then
        overflow("long")
    end
    return r
end

function __K2L_Exact.subLong(a, b)
    local r = a - b
    if ((a ~ b) & (a ~ r)) < 0 then
        overflow("long")
    end
    return r
end

function __K2L_Exact.mulLong(a, b)
    if a == 0 or b == 0 then
        return 0
    end
    local r = a * b
    if (a == MIN_LONG and b == -1) or (b == MIN_LONG and a == -1) or r // b ~= a then
        overflow("long")
    end
    return r
end

function __K2L_Exact.negLong(a)
    if a == MIN_LONG then
        overflow("long")
    end
    return -a
end

function __K2L_Exact.incLong(a)
    if a == MAX_LONG then
        overflow("long")
    end
    return a + 1
end

function __K2L_Exact.decLong(a)
    if a == MIN_LONG then
        overflow("long")
    end
    return a - 1
end

function __K2L_Exact.absLong(a)
    if a == MIN_LONG then
        error(__K2L_ArithmeticException.new("Overflow to represent absolute value of Long.MIN_VALUE"))
    end
    return a < 0 and -a or a
end

end
