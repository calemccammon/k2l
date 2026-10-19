-- requires: Utf16, Unicode, Numbers
-- Unicode-aware Char classification and case mapping for --strings utf16, from the tables of Unicode.lua
-- (generated from the JDK). These are the rules of Locale.ROOT; the Turkish, Azeri and Lithuanian ones are in
-- Utf16Locale.lua. The final-sigma rule of String.lowercase() approximates Java's word-boundary
-- check: the sigma is final when the word it is in has a cased letter before it and none after it.
local __K2L_Utf16Case = {}

do
    local byte, upper, lower, gsub, gmatch, concat, find = string.byte, string.upper, string.lower, string.gsub, string.gmatch, table.concat, string.find
    local C = __K2L_Utf16Case
    local U = __K2L_Utf16
    local Uni = __K2L_Unicode
    local Text = __K2L_Text
    local unitChar, code = U.unitChar, U.code

    local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"
    local NON_ASCII_CHAR = "[\194-\244][\128-\191]*"

    local function cpOf(ch)
        local b, b2, b3, b4 = byte(ch, 1, 4)
        if b < 0x80 then
            return b
        elseif b < 0xE0 then
            return (b - 0xC0) * 64 + (b2 - 0x80)
        elseif b < 0xF0 then
            return (b - 0xE0) * 4096 + (b2 - 0x80) * 64 + (b3 - 0x80)
        end
        return (b - 0xF0) * 262144 + (b2 - 0x80) * 4096 + (b3 - 0x80) * 64 + (b4 - 0x80)
    end

    ---------------------------------------------------------------- classification of Chars
    local function isAsciiLetter(b) return (b >= 65 and b <= 90) or (b >= 97 and b <= 122) end
    local function isAsciiDigit(b) return b >= 48 and b <= 57 end

    function C.isLetter(c)
        local b = byte(c)
        if b < 128 then
            return isAsciiLetter(b)
        end
        return Uni.isLetter(code(c))
    end

    function C.isDigit(c)
        local b = byte(c)
        if b < 128 then
            return isAsciiDigit(b)
        end
        return Uni.isDigit(code(c))
    end

    function C.isLetterOrDigit(c)
        local b = byte(c)
        if b < 128 then
            return isAsciiLetter(b) or isAsciiDigit(b)
        end
        local cp = code(c)
        return Uni.isLetter(cp) or Uni.isDigit(cp)
    end

    function C.isUpperCase(c)
        local b = byte(c)
        if b < 128 then
            return b >= 65 and b <= 90
        end
        return Uni.isUpper(code(c))
    end

    function C.isLowerCase(c)
        local b = byte(c)
        if b < 128 then
            return b >= 97 and b <= 122
        end
        return Uni.isLower(code(c))
    end

    function C.isTitleCase(c)
        return Uni.isTitle(code(c))
    end

    function C.isWhitespace(c)
        return U.isSpaceUnit(code(c))
    end

    -- the same for Int code points: Character.isLetter(int) and so on
    function C.isLetterCp(cp) return cp < 128 and isAsciiLetter(cp) or cp >= 128 and Uni.isLetter(cp) end
    function C.isDigitCp(cp) return cp < 128 and isAsciiDigit(cp) or cp >= 128 and Uni.isDigit(cp) end
    function C.isLetterOrDigitCp(cp) return C.isLetterCp(cp) or C.isDigitCp(cp) end
    function C.isUpperCaseCp(cp) return Uni.isUpper(cp) end
    function C.isLowerCaseCp(cp) return Uni.isLower(cp) end
    function C.isWhitespaceCp(cp) return cp < 0x10000 and U.isSpaceUnit(cp) end
    function C.toUpperCaseCp(cp) return Uni.upper(cp) end
    function C.toLowerCaseCp(cp) return Uni.lower(cp) end
    function C.toTitleCaseCp(cp) return Uni.title(cp) end

    ---------------------------------------------------------------- simple mappings of Chars
    function C.uppercaseChar(c)
        local b = byte(c)
        if b < 128 then
            return (b >= 97 and b <= 122) and string.char(b - 32) or c
        end
        return unitChar(Uni.upper(code(c)))
    end

    function C.lowercaseChar(c)
        local b = byte(c)
        if b < 128 then
            return (b >= 65 and b <= 90) and string.char(b + 32) or c
        end
        return unitChar(Uni.lower(code(c)))
    end

    function C.titlecaseChar(c)
        local b = byte(c)
        if b < 128 then
            return C.uppercaseChar(c)
        end
        return unitChar(Uni.title(code(c)))
    end

    ---------------------------------------------------------------- strings
    local function codePointsToString(list)
        local out = {}
        for i = 1, #list do
            out[i] = U.codePointString(list[i])
        end
        return concat(out)
    end

    local function mapUpper(ch)
        local cp = cpOf(ch)
        local special = Uni.specialUpper(cp)
        if special then
            return codePointsToString(special)
        end
        local mapped = Uni.upper(cp)
        if mapped ~= cp then
            return U.codePointString(mapped)
        end
    end

    -- String.uppercase(), also Char.uppercase(): ß becomes SS
    function C.uppercase(s)
        if not find(s, "[\128-\255]") then
            return upper(s)
        end
        return upper((gsub(s, NON_ASCII_CHAR, mapUpper)))
    end

    local function mapLower(ch)
        local cp = cpOf(ch)
        local special = Uni.specialLower(cp)
        if special then
            return codePointsToString(special)
        end
        local mapped = Uni.lower(cp)
        if mapped ~= cp then
            return U.codePointString(mapped)
        end
    end

    local function isWordChar(cp)
        return cp == 95 or cp == 45 or (cp < 128 and (isAsciiLetter(cp) or isAsciiDigit(cp))) or
            (cp >= 128 and (Uni.isLetter(cp) or Uni.isDigit(cp) or Uni.isMark(cp)))
    end

    -- Is the sigma at index i of the code point array a final sigma (see the header comment)?
    local function isFinalSigma(cps, i, n)
        local k = i
        local found = false
        while k > 1 and isWordChar(cps[k - 1]) and isWordChar(cps[k]) do
            if Uni.isCased(cps[k - 1]) then
                found = true
                break
            end
            k = k - 1
        end
        if not found then
            return false
        end
        k = i + 1
        while k <= n and isWordChar(cps[k - 1]) and isWordChar(cps[k]) do
            if Uni.isCased(cps[k]) then
                return false
            end
            k = k + 1
        end
        return true
    end

    local function lowerWithSigma(s)
        local cps, n = {}, 0
        for ch in gmatch(s, UTF8_CHAR) do
            n = n + 1
            cps[n] = cpOf(ch)
        end
        local out = {}
        for i = 1, n do
            local cp = cps[i]
            if cp == 0x3A3 then
                out[i] = isFinalSigma(cps, i, n) and "\207\130" or "\207\131"
            else
                local special = cp >= 128 and Uni.specialLower(cp)
                if special then
                    out[i] = codePointsToString(special)
                elseif cp < 128 then
                    out[i] = U.codePointString((cp >= 65 and cp <= 90) and cp + 32 or cp)
                else
                    out[i] = U.codePointString(Uni.lower(cp))
                end
            end
        end
        return concat(out)
    end

    -- String.lowercase(), also Char.lowercase()
    function C.lowercase(s)
        if not find(s, "[\128-\255]") then
            return lower(s)
        end
        if find(s, "\206\163", 1, true) then
            return U.norm(lowerWithSigma(s))
        end
        return lower((gsub(s, NON_ASCII_CHAR, mapLower)))
    end

    -- Char.titlecase(): the uppercase mapping, in title case when it has several chars
    function C.titlecase(c)
        local up = C.uppercase(c)
        if U.len(up) > 1 then
            if code(c) == 0x149 then
                return up
            end
            local first = Text.first(up)
            return first .. C.lowercase(Text.substring(up, 1))
        end
        return C.titlecaseChar(c)
    end

    -- Both sides of a case-insensitive comparison are folded the way Java compares chars: lower(upper(c))
    local function foldUnit(c)
        if c < 128 then
            return (c >= 65 and c <= 90) and c + 32 or c
        end
        return Uni.lower(Uni.upper(c))
    end
    U.foldUnit = foldUnit

    local function mapFold(ch)
        local cp = cpOf(ch)
        local mapped = Uni.lower(Uni.upper(cp))
        if mapped ~= cp then
            return U.codePointString(mapped)
        end
    end

    function C.fold(s)
        if not find(s, "[\128-\255]") then
            return lower(s)
        end
        return lower((gsub(s, NON_ASCII_CHAR, mapFold)))
    end

    function C.equalsIgnoreCase(a, b)
        if a == nil or b == nil then
            return a == b
        end
        return a == b or C.fold(a) == C.fold(b)
    end

    -- Regex IGNORE_CASE compares code points by this folding (Regex.lua loads before this file when it is used)
    if __K2L_Regex ~= nil then
        __K2L_Regex.____fold = foldUnit
        __K2L_Regex.____upper = Uni.upper
        __K2L_Regex.____lower = Uni.lower
    end

    function Text.caseInsensitiveOrder(a, b)
        return Text.compare(C.fold(a), C.fold(b))
    end

    ---------------------------------------------------------------- digits
    -- Char.digitToInt(radix): Unicode decimal digits and Latin letters
    local function digitOf(c, radix)
        local b = byte(c)
        local value
        if b < 128 then
            if isAsciiDigit(b) then
                value = b - 48
            elseif b >= 97 and b <= 122 then
                value = b - 87
            elseif b >= 65 and b <= 90 then
                value = b - 55
            end
        elseif #c <= 3 then
            value = Uni.digitValue(code(c))
        end
        if value == nil or value >= (radix or 10) then
            return nil
        end
        return value
    end

    local Num = __K2L_Num

    function Num.digitToIntOrNull(c, radix)
        return digitOf(c, radix)
    end

    function Num.digitToInt(c, radix)
        local value = digitOf(c, radix)
        if value == nil then
            error(__K2L_IllegalArgumentException.new("Char " .. c .. (radix and " is not a digit in the given radix=" .. radix or " is not a decimal digit")))
        end
        return value
    end
end
