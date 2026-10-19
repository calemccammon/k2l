local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Grid = __K2L_Class("Grid")

function Grid:____init(...)
    local rows = __K2L_ArrayOf(...)
    self.cells = rows:map(function(it) return it:toTypedArray() end)
    self.width = rows:get(0).size
    self.corner = rows:get(0):get(0)
end

function Grid:equals(other)
    return __K2L_InstanceOf(other, Grid) and self.cells:zip(other.cells):all(function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return a:contentEquals(b)
    end)
end

function Grid:hashCode()
    return self.cells:fold(17, function(h, row) return 31 * h + row:contentHashCode() end)
end

local function total(rows)
    return rows:sumOf(function(it) return it.size end) + rows:get(rows.size - 1):sum()
end

local function widest(...)
    local rows = __K2L_ArrayOf(...)
    return rows:maxOf(function(it) return it.size end)
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
