-- requires: Random, Unsigned
-- Random.nextLong(until), nextLong(from, until), nextUInt and nextULong without 64-bit integers. nextUInt is exact. A
-- Long is a double, so ranges up to 2^52 draw the numbers the JVM draws and the rest are only approximately uniform.
local __K2L_RandomLong = {}

do

local TWO_32 = 4294967296
local TWO_31 = 2147483648

local function fastLog2(n)
    local log = 0
    while n > 1 do
        n = (n - n % 2) / 2
        log = log + 1
    end
    return log
end

local function mulmod(a, b, n)
    local result = 0
    a = a % n
    while b > 0 do
        if b % 2 == 1 then
            result = (result + a) % n
        end
        a = (a * 2) % n
        b = (b - b % 2) / 2
    end
    return result
end

local function isPowerOfTwo(n)
    return 2 ^ fastLog2(n) == n
end

-- nextLong(from, until); `from` may be nil for nextLong(until).
local function nextLongRange(rng, from, upTo)
    if from == nil then
        from = 0
    end
    if not (from < upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. string.format("%.0f", from) .. ", " ..
            string.format("%.0f", upTo) .. ")."))
    end
    local n = upTo - from
    local rnd
    if n <= 4503599627370496 and isPowerOfTwo(n) then
        if n < TWO_32 then
            rnd = rng:nextBits(fastLog2(n)) % TWO_32
        elseif n == TWO_32 then
            rnd = rng:nextRaw() % TWO_32
        else
            local bitCount = fastLog2(n / TWO_32)
            rnd = rng:nextBits(bitCount) * TWO_32 + rng:nextRaw() % TWO_32
        end
    else
        -- bits = nextLong() ushr 1, from the two 32-bit draws: high * 2^32 + signed low
        local high = rng:nextRaw() % TWO_32
        local low = rng:nextRaw() % TWO_32
        if low >= TWO_31 then
            high = (high - 1) % TWO_32
        end
        local v = (mulmod(high, TWO_31 % n, n) + math.floor(low / 2)) % n
        rnd = v
    end
    return from + rnd
end

__K2L_RandomLong.nextLong = nextLongRange

-- nextLong(range: LongRange); `orNull` true is randomOrNull, false is LongRange.random (NoSuchElementException when empty).
function __K2L_RandomLong.nextLongIn(rng, range, orNull)
    local first, last = range.first, range.last
    if last < first then
        if orNull then
            return nil
        end
        local message = "Cannot get random in empty range: " .. string.format("%.0f", first) .. ".." .. string.format("%.0f", last)
        error((orNull == false and __K2L_NoSuchElementException or __K2L_IllegalArgumentException).new(message))
    elseif last < 9223372036854775807 then
        return nextLongRange(rng, first, last + 1)
    elseif first > -9223372036854775808 then
        return nextLongRange(rng, first - 1, last) + 1
    end
    return rng:nextLong()
end

function __K2L_RandomLong.nextULong(rng, from, upTo)
    if from == nil and upTo == nil then
        return (rng:nextRaw() * TWO_32 + rng:nextRaw()) % 18446744073709551616
    elseif from == nil then
        from = 0
    end
    if not (from < upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. __K2L_Unsigned.toString(from) .. ", " ..
            __K2L_Unsigned.toString(upTo) .. ")."))
    end
    return nextLongRange(rng, from, upTo)
end

-- nextUInt(from, until)
function __K2L_RandomLong.nextUInt(rng, from, upTo)
    if from == nil and upTo == nil then
        return rng:nextRaw() % TWO_32
    elseif from == nil then
        from = 0
    end
    if not (from < upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. from .. ", " .. upTo .. ")."))
    end
    return rng:nextInt(from - TWO_31, upTo - TWO_31) + TWO_31
end

end
