-- requires: Random, Unsigned
-- Random.nextLong(until), nextLong(from, until), nextUInt and nextULong on Lua 5.3/5.4, as Kotlin's Random implements them:
-- the same draws from the generator, so a seeded Random gives the numbers the JVM gives. The draws are
-- rng:nextRaw() (nextInt()) and rng:nextBits, so a generator of the program gets Kotlin's defaults too.
local __K2L_RandomLong = {}

do

local ult = math.ult

local function fastLog2(n)
    local log = 0
    while n > 1 do
        n = n >> 1
        log = log + 1
    end
    return log
end

local function toInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end

local function nextLong(rng)
    return (rng:nextRaw() << 32) + rng:nextRaw()
end

-- nextLong(from, until); `from` may be nil for nextLong(until).
local function nextLongRange(rng, from, upTo)
    if from == nil then
        from = 0
    end
    if not (from < upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. from .. ", " .. upTo .. ")."))
    end
    local n = upTo - from
    if n > 0 then
        local rnd
        if (n & -n) == n then
            local low = toInt32(n)
            local high = toInt32(n >> 32)
            if low ~= 0 then
                rnd = rng:nextBits(fastLog2(low & 0xFFFFFFFF)) & 0xFFFFFFFF
            elseif high == 1 then
                rnd = rng:nextRaw() & 0xFFFFFFFF
            else
                local bitCount = fastLog2(high & 0xFFFFFFFF)
                rnd = (rng:nextBits(bitCount) << 32) + (rng:nextRaw() & 0xFFFFFFFF)
            end
        else
            local v
            repeat
                local bits = nextLong(rng) >> 1
                v = bits % n
            until bits - v + (n - 1) >= 0
            rnd = v
        end
        return from + rnd
    end
    while true do
        local rnd = nextLong(rng)
        if rnd >= from and rnd < upTo then
            return rnd
        end
    end
end

__K2L_RandomLong.nextLong = nextLongRange

-- nextLong(range: LongRange); `orNull` true is randomOrNull, false is LongRange.random (NoSuchElementException when empty).
function __K2L_RandomLong.nextLongIn(rng, range, orNull)
    local first, last = range.first, range.last
    if last < first then
        if orNull then
            return nil
        end
        local message = "Cannot get random in empty range: " .. first .. ".." .. last
        error((orNull == false and __K2L_NoSuchElementException or __K2L_IllegalArgumentException).new(message))
    elseif last < math.maxinteger then
        return nextLongRange(rng, first, last + 1)
    elseif first > math.mininteger then
        return nextLongRange(rng, first - 1, last) + 1
    end
    return nextLong(rng)
end

local function emptyRange(from, upTo)
    error(__K2L_IllegalArgumentException.new("Random range is empty: [" ..
        __K2L_Unsigned.toString(from) .. ", " .. __K2L_Unsigned.toString(upTo) .. ")."))
end

-- nextULong(from, until): the signed draw over the range shifted by Long.MIN_VALUE.
function __K2L_RandomLong.nextULong(rng, from, upTo)
    if from == nil and upTo == nil then
        return nextLong(rng)
    elseif from == nil then
        from = 0
    end
    if not ult(from, upTo) then
        emptyRange(from, upTo)
    end
    local minimum = math.mininteger
    return nextLongRange(rng, from ~ minimum, upTo ~ minimum) ~ minimum
end

-- nextUInt(from, until)
function __K2L_RandomLong.nextUInt(rng, from, upTo)
    if from == nil and upTo == nil then
        return rng:nextRaw() & 0xFFFFFFFF
    elseif from == nil then
        from = 0
    end
    if not (from < upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. from .. ", " .. upTo .. ")."))
    end
    return rng:nextInt(from - 2147483648, upTo - 2147483648) + 2147483648
end

end
