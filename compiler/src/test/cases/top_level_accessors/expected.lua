-- ==== config/settings.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf

local history = __K2L_ListOf()
local ____name_field = "default"

local function getName()
    return ____name_field
end

local function setName(value)
    history:add("name: " .. ____name_field .. " -> " .. value)
    ____name_field = value
end

local ____volume_field = 10

local function getVolume()
    return ____volume_field
end

local function setVolume(v)
    ____volume_field = v > 100 and 100 or v
    history:add("volume=" .. ____volume_field)
end

local calls = 0

local function getHits()
    return calls
end

local ____level_field = 1

local function getLevel()
    return ____level_field
end

local function setLevel(v)
    ____level_field = v
end

local function describe()
    return getName() .. "/" .. getVolume() .. "/" .. getHits()
end

local Settings = __K2L_Class("app.config.Settings")

function Settings:touch()
    calls = calls + 1
    setLevel(getLevel() + 1)
end

return {history = history, getName = getName, setName = setName, getVolume = getVolume, setVolume = setVolume, getHits = getHits, getLevel = getLevel, setLevel = setLevel, describe = describe, Settings = Settings}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local ____settings = require("config.settings")
local getLater
____exports.counter = 3

local function getNow()
    return ____exports.counter * 2
end

local log = __K2L_ListOf()
local ____total_field = 0

local function getTotal()
    return ____total_field
end

local function setTotal(value)
    log:add("total " .. ____total_field .. " -> " .. value)
    ____total_field = value
end

local ____clamped_field = 5

local function getClamped()
    return ____clamped_field < 0 and 0 or ____clamped_field
end

local function setClamped(v)
    ____clamped_field = v > 10 and 10 or v
end

local ____doubled_field = 21

local function getDoubled()
    return ____doubled_field * 2
end

local function getFake()
    return "fake" .. ____exports.counter
end

local function setFake(v)
    ____exports.counter = #v
end

local function getHidden()
    return 99
end

local ____secret_field = 1

local function getSecret()
    return ____secret_field + 100
end

local function setSecret(v)
    ____secret_field = v * 2
end

local ____nullable_field = nil

local function getNullable()
    return ____nullable_field or "none"
end

local function setNullable(value)
    ____nullable_field = value
end

local ____flag_field = false

local function getFlag()
    return ____flag_field
end

local function setFlag(v)
    ____flag_field = not v
end

local function getComputed()
    return __K2L_ReadOnlyListOf(____exports.counter, ____exports.counter + 1)
end

local function getNow__1()
    return "fun getNow"
end

local function early()
    return getLater() + 1
end

function getLater()
    return 41
end

local ____branching_field = ____exports.counter > 100 and "big" or "small"

local function getBranching()
    return ____branching_field:upper()
end

local ____lazyish_field = 0

local function getLazyish()
    ____lazyish_field = ____lazyish_field + 1
    return ____lazyish_field
end

local function setLazyish(value)
    ____lazyish_field = value
end

local function main()
    print(getNow())
    ____exports.counter = ____exports.counter + 1
    print(getNow())
    setTotal(5)
    setTotal(getTotal() + 3)
    setTotal(getTotal() + 1)
    setTotal(getTotal() + 1)
    local ____old = getTotal()
    setTotal(getTotal() - 1)
    local old = ____old
    print(old .. " " .. getTotal())
    print(__K2L_Str(log))
    setClamped(50)
    print(getClamped())
    setClamped(getClamped() - 100)
    print(getClamped())
    setClamped(7)
    setClamped(getClamped() * 2)
    print(getClamped())
    print(getDoubled())
    setFake("abcd")
    print(getFake() .. " " .. ____exports.counter)
    print(getHidden())
    setSecret(4)
    setSecret(getSecret() + 1)
    print(getSecret())
    print(__K2L_Str(getNullable()))
    setNullable("set")
    print(__K2L_Str(getNullable()))
    setFlag(true)
    print(getFlag())
    setFlag(true)
    print(getFlag())
    print(__K2L_Str(getComputed()))
    print(getNow__1())
    print(early())
    print(getBranching())
    print(getLazyish() + getLazyish())
    print(____settings.getName())
    ____settings.setName("renamed")
    print(____settings.getName())
    ____settings.setVolume(150)
    ____settings.setVolume(____settings.getVolume() + 10)
    print(____settings.getVolume())
    print(____settings.getLevel())
    print(____settings.getHits())
    print(____settings.describe())
    ____settings.Settings:touch()
    print(____settings.getHits())
    print(____settings.getLevel())
    print(__K2L_Str(____settings.history))
    local sum = getNow() + ____settings.getVolume() + ____exports.counter
    print(sum)
    local ____local = getNow() > 5 and getTotal() or getClamped()
    print(____local)
end

____exports.getNow = getNow
____exports.log = log
____exports.getTotal = getTotal
____exports.setTotal = setTotal
____exports.getClamped = getClamped
____exports.setClamped = setClamped
____exports.getDoubled = getDoubled
____exports.getFake = getFake
____exports.setFake = setFake
____exports.getNullable = getNullable
____exports.setNullable = setNullable
____exports.getFlag = getFlag
____exports.setFlag = setFlag
____exports.getComputed = getComputed
____exports.getNow__1 = getNow__1
____exports.early = early
____exports.getLater = getLater
____exports.getBranching = getBranching
____exports.getLazyish = getLazyish
____exports.setLazyish = setLazyish
main()
return ____exports
