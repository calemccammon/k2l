    -- The tables are decoded the first time they are used.
    local decodedSets, decodedMaps, decodedSpecial = {}, {}, {}
    local floor = math.floor

    local function decodeSet(name)
        local starts, ends, n = {}, {}, 0
        local pos, inside = 0, false
        for run in sets[name]:gmatch("[^,]+") do
            local len = tonumber(run, 36)
            if inside then
                n = n + 1
                starts[n] = pos
                ends[n] = pos + len - 1
            end
            pos = pos + len
            inside = not inside
        end
        local set = {starts = starts, ends = ends, n = n}
        decodedSets[name] = set
        return set
    end

    -- The index of the range of the set holding cp, or nil, by binary search.
    local function search(set, cp)
        local starts, ends = set.starts, set.ends
        local lo, hi = 1, set.n
        while lo <= hi do
            local mid = floor((lo + hi) / 2)
            if cp < starts[mid] then
                hi = mid - 1
            elseif cp > ends[mid] then
                lo = mid + 1
            else
                return mid
            end
        end
        return nil
    end

    -- The index of the range of the set holding cp, or nil; the answers for Latin-1 are a table made with the set.
    local function find(name, cp)
        local set = decodedSets[name] or decodeSet(name)
        if cp < 256 then
            local latin = set.latin
            if latin == nil then
                latin = {}
                for c = 0, 255 do
                    latin[c] = search(set, c) or false
                end
                set.latin = latin
            end
            local i = latin[cp]
            if i then
                return i, set.starts
            end
            return nil
        end
        local i = search(set, cp)
        if i then
            return i, set.starts
        end
        return nil
    end

    local function decodeMap(name)
        local map = {}
        for run in maps[name]:gmatch("[^;]+") do
            local start, count, stride, delta = run:match("^(%w+),(%d+),(%d+),(-?%d+)$")
            start, count, stride, delta = tonumber(start, 36), tonumber(count), tonumber(stride), tonumber(delta)
            for i = 0, count - 1 do
                local cp = start + i * stride
                map[cp] = cp + delta
            end
        end
        decodedMaps[name] = map
        return map
    end

    local function decodeSpecial(name)
        local map = {}
        for entry in special[name]:gmatch("[^;]+") do
            local cp, rest = entry:match("^(%x+):(.*)$")
            local list = {}
            for part in rest:gmatch("%x+") do
                list[#list + 1] = tonumber(part, 16)
            end
            map[tonumber(cp, 16)] = list
        end
        decodedSpecial[name] = map
        return map
    end

    function __K2L_Unicode.isLetter(cp) return find("letter", cp) ~= nil end
    function __K2L_Unicode.isAlphabetic(cp) return find("letter", cp) ~= nil or find("alphabeticNonLetter", cp) ~= nil end
    function __K2L_Unicode.isDigit(cp) return find("digit", cp) ~= nil end
    function __K2L_Unicode.isUpper(cp) return find("upper", cp) ~= nil end
    function __K2L_Unicode.isLower(cp) return find("lower", cp) ~= nil end
    function __K2L_Unicode.isTitle(cp) return find("title", cp) ~= nil end
    -- Kotlin's isWhitespace: Character.isWhitespace or Character.isSpaceChar
    function __K2L_Unicode.isSpace(cp) return find("space", cp) ~= nil end
    -- A "cased" letter, as the final-sigma rule of String.lowercase() sees it.
    function __K2L_Unicode.isCased(cp) return find("cased", cp) ~= nil end
    function __K2L_Unicode.isMark(cp) return find("mark", cp) ~= nil end
    -- The general categories P (Pc, Pd, Ps, Pe, Pi, Pf, Po) and S (Sm, Sc, Sk, So)
    function __K2L_Unicode.isPunctuation(cp) return find("punct", cp) ~= nil end
    function __K2L_Unicode.isSymbol(cp) return find("symbol", cp) ~= nil end

    -- The value of a decimal digit (Nd blocks start at a zero digit), or nil.
    function __K2L_Unicode.digitValue(cp)
        local i, starts = find("digit", cp)
        return i and (cp - starts[i]) % 10 or nil
    end

    function __K2L_Unicode.upper(cp)
        return (decodedMaps.upper or decodeMap("upper"))[cp] or cp
    end

    function __K2L_Unicode.lower(cp)
        return (decodedMaps.lower or decodeMap("lower"))[cp] or cp
    end

    function __K2L_Unicode.title(cp)
        return (decodedMaps.title or decodeMap("title"))[cp] or cp
    end

    -- The full uppercase mapping (String.uppercase()) when it is not a single code point: a list of code points, or nil.
    function __K2L_Unicode.specialUpper(cp)
        return (decodedSpecial.upper or decodeSpecial("upper"))[cp]
    end

    function __K2L_Unicode.specialLower(cp)
        return (decodedSpecial.lower or decodeSpecial("lower"))[cp]
    end
