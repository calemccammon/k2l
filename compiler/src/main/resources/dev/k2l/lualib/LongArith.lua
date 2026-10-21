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

-- the Long with the signed high and the unsigned low 32 bits given, and back (BitSet's words)
function __K2L_LongArith.fromHalves(hi, lo)
    return hi * 4294967296 + lo
end

function __K2L_LongArith.halves(x)
    local lo = x % 4294967296
    return math.floor((x - lo) / 4294967296), lo
end
