-- requires: Random, Unsigned, Long64
-- Random.nextLong(until), nextLong(from, until), nextUInt and nextULong with --long64 emulate, as Kotlin's Random implements
-- them: the same draws from the generator, so a seeded Random gives the numbers the JVM gives.
local __K2L_RandomLong = {}

do

local L = __K2L_Long64
local add, sub, lt, band, neg, shl, ushr = L.add, L.sub, L.lt, L.band, L.neg, L.shl, L.ushr
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

local function nextLong(rng)
    local high = rng:nextRaw()
    return add(L.make(high, 0), rng:nextRaw())
end

-- nextLong(from, until); `from` may be nil for nextLong(until).
local function nextLongRange(rng, from, upTo)
    if from == nil then
        from = 0
    end
    if not lt(from, upTo) then
        error(__K2L_IllegalArgumentException.new("Random range is empty: [" .. L.str(from) .. ", " .. L.str(upTo) .. ")."))
    end
    local n = sub(upTo, from)
    if lt(0, n) then
        local rnd
        if band(n, neg(n)) == n then
            local low = L.toInt(n) % TWO_32
            local high = L.toInt(ushr(n, 32)) % TWO_32
            if low ~= 0 then
                rnd = rng:nextBits(fastLog2(low)) % TWO_32
            elseif high == 1 then
                rnd = rng:nextRaw() % TWO_32
            else
                local bitCount = fastLog2(high)
                rnd = add(shl(rng:nextBits(bitCount), 32), rng:nextRaw() % TWO_32)
            end
        else
            local v
            repeat
                local bits = ushr(nextLong(rng), 1)
                v = L.rem(bits, n)
            until not lt(add(sub(bits, v), sub(n, 1)), 0)
            rnd = v
        end
        return add(from, rnd)
    end
    while true do
        local rnd = nextLong(rng)
        if not lt(rnd, from) and lt(rnd, upTo) then
            return rnd
        end
    end
end

__K2L_RandomLong.nextLong = nextLongRange

-- nextLong(range: LongRange); `orNull` true is randomOrNull, false is LongRange.random (NoSuchElementException when empty).
function __K2L_RandomLong.nextLongIn(rng, range, orNull)
    local first, last = range.first, range.last
    if lt(last, first) then
        if orNull then
            return nil
        end
        local message = "Cannot get random in empty range: " .. L.str(first) .. ".." .. L.str(last)
        error((orNull == false and __K2L_NoSuchElementException or __K2L_IllegalArgumentException).new(message))
    elseif lt(last, L.MAX) then
        return nextLongRange(rng, first, add(last, 1))
    elseif lt(L.MIN, first) then
        return add(nextLongRange(rng, sub(first, 1), last), 1)
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
    if L.ucmp(from, upTo) >= 0 then
        emptyRange(from, upTo)
    end
    local minimum = L.MIN
    return L.bxor(nextLongRange(rng, L.bxor(from, minimum), L.bxor(upTo, minimum)), minimum)
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
