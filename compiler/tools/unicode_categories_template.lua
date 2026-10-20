    -- The runs are decoded the first time a regex tests a non-ASCII character against a category: the first code point
    -- of each run, and its Character.getType value.
    local starts, types, n
    local floor = math.floor

    local function decode()
        starts, types, n = {}, {}, 0
        local cp = 0
        for len, letter in runs:gmatch("([0-9a-z]*)([^0-9a-z])") do
            n = n + 1
            starts[n] = cp
            types[n] = __K2L_Regex.____categoryLetters:find(letter, 1, true) - 1
            cp = cp + (len == "" and 1 or tonumber(len, 36))
        end
    end

    -- Character.getType(cp): the type of the last run starting at or before cp, by binary search
    __K2L_Regex.____category = function(cp)
        if starts == nil then
            decode()
        end
        local lo, hi = 1, n
        while lo < hi do
            local mid = floor((lo + hi + 1) / 2)
            if starts[mid] <= cp then
                lo = mid
            else
                hi = mid - 1
            end
        end
        return types[lo]
    end
