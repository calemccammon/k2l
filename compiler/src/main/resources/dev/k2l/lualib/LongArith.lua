-- Long arithmetic for the lualib's own Long code (LongStream, the Long collectors and statistics): Lua numbers, so exact
-- 64-bit integers wrapping like the JVM's on 5.3/5.4 and doubles (exact up to 2^53) elsewhere; with --long64 emulate the
-- LongArith.l64 variant uses the emulated operations.
local __K2L_LongArith = {}

function __K2L_LongArith.add(a, b)
    return a + b
end

function __K2L_LongArith.lt(a, b)
    return a < b
end

function __K2L_LongArith.toDouble(a)
    return a + 0.0
end

-- Long.MAX_VALUE and Long.MIN_VALUE (doubles without integers: 2^63, rounded)
__K2L_LongArith.MAX = math.maxinteger or 2 ^ 63
__K2L_LongArith.MIN = math.mininteger or -2 ^ 63
