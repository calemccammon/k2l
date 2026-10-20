local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Grid = __K2L_Class("Grid")

function Grid:____init(...)
    local rows = __K2L_ArrayOf(...)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = rows:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:toTypedArray()
    end
    self.cells = __K2L_ListWrap(____out, ____count)
    self.width = rows:get(0).size
    self.corner = rows:get(0):get(0)
end

function Grid:equals(other)
    local ____cond = getmetatable(other) == Grid
    if ____cond then
        local ____list = self.cells:zip(other.cells)
        local ____result = true
        local ____items_1, ____n_1 = ____list:____array()
        for ____i_1 = 1, ____n_1 do
            local ____it = ____items_1[____i_1]
            local ____result_1
            do
                local a, b = ____it.first, ____it.second
                ____result_1 = a:contentEquals(b)
            end
            if not ____result_1 then
                ____result = false
                break
            end
        end
        ____cond = ____result
    end
    return ____cond
end

local ____lambda_1 = function(h, row) return 31 * h + row:contentHashCode() end
function Grid:hashCode()
    return self.cells:fold(17, ____lambda_1)
end

local function total(rows)
    local ____sum = 0
    local ____items_2, ____n_2 = rows:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum = ____sum + it.size
    end
    return ____sum + rows:get(rows.size - 1):sum()
end

local function widest(...)
    local rows = __K2L_ArrayOf(...)
    local ____best
    local ____has = false
    local ____items_3, ____n_3 = rows:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        local ____key = it.size
        if not ____has or ____best < ____key then
            ____best = ____key
            ____has = true
        end
    end
    if not ____has then
        error(__K2L_NoSuchElementException.new(nil))
    end
    return ____best
end

local function main()
    print(__K2L_TypedArrayOf("[I", 1, 2, 3):contentHashCode() .. " " .. __K2L_TypedArrayOf("[I"):contentHashCode() .. " " .. __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b"):contentHashCode())
    print(__K2L_TypedArrayOf("[Z", true, false):contentHashCode() .. " " .. __K2L_TypedArrayOf("[C", "a", "b"):contentHashCode() .. " " .. __K2L_TypedArrayOf("[J", 5, 7):contentHashCode())
    print(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1), __K2L_TypedArrayOf("[I", 2, 3)):contentDeepHashCode() .. " " .. __K2L_TypedArrayOf("[[Ljava.lang.String;", __K2L_TypedArrayOf("[Ljava.lang.String;", "x"), __K2L_TypedArrayOf("[Ljava.lang.String;", "y", "z")):contentDeepHashCode())
    print(__K2L_TypedArrayOf("[I", 4, 5):contentHashCode() == __K2L_Hash(__K2L_ReadOnlyListOf(4, 5)))
    local a = __K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 3))
    local b = __K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 3))
    print(tostring(a:contentEquals(b)) .. " " .. tostring(a:contentDeepEquals(b)) .. " " .. tostring(a:contentDeepEquals(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 4)))))
    print(tostring(__K2L_TypedArrayOf("[Ljava.lang.String;", "p", nil):contentDeepEquals(__K2L_TypedArrayOf("[Ljava.lang.String;", "p", nil))) .. " " .. a:contentDeepToString())
    local g1 = Grid.new(__K2L_TypedArrayOf("[I", 1, 2, 3), __K2L_TypedArrayOf("[I", 4, 5, 6))
    local g2 = Grid.new(__K2L_TypedArrayOf("[I", 1, 2, 3), __K2L_TypedArrayOf("[I", 4, 5, 6))
    print(tostring(g1:equals(g2)) .. " " .. tostring(g1:hashCode() == g2:hashCode()) .. " " .. g1:hashCode() .. " " .. g1.width .. " " .. g1.corner)
    print(__K2L_ReadOnlySetOf(g1, g2).size .. " " .. total(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 3, 4, 5))) .. " " .. widest(__K2L_TypedArrayOf("[D", 1.0), __K2L_TypedArrayOf("[D", 2.0, 3.0)))
end

main()
return {Grid = Grid, total = total, widest = widest}
