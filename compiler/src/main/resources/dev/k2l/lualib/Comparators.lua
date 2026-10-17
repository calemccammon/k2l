-- requires: Compare
-- Comparators are Lua functions (a, b) -> Int.

local function __K2L_CompareBy(...)
    local selectors = {...}
    return function(a, b)
        for _, selector in ipairs(selectors) do
            local c = __K2L_Compare(selector(a), selector(b))
            if c ~= 0 then
                return c
            end
        end
        return 0
    end
end

local function __K2L_CompareByDescending(selector)
    return function(a, b)
        return __K2L_Compare(selector(b), selector(a))
    end
end

local function __K2L_ThenBy(comparator, selector)
    return function(a, b)
        local c = comparator(a, b)
        if c ~= 0 then
            return c
        end
        return __K2L_Compare(selector(a), selector(b))
    end
end

local function __K2L_ThenByDescending(comparator, selector)
    return function(a, b)
        local c = comparator(a, b)
        if c ~= 0 then
            return c
        end
        return __K2L_Compare(selector(b), selector(a))
    end
end

local function __K2L_ReverseComparator(comparator)
    return function(a, b)
        return comparator(b, a)
    end
end

local function __K2L_NaturalOrder(a, b)
    return __K2L_Compare(a, b)
end

local function __K2L_ReverseOrder(a, b)
    return __K2L_Compare(b, a)
end
