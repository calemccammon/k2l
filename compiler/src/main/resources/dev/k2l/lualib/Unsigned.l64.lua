-- requires: Exceptions, Long64
-- ULong with --long64 emulate: the bit pattern of a Long (see Long64.l64.lua), so values from 2^63 are negative.
local __K2L_Unsigned = {}

do

local L = __K2L_Long64

__K2L_Unsigned.udiv = L.udiv
__K2L_Unsigned.urem = L.urem
__K2L_Unsigned.compare = L.ucmp
__K2L_Unsigned.toString = L.ustr
__K2L_Unsigned.toDouble = L.utoDouble
__K2L_Unsigned.fromDouble64 = L.ufromDouble

-- Double.toUInt(): saturating, NaN is 0.
function __K2L_Unsigned.fromDouble32(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= 4294967295 then
        return 4294967295
    end
    return math.floor(x)
end

end
