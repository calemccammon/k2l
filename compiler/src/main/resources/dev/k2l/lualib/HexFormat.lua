-- requires: Extras, Exceptions, Collections
-- kotlin.text.HexFormat: a format and its builders are tables of the properties, which the program reads and (in a
-- builder) writes directly. Numbers and byte arrays are formatted and parsed with them as the stdlib does.
local __K2L_HexFormat = {}
local Extras = __K2L_Extras
local MAX = 2147483647

local function bytesFormat(from)
    from = from or {}
    return {
        bytesPerLine = from.bytesPerLine or MAX, bytesPerGroup = from.bytesPerGroup or MAX,
        groupSeparator = from.groupSeparator or "  ", byteSeparator = from.byteSeparator or "",
        bytePrefix = from.bytePrefix or "", byteSuffix = from.byteSuffix or "",
    }
end

local function numberFormat(from)
    from = from or {}
    local removeLeadingZeros = from.removeLeadingZeros
    if removeLeadingZeros == nil then
        removeLeadingZeros = false
    end
    return {prefix = from.prefix or "", suffix = from.suffix or "", removeLeadingZeros = removeLeadingZeros, minLength = from.minLength or 1}
end

local function newFormat(upperCase, bytes, number)
    return {upperCase = upperCase, bytes = bytesFormat(bytes), number = numberFormat(number)}
end

__K2L_HexFormat.Default = newFormat(false)
__K2L_HexFormat.UpperCase = newFormat(true)

-- HexFormat { builderAction }: the builder starts from the default format
function __K2L_HexFormat.build(action)
    local builder = newFormat(false)
    action(builder)
    return newFormat(builder.upperCase, builder.bytes, builder.number)
end

-- bytes { } and number { } of a builder
function __K2L_HexFormat.configure(part, action)
    action(part)
end

------------------------------------------------------------------ numbers

-- Int/Long/Short/Byte.toHexString(format), of the `bits` of the value
function __K2L_HexFormat.number(value, bits, format)
    local number = format.number
    local digits = Extras.toHex(value, bits)
    if number.removeLeadingZeros then
        digits = digits:gsub("^0+", "")
        if digits == "" then
            digits = "0"
        end
    end
    if #digits < number.minLength then
        digits = string.rep("0", number.minLength - #digits) .. digits
    end
    if format.upperCase then
        digits = digits:upper()
    end
    return number.prefix .. digits .. number.suffix
end

-- String.hexToInt(format) and friends: the digits between the prefix and the suffix (both matched ignoring case)
function __K2L_HexFormat.parseNumber(s, bits, format)
    local prefix, suffix = format.number.prefix, format.number.suffix
    local n = #s
    if n < #prefix + #suffix or s:sub(1, #prefix):lower() ~= prefix:lower() or s:sub(n - #suffix + 1):lower() ~= suffix:lower() then
        error(__K2L_NumberFormatException.new("Expected a hexadecimal number with prefix \"" .. prefix .. "\" and suffix \"" .. suffix
            .. "\", but was " .. s))
    end
    local digits = s:sub(#prefix + 1, n - #suffix):gsub("^0+(%x)", "%1")
    return Extras.hexTo(digits, bits)
end

------------------------------------------------------------------ byte arrays

-- ByteArray.toHexString(startIndex, endIndex, format)
function __K2L_HexFormat.bytes(array, from, to, format)
    from, to = from or 0, to or array.size
    local bytes = format.bytes
    local perLine, perGroup = bytes.bytesPerLine, bytes.bytesPerGroup
    local pattern = format.upperCase and "%02X" or "%02x"
    local out = {}
    for i = from, to - 1 do
        local k = i - from
        if k > 0 then
            if k % perLine == 0 then
                out[#out + 1] = "\n"
            elseif k % perLine % perGroup == 0 then
                out[#out + 1] = bytes.groupSeparator
            else
                out[#out + 1] = bytes.byteSeparator
            end
        end
        out[#out + 1] = bytes.bytePrefix .. string.format(pattern, array[i + 1] % 256) .. bytes.byteSuffix
    end
    return table.concat(out)
end

-- String.hexToByteArray(format): the layout `bytes` writes, with "\n", "\r\n" or "\r" between lines and the
-- separators, prefix and suffix matched ignoring case
function __K2L_HexFormat.parseBytes(s, format)
    local bytes = format.bytes
    local perLine, perGroup = bytes.bytesPerLine, bytes.bytesPerGroup
    local lower = s:lower()
    local out, n, i, len = {}, 0, 1, #s
    local function fail()
        error(__K2L_NumberFormatException.new("Expected a hexadecimal byte array in the format, but was \"" .. s .. "\""))
    end
    local function expect(text)
        if lower:sub(i, i + #text - 1) ~= text:lower() then
            fail()
        end
        i = i + #text
    end
    while i <= len do
        if n > 0 then
            if n % perLine == 0 then
                local newline = s:match("^\r?\n", i) or s:match("^\r", i)
                if newline == nil then
                    fail()
                end
                i = i + #newline
            elseif n % perLine % perGroup == 0 then
                expect(bytes.groupSeparator)
            else
                expect(bytes.byteSeparator)
            end
        end
        expect(bytes.bytePrefix)
        local digits = s:sub(i, i + 1)
        if not digits:match("^%x%x$") then
            fail()
        end
        i = i + 2
        expect(bytes.byteSuffix)
        local b = tonumber(digits, 16)
        n = n + 1
        out[n] = b >= 128 and b - 256 or b
    end
    out.size = n
    return setmetatable(out, __K2L_ArrayClassOf("[B"))
end
