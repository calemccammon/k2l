local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Duration = ____lualib.__K2L_Duration
local __K2L_DurationUnit = ____lualib.__K2L_DurationUnit
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local Timeout = __K2L_Class("Timeout")
__K2L_ClassInfo(Timeout, "Timeout", "Timeout", "class")

function Timeout:____init(name, value)
    self.name = name
    self.value = value
end

function Timeout.new(name, value)
    return setmetatable({name = name, value = value}, Timeout)
end

function Timeout:toString()
    return "Timeout(name=" .. self.name .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Timeout:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.value) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Timeout:equals(other)
    return getmetatable(other) == Timeout and self.name == other.name and __K2L_Equals(self.value, other.value)
end

local ____lambda_1 = function()
    return __K2L_Duration.parse("1x", false, false)
end
local ____lambda_2 = function()
    return __K2L_Duration.parse("1m 1h", false, false)
end
local ____lambda_3 = function() return __K2L_Duration.parse("", false, false) end
local ____lambda_4 = function()
    return __K2L_Duration.parse("1.5h 30m", false, false)
end
local ____lambda_5 = function()
    return __K2L_Duration.parse("1h", true, false)
end
local ____lambda_6 = function()
    return __K2L_Duration.parse("P1Y", true, false)
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.parse("10s", false, true), __K2L_Duration.parse("ten seconds", false, true), __K2L_Duration.parse("1h1m", false, true))
end
local ____lambda_8 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.parse("PT2M", true, true), __K2L_Duration.parse("2m", true, true))
end
local ____lambda_9 = function(it) return it.value end
local ____lambda_10 = function(acc, x) return acc:plus(x.value) end
local function main()
    t("default", function()
        local ____list = __K2L_ReadOnlyListOf("1h 30m", "45s", "1.5s", "250ms", "2d 3h", "1d 2h 3m 4.005s", "0s", "12us", "7ns")
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = __K2L_Duration.parse(it, false, false)
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    t("signs", function()
        local ____list_1 = __K2L_ReadOnlyListOf("-5m", "+5m", "-(1h 30m)", "-1.25h")
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = __K2L_Duration.parse(it, false, false)
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)
    t("infinity", function()
        local ____list_2 = __K2L_ReadOnlyListOf("Infinity", "-Infinity", "INFINITY")
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_2, ____n_2 = ____list_2:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = __K2L_Duration.parse(it, false, false)
        end
        return __K2L_ListWrap(____out_2, ____count_2)
    end)
    t("iso via parse", function()
        local ____list_3 = __K2L_ReadOnlyListOf("PT1H30M", "P2DT3H", "PT0.5S", "-PT5M", "PT-5M", "P1D")
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_3, ____n_3 = ____list_3:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = __K2L_Duration.parse(it, false, false)
        end
        return __K2L_ListWrap(____out_3, ____count_3)
    end)
    t("parseIsoString", function()
        local ____list_4 = __K2L_ReadOnlyListOf("PT36H", "PT1.123456789S", "PT90M", "P1DT1S", "PT0S")
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_4, ____n_4 = ____list_4:____array()
        for ____i_4 = 1, ____n_4 do
            local it = ____items_4[____i_4]
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = __K2L_Duration.parse(it, true, false)
        end
        return __K2L_ListWrap(____out_4, ____count_4)
    end)
    t("round trips", function()
        local ____list_5 = __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(90, __K2L_DurationUnit.MINUTES), __K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(26, __K2L_DurationUnit.HOURS):plus(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.MILLISECONDS)))
        local ____result_1 = true
        local ____items_5, ____n_5 = ____list_5:____array()
        for ____i_5 = 1, ____n_5 do
            local it = ____items_5[____i_5]
            if not (__K2L_Equals(__K2L_Duration.parse(__K2L_Str(it), false, false), it) and __K2L_Equals(__K2L_Duration.parse(it:toIsoString(), true, false), it)) then
                ____result_1 = false
                break
            end
        end
        return ____result_1
    end)
    t("bad default", ____lambda_1)
    t("bad order", ____lambda_2)
    t("bad empty", ____lambda_3)
    t("bad fraction", ____lambda_4)
    t("bad iso", ____lambda_5)
    t("bad iso unit", ____lambda_6)
    t("parseOrNull", ____lambda_7)
    t("parseIsoStringOrNull", ____lambda_8)
    local config = "connect=5s\nread=1m 30s\nidle=PT10M\nretry=oops"
    local ____list_6 = __K2L_StringLines(config)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_6, ____n_6 = ____list_6:____array()
    for ____i_6 = 1, ____n_6 do
        local line = ____items_6[____i_6]
        local ____result_2
        do
            local ____destructured = __K2L_StringSplit(line, "=")
            local name, value = ____destructured[1], ____destructured[2]
            ____result_2 = Timeout.new(name, __K2L_Duration.parse(value, false, true) or __K2L_Duration.ZERO)
        end
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = ____result_2
    end
    local timeouts = __K2L_ListWrap(____out_5, ____count_5)
    t("config", function() return timeouts end)
    t("longest", function() return timeouts:maxBy(____lambda_9).name end)
    t("total", function()
        return timeouts:fold(__K2L_Duration.ZERO, ____lambda_10)
    end)
end

__K2L_DeepMain(main)
return {t = t, Timeout = Timeout}
