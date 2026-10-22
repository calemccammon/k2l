-- requires: Class, Exceptions
-- kotlin.random.Random. __K2L_RandomBase is the class itself, the base of the program's own generators: everything is
-- drawn from the abstract nextBits(bitCount), mostly through nextUnit(), a Double in [0, 1) of 53 bits.
-- Random.Default (__K2L_Random.default()) draws from Lua's math.random. Random(seed) (__K2L_Random) is a linear
-- congruential generator of k2l's own (see nextBits below): its sequences are the same on every Lua target, but not the
-- JVM's.
local __K2L_RandomBase = __K2L_Class("kotlin.random.Random")
local __K2L_Random = __K2L_Class("kotlin.random.SeededRandom", __K2L_RandomBase)
local __K2L_DefaultRandom = __K2L_Class("kotlin.random.Random.Default", __K2L_RandomBase)

do

local floor, random = math.floor, math.random
local TWO_31, TWO_32, TWO_53 = 2147483648, 4294967296, 9007199254740992

local function checkRange(from, upTo)
    if not (upTo > from) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. tostring(from) .. ", " .. tostring(upTo) .. ")."))
    end
end

function __K2L_RandomBase:____init()
end

-- nextInt(): 32 random bits, as an Int
function __K2L_RandomBase:nextRaw()
    return self:nextBits(32)
end

-- a Double in [0, 1), of 53 random bits
function __K2L_RandomBase:nextUnit()
    return (self:nextBits(26) * 134217728 + self:nextBits(27)) / TWO_53
end

-- nextInt(), nextInt(until) and nextInt(from, until); nextLong the same with Longs
function __K2L_RandomBase:nextInt(from, upTo)
    if from == nil then
        return self:nextRaw()
    elseif upTo == nil then
        from, upTo = 0, from
    end
    checkRange(from, upTo)
    return from + floor(self:nextUnit() * (upTo - from))
end

function __K2L_RandomBase:nextLong(from, upTo)
    if from == nil then
        return self:nextBits(32) * TWO_32 + self:nextBits(32) % TWO_32
    end
    return self:nextInt(from, upTo)
end

-- nextInt(range) and nextLong(range); `orNull` true is randomOrNull, false is range.random() (NoSuchElementException when
-- the range is empty, IllegalArgumentException for nextInt(range))
function __K2L_RandomBase:nextIntRange(range, orNull)
    local first, last = range.first, range.last
    if last < first then
        if orNull then
            return nil
        end
        local message = "Cannot get random in empty range: " .. first .. ".." .. last
        error((orNull == false and __K2L_NoSuchElementException or __K2L_IllegalArgumentException).new(message))
    end
    return first + floor(self:nextUnit() * (last - first + 1))
end

__K2L_RandomBase.nextLongRange = __K2L_RandomBase.nextIntRange

function __K2L_RandomBase:nextBoolean()
    return self:nextBits(1) ~= 0
end

-- nextDouble(), nextDouble(until) and nextDouble(from, until)
function __K2L_RandomBase:nextDouble(from, upTo)
    if from == nil then
        return self:nextUnit()
    elseif upTo == nil then
        from, upTo = 0.0, from
    end
    checkRange(from, upTo)
    -- in halves when the size of the range overflows
    local half = self:nextUnit() * (upTo / 2 - from / 2)
    local r = from + half + half
    return r < upTo and r or from
end

function __K2L_RandomBase:nextFloat()
    return self:nextBits(24) / 16777216
end

-- nextBytes(array, from, until): a random Byte for each element
function __K2L_RandomBase:nextBytes(array, from, upTo)
    from, upTo = from or 0, upTo or array.size
    if from < 0 or upTo > array.size or from > upTo then
        error(__K2L_IllegalArgumentException.new("fromIndex (" .. from .. ") or toIndex (" .. upTo .. ") are out of range: 0.." ..
            array.size .. "."))
    end
    for i = from + 1, upTo do
        local b = self:nextBits(8)
        array[i] = b >= 128 and b - 256 or b
    end
    return array
end

-- Random(seed): state' = (A * state + C) mod 2^32. C is odd and A - 1 a multiple of 4, which gives the full period of
-- 2^32 (Hull and Dobell); A < 2^21 keeps A * state below 2^53, so a step is exact in doubles too. nextBits takes the upper
-- bits of the state, as the low bits of such a generator repeat with short periods.
local A, C = 1718273, 2531011

function __K2L_Random:____init(seed)
    local low = seed % TWO_32
    self.state = (low + floor((seed - low) / TWO_32)) % TWO_32
    self:nextBits(32)
end

function __K2L_Random.seeded(seed)
    return __K2L_Random.new(seed)
end

function __K2L_Random:nextBits(bitCount)
    local state = (A * self.state + C) % TWO_32
    self.state = state
    local bits = floor(state / 2 ^ (32 - bitCount))
    if bitCount == 32 and bits >= TWO_31 then
        return bits - TWO_32
    end
    return bits
end

-- Random.Default: math.random
function __K2L_DefaultRandom:nextUnit()
    return random()
end

function __K2L_DefaultRandom:nextBits(bitCount)
    local bits = floor(random() * 2 ^ bitCount)
    if bitCount == 32 and bits >= TWO_31 then
        return bits - TWO_32
    end
    return bits
end

local default = __K2L_DefaultRandom.new()

function __K2L_Random.default()
    return default
end

end
