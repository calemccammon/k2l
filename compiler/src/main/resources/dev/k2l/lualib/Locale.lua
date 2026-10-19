-- java.util.Locale as its string form, the way Locale.toString() writes it: "tr", "tr_TR", "en_US_POSIX", "az_AZ_#Latn",
-- "" for Locale.ROOT. The constants (Locale.US, ...) are these strings in the generated code; this builds and takes apart the
-- others. Only the language selects different behavior (the case rules of Turkish, Azeri and Lithuanian with
-- --strings utf16, see Utf16Locale.lua).
local __K2L_Locale = {}

do
    local L = __K2L_Locale

    local function segments(tag)
        local parts = {}
        for part in (tag .. "_"):gmatch("([^_]*)_") do
            parts[#parts + 1] = part
        end
        return parts
    end

    -- Locale(language, country, variant) and Locale.of(...): the language in lower case, the country in upper case.
    function L.of(language, country, variant, script)
        language, country, variant, script = (language or ""):lower(), (country or ""):upper(), variant or "", script or ""
        local text = language
        if country ~= "" or (language ~= "" and (variant ~= "" or script ~= "")) then
            text = text .. "_" .. country
        end
        if variant ~= "" and (language ~= "" or country ~= "") then
            text = text .. "_" .. variant
        end
        if script ~= "" and (language ~= "" or country ~= "") then
            text = text .. "_#" .. script
        end
        return text
    end

    -- Locale.forLanguageTag("tr-TR"): the language, a script (four letters), a region and variants.
    function L.forLanguageTag(tag)
        local subtags = {}
        for subtag in tag:gmatch("[^-_]+") do
            subtags[#subtags + 1] = subtag
        end
        local language = subtags[1]
        if language == nil or not language:match("^%a%a%a?%a?%a?%a?%a?%a?$") or language:lower() == "und" then
            return ""
        end
        local i, script, country, variants = 2, "", "", {}
        if subtags[i] and subtags[i]:match("^%a%a%a%a$") then
            script = subtags[i]:sub(1, 1):upper() .. subtags[i]:sub(2):lower()
            i = i + 1
        end
        if subtags[i] and (subtags[i]:match("^%a%a$") or subtags[i]:match("^%d%d%d$")) then
            country = subtags[i]
            i = i + 1
        end
        while subtags[i] and (#subtags[i] >= 5 or (#subtags[i] == 4 and subtags[i]:match("^%d"))) and #subtags[i] <= 8 do
            variants[#variants + 1] = subtags[i]
            i = i + 1
        end
        return L.of(language, country, table.concat(variants, "_"), script)
    end

    function L.language(tag)
        return segments(tag)[1]
    end

    function L.country(tag)
        local country = segments(tag)[2] or ""
        return country:sub(1, 1) == "#" and "" or country
    end

    function L.variant(tag)
        local parts, variants = segments(tag), {}
        for i = 3, #parts do
            if parts[i]:sub(1, 1) ~= "#" then
                variants[#variants + 1] = parts[i]
            end
        end
        return table.concat(variants, "_")
    end

    -- Locale.toLanguageTag(): "und" for the root locale
    function L.languageTag(tag)
        local language, country = L.language(tag), L.country(tag)
        local text = language == "" and "und" or language
        local script = tag:match("_#(%a+)$")
        if script then
            text = text .. "-" .. script
        end
        if country ~= "" then
            text = text .. "-" .. country
        end
        local variant = L.variant(tag)
        if variant ~= "" then
            text = text .. "-" .. variant:gsub("_", "-")
        end
        return text
    end
end
