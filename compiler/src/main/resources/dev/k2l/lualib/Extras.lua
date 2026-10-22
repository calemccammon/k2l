-- requires: Strings, Exceptions, Lazy, Collections
-- More of the Kotlin stdlib: kotlin.text functions (replaceAfter and friends, toByte and toShort, Char.isISOControl, decoding
-- bytes), lazyOf, and the right-to-left reductions of lists and arrays.
local __K2L_Extras = {}

local function lastIndexOf(s, part)
    local last
    local i = s:find(part, 1, true)
    while i do
        last = i
        i = s:find(part, i + 1, true)
    end
    return last
end

-- replaceAfter(delimiter, replacement, missingDelimiterValue = this) and the other three
function __K2L_Extras.replaceAfter(s, delimiter, replacement, missing)
    local _, j = s:find(delimiter, 1, true)
    if j == nil then
        return missing or s
    end
    return s:sub(1, j) .. replacement
end

function __K2L_Extras.replaceBefore(s, delimiter, replacement, missing)
    local i = s:find(delimiter, 1, true)
    if i == nil then
        return missing or s
    end
    return replacement .. s:sub(i)
end

function __K2L_Extras.replaceAfterLast(s, delimiter, replacement, missing)
    local i = lastIndexOf(s, delimiter)
    if i == nil then
        return missing or s
    end
    return s:sub(1, i + #delimiter - 1) .. replacement
end

function __K2L_Extras.replaceBeforeLast(s, delimiter, replacement, missing)
    local i = lastIndexOf(s, delimiter)
    if i == nil then
        return missing or s
    end
    return replacement .. s:sub(i)
end

-- toByte/toShort (bits 8 or 16) and their OrNull forms: toInt, then the range of the type
function __K2L_Extras.toSmallOrNull(s, bits, radix)
    local n = __K2L_StringToIntOrNull(s, radix)
    local limit = bits == 8 and 128 or 32768
    if n == nil or n < -limit or n >= limit then
        return nil
    end
    return n
end

function __K2L_Extras.toSmall(s, bits, radix)
    local n = __K2L_Extras.toSmallOrNull(s, bits, radix)
    if n == nil then
        -- the message of java.lang.Byte.parseByte / Short.parseShort
        if __K2L_StringToIntOrNull(s, radix) ~= nil then
            error(__K2L_NumberFormatException.new("Value out of range. Value:\"" .. s .. "\" Radix:" .. (radix or 10)))
        end
        __K2L_StringToInt(s, radix)
    end
    return n
end

-- the string whose UTF-8 is the bytes of a ByteArray
function __K2L_Extras.decode(bytes)
    local parts, char = {}, string.char
    for i = 1, bytes.size do
        parts[i] = char(bytes[i] % 256)
    end
    return table.concat(parts)
end

function __K2L_Extras.isISOControl(code)
    return code <= 31 or (code >= 127 and code <= 159)
end

-- reduceRightOrNull, reduceRightIndexed and reduceRightIndexedOrNull of a list or an array (`kind` names it in the error)
function __K2L_Extras.reduceRight(items, operation, indexed, orNull, kind)
    local n = items.size
    if n == 0 then
        if orNull then
            return nil
        end
        error(__K2L_UnsupportedOperationException.new("Empty " .. kind .. " can't be reduced."))
    end
    local acc = items[n]
    for i = n - 1, 1, -1 do
        if indexed then
            acc = operation(i - 1, items[i], acc)
        else
            acc = operation(items[i], acc)
        end
    end
    return acc
end

------------------------------------------------------------------ hex digits of the default HexFormat

local TWO32 = 4294967296
-- 2^bits, as integers where Lua has them
local SPAN = {[8] = 256, [16] = 65536, [32] = 4294967296}
local DIGITS = {[8] = 2, [16] = 4, [32] = 8, [64] = 16}

-- Int/Long/Short/Byte.toHexString(): the two's complement bits, `bits / 4` lowercase digits
function __K2L_Extras.toHex(value, bits)
    if bits == 64 then
        local lo = value % TWO32
        local hi = ((value - lo) / TWO32) % TWO32
        return string.format("%08x%08x", hi, lo)
    end
    return string.format("%0" .. DIGITS[bits] .. "x", value % SPAN[bits])
end

function __K2L_Extras.bytesToHex(bytes)
    local parts, format = {}, string.format
    for i = 1, bytes.size do
        parts[i] = format("%02x", bytes[i] % 256)
    end
    return table.concat(parts)
end

local function hexDigits(s, most)
    if #s == 0 or #s > most or s:find("[^%x]") then
        error(__K2L_NumberFormatException.new("Expected a hexadecimal number of at most " .. most .. " digits, but was \"" .. s .. "\""))
    end
end

-- String.hexToInt() (bits 32), hexToLong() (64), hexToShort() (16), hexToByte() (8): the bits of the type, signed
function __K2L_Extras.hexTo(s, bits)
    hexDigits(s, DIGITS[bits])
    if bits == 64 then
        -- the high and low 32 bits apart, exact without Lua integers too
        local padded = string.rep("0", 16 - #s) .. s
        local hi, lo = tonumber(padded:sub(1, 8), 16), tonumber(padded:sub(9), 16)
        if hi >= 2147483648 then
            hi = hi - TWO32
        end
        return hi * TWO32 + lo
    end
    local acc = tonumber(s, 16)
    if acc >= SPAN[bits] / 2 then
        acc = acc - SPAN[bits]
    end
    return acc
end

function __K2L_Extras.hexToBytes(s)
    if #s % 2 ~= 0 or s:find("[^%x]") then
        error(__K2L_NumberFormatException.new("Expected an even number of hexadecimal digits, but was \"" .. s .. "\""))
    end
    local out = {}
    local n = math.floor(#s / 2)
    for i = 1, n do
        local b = tonumber(s:sub(2 * i - 1, 2 * i), 16)
        out[i] = b >= 128 and b - 256 or b
    end
    out.size = n
    return setmetatable(out, __K2L_Array)
end

function __K2L_Extras.lazyOf(value)
    local lazy = __K2L_Lazy(function()
        return value
    end)
    lazy:getValue()
    return lazy
end
