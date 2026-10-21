-- requires: Exceptions, Long64, Long64Ext, JavaNumbers
-- The Long statics of JavaLongs with --long64 emulate, on the exact operations of Long64 (the unsigned ones are mapped to
-- Long64's own).
local __K2L_JavaLongs = {}

do

local L = __K2L_JavaLongs
local W, X = __K2L_Long64, __K2L_Long64X
local MIN = W.MIN

local function overflow()
    error(__K2L_ArithmeticException.new("long overflow"))
end

local function isMinByMinusOne(a, b)
    return b == -1 and W.cmp(a, MIN) == 0
end

function L.ceilDiv(a, b)
    local q = W.div(a, b)
    if (W.lt(a, 0) == W.lt(b, 0)) and W.rem(a, b) ~= 0 then
        return W.add(q, 1)
    end
    return q
end

function L.ceilMod(a, b)
    return W.sub(a, W.mul(L.ceilDiv(a, b), b))
end

function L.divideExact(a, b)
    if isMinByMinusOne(a, b) then
        overflow()
    end
    return W.div(a, b)
end

function L.floorDivExact(a, b)
    if isMinByMinusOne(a, b) then
        overflow()
    end
    return X.floorDiv(a, b)
end

function L.ceilDivExact(a, b)
    if isMinByMinusOne(a, b) then
        overflow()
    end
    return L.ceilDiv(a, b)
end

function L.clamp(value, lo, hi)
    if W.lt(hi, lo) then
        error(__K2L_IllegalArgumentException.new(W.str(lo) .. " > " .. W.str(hi)))
    end
    if W.lt(value, lo) then
        return lo
    elseif W.lt(hi, value) then
        return hi
    end
    return value
end

function L.parseUnsigned(s, radix)
    __K2L_JavaNumbers.checkUnsigned(s)
    local n = X.parse(s, radix, true)
    if n == nil then
        __K2L_JavaNumbers.unsignedFailure(s, radix, "long")
    end
    return n
end

end
