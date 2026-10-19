-- requires: Utf16, Unicode, Utf16Case
-- Locale-specific case mapping for --strings utf16: the rules of java.lang.String.toUpperCase(Locale) and toLowerCase(Locale)
-- for Turkish and Azeri (dotted and dotless i) and Lithuanian (dots kept on i, j and i with ogonek under accents), as in
-- the JDK's ConditionalSpecialCasing. Every other locale maps like Locale.ROOT. A locale is its tag string, see Locale.lua.
-- The combining classes the conditions look at come from compiler/tools/GenCombining.java.
local __K2L_Utf16Locale = {}

do
    local byte, gmatch, concat, floor = string.byte, string.gmatch, table.concat, math.floor
    local L = __K2L_Utf16Locale
    local U = __K2L_Utf16
    local C = __K2L_Utf16Case
    local Text = __K2L_Text
    local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"

    -- code points whose canonical combining class is 230 ("above"), and those with any other non-zero class
    local sets = {
        above = "lc,l,14,3,2,1,3,1,3,3,3,3,4,1,3,1,7,d,7n,5,7e,4,1,3,2,6,6,2,1,2,2,1,k,1,23,8,1n,2,2,5,1,2,3b,7,2,4,1,1,2,2,2,2,1v,1,1,2,1,2,3,1,2,1,1,3,1,1,1,1,1,1,1,2,4g,7,1,1,y,4,1,9,1,3,1,5,2y,1,3,4,16,5,5,e,2,2,1,2,1,3,6,3,1,2,2,5,29,1,1,2,4p,1,137,2,2,2,r9,3,vx,1,9o,1,64,1,2l,8,1f,5,6,2,4,2,2,5,1,4,4c,1,1,7,9o,3,7,2,4,1,j,1,3,2,5i,2,1,7,1,2,4,11,5,1,2,1,k1,2,2,4,3,2,4,1,5,1,1,1,6,1,2da,3,6m,w,nsf,1,4,a,w,2,28,2,dq,i,ce,1,1,2,3,2,5,2,1,1,ggu,7,7,2,11i,5,1as,1,14,1,4s,1,fy,4,ar,2,4b,3,1,1,1h,1,1,1,aj,3,gz,7,3,5,6h,1,h5d,7,k7i,5,w,4,44,3,2pn,7,1,h,2,7,1,2,1,5,2s,1,4g,7,af,1,1p,4,e7,1,us,6,l706",
        other = "lx,14,8,1,1,3,3,2,4,4,1,3,1,7,fi,1,4,1,3,2,6,6,2,1,2,2,1,e,1,1,1,2,2,1,1,1,28,3,1c,8,2,2,5,1,2,1,g,1,36,1,6,1,2,1,z,1,v,1,2,1,2,3,1,2,1,1,3,1,1,1,1,1,1,1,4p,1,a,1,2j,3,1p,3,1f,5,f,1,2,1,2,1,3,6,3,1,2,2,1t,1,g,1,4,1,2x,1,g,1,32,1,g,1,32,1,g,1,32,1,g,1,3j,1,32,1,g,1,7,2,2t,1,g,1,31,2,g,1,3g,1,31,3,d,4,30,3,d,4,24,2,r,1,1,1,1,1,1j,2,1,1,5,4,2,1,3,1,1t,1,34,1,1,2,2a,1,1ae,2,u,1,4d,1,5y,1,3z,1,1,1,64,1,1z,1,u,1,1h,6,2,1,1,2,2,2,5,1,2x,1,f,1,13,1,1p,2,1m,1,b,2,1v,1,4c,6,2,4,2,7,4,1,5w,1,7,1,2,4,11,5,1,2,1,1,k2,2,4,3,a,2,1,1,1,6,2hb,1,iy,6,2x,2,nl7,1,11,1,47,1,2u,3,11,1,2n,1,c,1,6r,1,1t,1,6u,1,fn4,1,lk,7,r3,1,6a,1,1f0,1,17,2,4,1,4m,1,t2,3,1y,2,3,1,1,4,1e,1,1,1,5c,1,15,1,e,1,1l,2,3c,2,1q,1,24,1,9,1,2y,2,4y,2,28,2,g,1,6s,1,3,1,3f,2,6z,2,3i,1,3a,2,37,1,7h,2,76,2,4,1,4c,1,2b,1,i,1,29,1,bp,1,76,1,1,2,29,1,bt,2,ey5,5,zf,2,f58,1,43q,5,3,6,8,8,7,2,3ts,3,rl,7,37,1,l705",
    }
    local decoded = {}

    local function decode(name)
        local starts, ends, n = {}, {}, 0
        local pos, inside = 0, false
        for run in sets[name]:gmatch("[^,]+") do
            local len = tonumber(run, 36)
            if inside then
                n = n + 1
                starts[n], ends[n] = pos, pos + len - 1
            end
            pos = pos + len
            inside = not inside
        end
        decoded[name] = {starts = starts, ends = ends, n = n}
        return decoded[name]
    end

    local function inSet(name, cp)
        local set = decoded[name] or decode(name)
        local starts, ends = set.starts, set.ends
        local lo, hi = 1, set.n
        while lo <= hi do
            local mid = floor((lo + hi) / 2)
            if cp < starts[mid] then
                hi = mid - 1
            elseif cp > ends[mid] then
                lo = mid + 1
            else
                return true
            end
        end
        return false
    end

    -- the Soft_Dotted property
    local SOFT_DOTTED = {
        [0x69] = true, [0x6A] = true, [0x12F] = true, [0x249] = true, [0x268] = true, [0x29D] = true, [0x2B2] = true,
        [0x3F3] = true, [0x456] = true, [0x458] = true, [0x1D62] = true, [0x1D96] = true, [0x1DA4] = true, [0x1DA8] = true,
        [0x1E2D] = true, [0x1ECB] = true, [0x2071] = true, [0x2148] = true, [0x2149] = true, [0x2C7C] = true, [0x1DF1A] = true,
        [0x1E04C] = true, [0x1E04D] = true, [0x1E068] = true,
    }
    for _, start in ipairs({0x1D422, 0x1D456, 0x1D48A, 0x1D4BE, 0x1D4F2, 0x1D526, 0x1D55A, 0x1D58E, 0x1D5C2, 0x1D5F6, 0x1D62A,
        0x1D65E, 0x1D692}) do
        SOFT_DOTTED[start], SOFT_DOTTED[start + 1] = true, true
    end

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

    -- Whether the code point has combining class 0 or 230, where the conditions stop looking.
    local function stops(cp)
        return not inSet("other", cp)
    end

    -- Is there `wanted` after index i, with only other combining marks in between?
    local function isBefore(cps, i, n, wanted)
        for k = i + 1, n do
            local cp = cps[k]
            if cp == wanted then
                return true
            elseif stops(cp) then
                return false
            end
        end
        return false
    end

    -- Is there a code point satisfying `test` before index i, with only other combining marks in between?
    local function isAfter(cps, i, test)
        for k = i - 1, 1, -1 do
            local cp = cps[k]
            if test(cp) then
                return true
            elseif stops(cp) then
                return false
            end
        end
        return false
    end

    -- Is a combining mark of class 230 after index i, before any other starter?
    local function isMoreAbove(cps, i, n)
        for k = i + 1, n do
            local cp = cps[k]
            if inSet("above", cp) then
                return true
            elseif not inSet("other", cp) then
                return false
            end
        end
        return false
    end

    local function codePoints(s)
        local cps, n = {}, 0
        for ch in gmatch(s, UTF8_CHAR) do
            n = n + 1
            cps[n] = cpOf(ch)
        end
        return cps, n
    end

    local function language(tag)
        return tag:match("^[^_]*")
    end

    local function isI(cp) return cp == 0x49 end
    local function isSoftDotted(cp) return SOFT_DOTTED[cp] == true end

    -- The text a char is lowercased to in the locale, or nil for the standard mapping.
    local function lowerReplacement(lang, cps, i, n)
        local cp = cps[i]
        if lang == "tr" or lang == "az" then
            if cp == 0x130 then
                return "i"
            elseif cp == 0x49 then
                return isBefore(cps, i, n, 0x307) and "i" or "\196\177"
            elseif cp == 0x307 and isAfter(cps, i, isI) then
                return ""
            end
        elseif lang == "lt" then
            if cp == 0x49 and isMoreAbove(cps, i, n) then
                return "i\204\135"
            elseif cp == 0x4A and isMoreAbove(cps, i, n) then
                return "j\204\135"
            elseif cp == 0x12E and isMoreAbove(cps, i, n) then
                return "\196\175\204\135"
            elseif cp == 0xCC then
                return "i\204\135\204\128"
            elseif cp == 0xCD then
                return "i\204\135\204\129"
            elseif cp == 0x128 then
                return "i\204\135\204\131"
            end
        end
    end

    local function upperReplacement(lang, cps, i)
        local cp = cps[i]
        if (lang == "tr" or lang == "az") and cp == 0x69 then
            return "\196\176"
        elseif lang == "lt" and cp == 0x307 and isAfter(cps, i, isSoftDotted) then
            return ""
        end
    end

    -- Applies the locale's replacements, then the standard mapping to the result (they leave nothing the standard mapping changes).
    local function mapped(s, tag, replacement, standard)
        local lang = language(tag)
        if lang ~= "tr" and lang ~= "az" and lang ~= "lt" then
            return standard(s)
        end
        local cps, n = codePoints(s)
        local out, changed, i = {}, false, 0
        for ch in gmatch(s, UTF8_CHAR) do
            i = i + 1
            local r = replacement(lang, cps, i, n)
            if r ~= nil then
                changed = true
                out[i] = r
            else
                out[i] = ch
            end
        end
        return standard(changed and concat(out) or s)
    end

    -- String.uppercase(locale)
    function L.uppercase(s, tag)
        return mapped(s, tag, upperReplacement, C.uppercase)
    end

    -- String.lowercase(locale)
    function L.lowercase(s, tag)
        return mapped(s, tag, lowerReplacement, C.lowercase)
    end

    -- Char.titlecase(locale)
    function L.titlecase(c, tag)
        local up = L.uppercase(c, tag)
        if U.len(up) > 1 then
            if U.code(c) == 0x149 then
                return up
            end
            return Text.first(up) .. L.lowercase(Text.substring(up, 1), tag)
        end
        -- a char with a title case of its own (the digraph dž) keeps it; any other is its localized uppercase
        local title = C.titlecaseChar(c)
        return title ~= C.uppercaseChar(c) and title or up
    end
end
