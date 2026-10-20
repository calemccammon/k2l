local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local function twice(f)
    return __K2L_ReadOnlyListOf(f(), f())
end

local function sign(x)
    local described
    if x < 0 then
        described = "negative"
    elseif x == 0 then
        described = "zero"
    else
        described = "positive"
    end
    return described
end

local function main()
    print("a labeled call")
    local five = 5
    print(five + 6)
    local y = five > 3 and "big" or "small"
    print(y)
    local half = function(x)
        if (x >= 0 and x % 2 or 0 - -x % 2) ~= 0 then
            return -1
        end
        return x >= 0 and x // 2 or 0 - -x // 2
    end
    print(__K2L_Str(__K2L_ReadOnlyListOf(4, 5, 6):map(half)))
    local ____list = __K2L_ReadOnlyListOf(1, 2, 3)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____result
        do
            if it == 2 then
                ____result = 0
                goto ____inline_end
            else
                ____result = it * 10
            end
            ::____inline_end::
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local n = 0
    print(__K2L_Str(twice(function()
        n = n + 1
        if n == 1 then
            return "first"
        end
        return "then " .. n
    end)))
    local total = 0
    total = total + 3
    total = total + 1
    if total > 3 then
        print("total " .. total)
    else
        print("small")
    end
    do
        if total == 4 then
            goto ____inline_end_1
        end
        print("not reached")
        ::____inline_end_1::
    end
    print(sign(-2) .. " " .. sign(0) .. " " .. sign(9))
    local ____pairs = twice(function()
        local found = __K2L_ListOf()
        for i = 0, 3 do
            do
                for j = 0, 3 do
                    if j > i then
                        goto ____continue
                    end
                    if i == 3 then
                        goto ____break
                    end
                    if found.size > 4 then
                        return found:joinToString()
                    end
                    found:add(i .. j)
                end
            end
            ::____continue::
        end
        ::____break::
        return found:joinToString()
    end)
    print(__K2L_Str(____pairs))
end

main()
return {twice = twice, sign = sign}
