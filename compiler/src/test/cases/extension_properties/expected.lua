-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit

local ____exports = {}
local ____ext = require("util.ext")

local function getWordCount(self)
    return __K2L_StringSplit(self, " ").size
end

local function getSquared(____this)
    return ____this * ____this
end

local function getIsEven(____this_1)
    return math.fmod(____this_1, 2) == 0
end

local function getSize2(____this_2)
    return #____this_2 * 2
end

local function getSize2__1(____this_3)
    return ____this_3.size * 2
end

local function getTwice()
    return 2
end

local function getTwice__1(____this_4)
    return ____this_4 .. ____this_4
end

local function getTwice__2(x)
    return x * 2
end

local function getSecond(____this_5)
    return ____this_5[2]
end

local function getPenultimate(____this_6)
    return ____this_6.size >= 2 and ____this_6[____this_6.size - 2 + 1] or nil
end

local function getOrDash(____this_7)
    return ____this_7 or "-"
end

local function getSafeLength(____this_8)
    return ____this_8 and #____this_8 or -1
end

local Box = __K2L_Class("Box")

function Box:____init(value, name)
    self.value = value
    self.name = name
end

local function getDoubled(____this_9)
    return ____this_9.value * 2
end

local function setDoubled(____this_9, v)
    ____this_9.value = __K2L_IDiv(v, 2)
end

local function getLabel(____this_10)
    return ____this_10.name .. "=" .. ____this_10.value
end

local function getSign(____this_11)
    if ____this_11 < 0 then
        return "negative"
    end
    if ____this_11 == 0 then
        return "zero"
    end
    return "positive"
end

____exports.counter = 0

local function getTracked(____this_12)
    return ____this_12 + ____exports.counter
end

local function setTracked(____this_12, v)
    ____exports.counter = ____exports.counter + v
end

local function describe(____this_13)
    return getLabel(____this_13) .. " doubled=" .. getDoubled(____this_13)
end

local function makeBox()
    print("makeBox")
    return Box.new(10, "made")
end

local function main()
    print(____ext.getLastChar("hello"))
    print(getWordCount("a b c"))
    print(getSquared(7))
    print(getIsEven(4))
    print(getIsEven(3))
    print(getSize2("abc"))
    print(getSize2__1(__K2L_ListOf(1, 2, 3)))
    print(getTwice__1("ab"))
    print(getTwice())
    print(getTwice__2(5))
    print(getSecond(__K2L_ListOf("x", "y", "z")))
    print(__K2L_Str(getPenultimate(__K2L_ListOf(1, 2, 3))))
    print(__K2L_Str(getPenultimate(__K2L_ListOf(1))))
    local missing = nil
    print(getOrDash(missing))
    print(getOrDash("here"))
    print(getSafeLength(missing))
    print(getSafeLength("four"))
    local b = Box.new(5, "b")
    print(getDoubled(b))
    setDoubled(b, 20)
    print(b.value)
    setDoubled(b, getDoubled(b) + 4)
    print(b.value)
    setDoubled(b, getDoubled(b) + 1)
    print(b.value)
    print(describe(b))
    local ____object = makeBox()
    setDoubled(____object, getDoubled(____object) + 2)
    local made = makeBox()
    setDoubled(made, getDoubled(made) * 3)
    print(made.value)
    local nb = nil
    print(__K2L_Str(nb and getDoubled(nb)))
    print(__K2L_Str(nb and getLabel(nb)))
    local sb = Box.new(1, "s")
    print(__K2L_Str(sb and getDoubled(sb)))
    local ____receiver = sb and getLabel(sb)
    print(__K2L_Str(____receiver and #____receiver))
    print(getSign(-5))
    print(getSign(0))
    print(getSign(9))
    print(getTracked(1))
    setTracked(5, 3)
    print(____exports.counter)
    print(getTracked(1))
    print(____ext.getLastChar("kotlin"))
    local c = ____ext.Counter.new(4)
    print(____ext.getDouble(c))
    ____ext.setDouble(c, 30)
    print(c.count)
    ____ext.setDouble(c, ____ext.getDouble(c) + 2)
    print(c.count)
    local numbers = __K2L_ListOf(1, 2, 3)
    print(____ext.getHead(numbers))
    ____ext.setHead(numbers, 10)
    ____ext.setHead(numbers, ____ext.getHead(numbers) + 5)
    print(__K2L_Str(numbers))
end

____exports.getWordCount = getWordCount
____exports.getSquared = getSquared
____exports.getIsEven = getIsEven
____exports.getSize2 = getSize2
____exports.getSize2__1 = getSize2__1
____exports.getTwice = getTwice
____exports.getTwice__1 = getTwice__1
____exports.getTwice__2 = getTwice__2
____exports.getSecond = getSecond
____exports.getPenultimate = getPenultimate
____exports.getOrDash = getOrDash
____exports.getSafeLength = getSafeLength
____exports.Box = Box
____exports.getDoubled = getDoubled
____exports.setDoubled = setDoubled
____exports.getLabel = getLabel
____exports.getSign = getSign
____exports.getTracked = getTracked
____exports.setTracked = setTracked
____exports.describe = describe
____exports.makeBox = makeBox
main()
return ____exports
-- ==== util/ext.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IDiv = ____lualib.__K2L_IDiv

local function getLastChar(self)
    return self:sub(#self - 1 + 1, #self - 1 + 1)
end

local function getHead(____this)
    return ____this[1]
end

local function setHead(____this, value)
    ____this[1] = value
end

local Counter = __K2L_Class("Counter")

function Counter:____init(count)
    self.count = count
end

local function getDouble(____this_1)
    return ____this_1.count * 2
end

local function setDouble(____this_1, value)
    ____this_1.count = __K2L_IDiv(value, 2)
end

return {getLastChar = getLastChar, getHead = getHead, setHead = setHead, Counter = Counter, getDouble = getDouble, setDouble = setDouble}
