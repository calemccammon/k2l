-- requires: Class, Bit, ToInt32, Exceptions, Bits, DoubleToString
-- kotlin.random.Random: Kotlin's XorWow generator, so a seeded Random gives the numbers the JVM gives.
-- Int arithmetic is 32 bits; Long results are exact only where Lua has 64-bit integers (5.3+).
-- __K2L_RandomBase is kotlin.random.Random, the base of the program's own generators: everything is drawn from the
-- abstract nextBits(bitCount) (and nextRaw(), its nextInt(), which is nextBits(32)), as Kotlin's default implementations
-- draw. __K2L_Random is XorWow, whose nextRaw() is its next number and nextBits its upper bits.
local __K2L_RandomBase = __K2L_Class("kotlin.random.Random")
local __K2L_Random = __K2L_Class("kotlin.random.XorWowRandom", __K2L_RandomBase)

do

-- `str` formats the bounds (Double.toString for nextDouble).
local function checkRange(from, upTo, str)
    if not (upTo > from) then
        str = str or tostring
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. str(from) .. ", " .. str(upTo) .. ")."))
    end
end

function __K2L_RandomBase:____init()
end

function __K2L_RandomBase:nextRaw()
    return self:nextBits(32)
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

-- nextBits(bitCount): the upper bitCount bits of one draw. XorWow's nextBits draws even for 0 bits (nextInt(1) consumes
-- a number on the JVM).
function __K2L_Random:nextBits(bitCount)
    local raw = self:nextRaw()
    if bitCount == 0 then
        return 0
    end
    return __K2L_Ushr(raw, 32 - bitCount)
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
function __K2L_RandomBase:nextInt(from, upTo)
    if from == nil then
        return self:nextRaw()
    elseif upTo == nil then
        from, upTo = 0, from
    end
    checkRange(from, upTo)
    local n = upTo - from
    -- n is an Int in Kotlin, where 2^31 is Int.MIN_VALUE: a power of two too
    if n > 0 and n <= 2147483648 then
        local rnd
        if isPowerOfTwo(n) then
            rnd = self:nextBits(fastLog2(n))
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

-- nextInt(range: IntRange); `orNull` true is randomOrNull, false is IntRange.random (NoSuchElementException when empty).
function __K2L_RandomBase:nextIntRange(range, orNull)
    local first, last = range.first, range.last
    if last < first then
        if orNull then
            return nil
        end
        local message = "Cannot get random in empty range: " .. first .. ".." .. last
        error((orNull == false and __K2L_NoSuchElementException or __K2L_IllegalArgumentException).new(message))
    elseif last < 2147483647 then
        return self:nextInt(first, last + 1)
    elseif first > -2147483648 then
        return self:nextInt(first - 1, last) + 1
    end
    return self:nextRaw()
end

function __K2L_RandomBase:nextLong()
    local high = self:nextRaw()
    local low = self:nextRaw()
    return high * 4294967296 + low
end

function __K2L_RandomBase:nextBoolean()
    return self:nextBits(1) ~= 0
end

local function nextUnit(self)
    local high = self:nextBits(26)
    local low = self:nextBits(27)
    return (high * 134217728 + low) / 9007199254740992
end

-- nextDouble(), nextDouble(until) and nextDouble(from, until)
function __K2L_RandomBase:nextDouble(from, upTo)
    if from == nil then
        return nextUnit(self)
    elseif upTo == nil then
        from, upTo = 0.0, from
    end
    checkRange(from, upTo, __K2L_DoubleToString)
    local size = upTo - from
    local r
    if size == math.huge and from > -math.huge and upTo < math.huge then
        local half = nextUnit(self) * (upTo / 2 - from / 2)
        r = from + half + half
    else
        r = from + nextUnit(self) * size
    end
    if r >= upTo then
        return __K2L_Bits.nextDown(upTo)
    end
    return r
end

local function byteOf(v, scale)
    local b = math.floor(v / scale) % 256
    if b >= 128 then
        return b - 256
    end
    return b
end

-- nextBytes(array, from, until): four bytes per draw, low byte first, then one draw of the remaining bits, as Kotlin fills them.
function __K2L_RandomBase:nextBytes(array, from, upTo)
    local size = array.size
    from = from or 0
    upTo = upTo or size
    if from < 0 or from > size or upTo < 0 or upTo > size then
        error(__K2L_IllegalArgumentException.new("fromIndex (" .. from .. ") or toIndex (" .. upTo ..
            ") are out of range: 0.." .. size .. "."))
    end
    if from > upTo then
        error(__K2L_IllegalArgumentException.new("fromIndex (" .. from .. ") must be not greater than toIndex (" .. upTo .. ")."))
    end
    local position = from + 1
    for _ = 1, (upTo - from - (upTo - from) % 4) / 4 do
        local v = self:nextRaw()
        array[position], array[position + 1] = byteOf(v, 1), byteOf(v, 256)
        array[position + 2], array[position + 3] = byteOf(v, 65536), byteOf(v, 16777216)
        position = position + 4
    end
    local remainder = upTo + 1 - position
    local v = self:nextBits(remainder * 8)
    local scale = 1
    for i = 0, remainder - 1 do
        array[position + i] = byteOf(v, scale)
        scale = scale * 256
    end
    return array
end

function __K2L_RandomBase:nextFloat()
    return self:nextBits(24) / 16777216
end

-- XorWow's own table holds the shared methods, so that its calls find them in one lookup
for _, name in ipairs({"nextInt", "nextIntRange", "nextLong", "nextBoolean", "nextDouble", "nextBytes", "nextFloat"}) do
    __K2L_Random[name] = __K2L_RandomBase[name]
end

end
