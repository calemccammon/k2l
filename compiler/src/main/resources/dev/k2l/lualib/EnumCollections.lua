-- requires: Class, Exceptions, Collections, Str
-- java.util.EnumMap and EnumSet: a TreeMap and a TreeSet in the natural order of enum entries (their ordinals), with
-- the JDK's classes. A set remembers the entries of its enum class (`____universe`) for allOf and complementOf.
local __K2L_EnumMap = __K2L_Class("java.util.EnumMap", __K2L_SortedMap)
local __K2L_EnumSet = __K2L_Class("java.util.RegularEnumSet", __K2L_SortedSet)
local __K2L_EnumSets = {}
-- they inherit the methods of TreeMap and TreeSet but are not TreeMaps or SortedSets for `is` (see InstanceOf)
__K2L_EnumMap.____super = __K2L_Map
__K2L_EnumSet.____super = __K2L_Set

do

-- the entries of the enum class of a `Class` object (`E::class.java`)
local function entriesOf(class)
    return class.____kotlin.____cls.____values
end

local function isClass(value)
    return type(value) == "table" and rawget(value, "____kotlin") ~= nil
end

-- EnumMap(Class), EnumMap(EnumMap) or EnumMap(Map), which must not be empty unless it is an EnumMap
function __K2L_EnumMap:____init(classOrMap)
    __K2L_SortedMap.____init(self)
    if classOrMap ~= nil and not isClass(classOrMap) then
        if getmetatable(classOrMap) ~= __K2L_EnumMap and classOrMap.size == 0 then
            error(__K2L_IllegalArgumentException.new("Specified map is empty"))
        end
        self:putAll(classOrMap)
    end
end

local function newSet(universe)
    local set = __K2L_EnumSet.new()
    set.____universe = universe
    return set
end

local S = __K2L_EnumSets

function S.noneOf(class)
    return newSet(entriesOf(class))
end

function S.allOf(class)
    local universe = entriesOf(class)
    local set = newSet(universe)
    for i = 1, #universe do
        set:add(universe[i])
    end
    return set
end

function S.of(first, ...)
    local set = newSet(first.____values)
    set:add(first)
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end

function S.copyOf(elements)
    if getmetatable(elements) == __K2L_EnumSet then
        local set = newSet(elements.____universe)
        set:addAll(elements)
        return set
    end
    if elements.size == 0 then
        error(__K2L_IllegalArgumentException.new("Collection is empty"))
    end
    local set = newSet(elements:first().____values)
    set:addAll(elements)
    return set
end

function S.range(from, to)
    if from.ordinal > to.ordinal then
        error(__K2L_IllegalArgumentException.new(__K2L_Str(from) .. " > " .. __K2L_Str(to)))
    end
    local universe = from.____values
    local set = newSet(universe)
    for i = from.ordinal + 1, to.ordinal + 1 do
        set:add(universe[i])
    end
    return set
end

function S.complementOf(other)
    local universe = other.____universe
    local set = newSet(universe)
    for i = 1, #universe do
        if not other:contains(universe[i]) then
            set:add(universe[i])
        end
    end
    return set
end

end
