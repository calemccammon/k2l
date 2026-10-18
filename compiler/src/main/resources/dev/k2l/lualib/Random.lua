-- requires: Class, Bit, ToInt32, Exceptions
-- kotlin.random.Random: Kotlin's XorWow generator, so a seeded Random gives the numbers the JVM gives.
-- Int arithmetic is 32 bits; Long results are exact only where Lua has 64-bit integers (5.3+).
local __K2L_Random = __K2L_Class("kotlin.random.XorWowRandom")

do

local function checkRange(from, upTo)
    if not (upTo > from) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. from .. ", " .. upTo .. ")."))
    end
end

function __K2L_Random:____init(seed1, seed2)
    self.x, self.y, self.z, self.w = seed1, seed2, 0, 0
    self.v = __K2L_BNot(seed1)
    self.addend = __K2L_BXor(__K2L_Shl(seed1, 10), __K2L_Ushr(seed2, 4))
    for _ = 1, 64 do
        self:nextRaw()
    end
end

-- Random(seed: Int)
function __K2L_Random.seeded(seed)
    return __K2L_Random.new(seed, seed < 0 and -1 or 0)
end

-- Random(seed: Long)
function __K2L_Random.seededLong(seed)
    local low = seed % 4294967296
    return __K2L_Random.new(__K2L_ToInt32(low), __K2L_ToInt32((seed - low) / 4294967296))
end

local defaultRandom

-- Random.Default
function __K2L_Random.default()
    if defaultRandom == nil then
        local seed = os.time() * 1000 + math.floor(os.clock() * 1000000)
        defaultRandom = __K2L_Random.seededLong(seed % 2147483647 + 1)
    end
    return defaultRandom
end

function __K2L_Random:nextRaw()
    local t = self.x
    t = __K2L_BXor(t, __K2L_Ushr(t, 2))
    self.x, self.y, self.z = self.y, self.z, self.w
    local v0 = self.v
    self.w = v0
    t = __K2L_BXor(__K2L_BXor(__K2L_BXor(t, __K2L_Shl(t, 1)), v0), __K2L_Shl(v0, 4))
    self.v = t
    self.addend = __K2L_ToInt32(self.addend + 362437)
    return __K2L_ToInt32(t + self.addend)
end

local function nextBits(self, bitCount)
    if bitCount == 0 then
        return 0
    end
    return __K2L_Ushr(self:nextRaw(), 32 - bitCount)
end

local function fastLog2(n)
    local log = 0
    while n > 1 do
        n = (n - n % 2) / 2
        log = log + 1
    end
    return log
end

local function isPowerOfTwo(n)
    return 2 ^ fastLog2(n) == n
end

-- nextInt(), nextInt(until) and nextInt(from, until)
function __K2L_Random:nextInt(from, upTo)
    if from == nil then
        return self:nextRaw()
    elseif upTo == nil then
        from, upTo = 0, from
    end
    checkRange(from, upTo)
    local n = upTo - from
    if n > 0 and n <= 2147483647 then
        local rnd
        if isPowerOfTwo(n) then
            rnd = nextBits(self, fastLog2(n))
        else
            local v, bits
            repeat
                bits = __K2L_Ushr(self:nextRaw(), 1)
                v = bits % n
            until bits - v + (n - 1) <= 2147483647
            rnd = v
        end
        return from + rnd
    end
    while true do
        local rnd = self:nextRaw()
        if rnd >= from and rnd < upTo then
            return rnd
        end
    end
end

function __K2L_Random:nextIntRange(range)
    return self:nextInt(range.first, range.last + 1)
end

function __K2L_Random:nextLong()
    local high = self:nextRaw()
    local low = self:nextRaw()
    return high * 4294967296 + low
end

function __K2L_Random:nextBoolean()
    return nextBits(self, 1) ~= 0
end

local function nextUnit(self)
    local high = nextBits(self, 26)
    local low = nextBits(self, 27)
    return (high * 134217728 + low) / 9007199254740992
end

-- nextDouble(), nextDouble(until) and nextDouble(from, until)
function __K2L_Random:nextDouble(from, upTo)
    if from == nil then
        return nextUnit(self)
    elseif upTo == nil then
        from, upTo = 0.0, from
    end
    checkRange(from, upTo)
    local r = from + nextUnit(self) * (upTo - from)
    if r >= upTo then
        return upTo - upTo * 2.220446049250313e-16
    end
    return r
end

function __K2L_Random:nextFloat()
    return nextBits(self, 24) / 16777216
end

end
