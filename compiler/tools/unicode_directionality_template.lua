    -- The runs are decoded the first time a non-ASCII character's directionality is asked for: the first code point of
    -- each run, and its Character.getDirectionality value.
    local LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWX"
    local starts, values, n
    local floor = math.floor

    local function decode()
        starts, values, n = {}, {}, 0
        local cp = 0
        for len, letter in runs:gmatch("([0-9a-z]*)([^0-9a-z])") do
            n = n + 1
            starts[n] = cp
            values[n] = LETTERS:find(letter, 1, true) - 2
            cp = cp + (len == "" and 1 or tonumber(len, 36))
        end
    end

    -- Character.getDirectionality(cp): the value of the last run starting at or before cp, by binary search
    __K2L_CharDirectionality.____unicode = function(cp)
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
        return values[lo]
    end
