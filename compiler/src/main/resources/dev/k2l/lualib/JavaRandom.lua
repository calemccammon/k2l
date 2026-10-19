-- requires: Class, Exceptions, Bit, ToInt32
-- java.util.Random: the 48-bit linear congruential generator, so a seeded Random gives the numbers the JVM gives.
-- The state is kept as two 24-bit halves, which keeps every product below 2^53 (exact on Lua 5.1 and LuaJIT).
-- nextLong() needs 64-bit integers (Lua 5.3+) to be exact.
local __K2L_JavaRandom = __K2L_Class("java.util.Random")

do

local TWO24 = 16777216
local MULT_HI, MULT_LO = 0x5DE, 0xECE66D
local floor = math.floor

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

function __K2L_JavaRandom:setSeed(seed)
    local low48 = seed % 281474976710656
    self.lo = __K2L_BXor(low48 % TWO24, MULT_LO)
    self.hi = __K2L_BXor(floor(low48 / TWO24), MULT_HI)
    self.nextNextGaussian = nil
end

function __K2L_JavaRandom:____init(seed)
    if seed == nil then
        seed = os.time() * 1000003 + floor(os.clock() * 1000000)
    end
    self:setSeed(seed)
end

local function step(self)
    local lo, hi = self.lo, self.hi
    local newLo = lo * MULT_LO + 0xB
    local carry = floor(newLo / TWO24)
    newLo = newLo - carry * TWO24
    local newHi = (hi * MULT_LO + lo * MULT_HI + carry) % TWO24
    self.lo, self.hi = newLo, newHi
end

local function next(self, bits)
    step(self)
    local value = floor((self.hi * TWO24 + self.lo) / 2 ^ (48 - bits))
    if bits == 32 then
        return __K2L_ToInt32(value)
    end
    return value
end

-- k where n == 2^k, or nil
local function log2(n)
    local p, k = 1, 0
    while p < n do
        p, k = p * 2, k + 1
    end
    return p == n and k or nil
end

function __K2L_JavaRandom:nextInt(a, b)
    if a == nil then
        return next(self, 32)
    elseif b ~= nil then
        return self:nextIntRange(a, b)
    end
    local bound = a
    if bound <= 0 then
        illegalArgument("bound must be positive")
    end
    local r = next(self, 31)
    local k = log2(bound)
    if k ~= nil then
        return floor(r / 2 ^ (31 - k))
    end
    local m = bound - 1
    local u = r
    r = u % bound
    while u - r + m >= 2147483648 do
        u = next(self, 31)
        r = u % bound
    end
    return r
end

-- nextInt(origin, bound), as RandomSupport.boundedNextInt does it
function __K2L_JavaRandom:nextIntRange(origin, bound)
    if origin >= bound then
        illegalArgument("bound must be greater than origin")
    end
    local r = next(self, 32)
    local n = bound - origin
    local m = n - 1
    if n > 2147483648 then
        while r < origin or r >= bound do
            r = next(self, 32)
        end
    elseif n == 2147483648 or log2(n) ~= nil then
        r = r % n + origin
    else
        local u = floor((r % 4294967296) / 2)
        r = u % n
        while u + m - r >= 2147483648 do
            u = floor((next(self, 32) % 4294967296) / 2)
            r = u % n
        end
        r = r + origin
    end
    return r
end

function __K2L_JavaRandom:nextLong()
    local high = next(self, 32)
    local low = next(self, 32)
    return high * 4294967296 + low
end

function __K2L_JavaRandom:nextBoolean()
    return next(self, 1) ~= 0
end

function __K2L_JavaRandom:nextDouble(a, b)
    local r = (next(self, 26) * 134217728 + next(self, 27)) / 9007199254740992
    if a == nil then
        return r
    end
    local origin, bound = 0.0, a
    if b ~= nil then
        origin, bound = a, b
    end
    if not (origin < bound and bound - origin < math.huge) then
        illegalArgument("bound must be greater than origin")
    end
    r = r * (bound - origin) + origin
    if r >= bound then
        r = bound - bound * 2.220446049250313e-16
    end
    return r
end

function __K2L_JavaRandom:nextFloat()
    return next(self, 24) / 16777216
end

function __K2L_JavaRandom:nextGaussian()
    if self.nextNextGaussian ~= nil then
        local value = self.nextNextGaussian
        self.nextNextGaussian = nil
        return value
    end
    local v1, v2, s
    repeat
        v1 = 2 * self:nextDouble() - 1
        v2 = 2 * self:nextDouble() - 1
        s = v1 * v1 + v2 * v2
    until s < 1 and s ~= 0
    local multiplier = math.sqrt(-2 * math.log(s) / s)
    self.nextNextGaussian = v2 * multiplier
    return v1 * multiplier
end

end
