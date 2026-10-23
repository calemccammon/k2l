local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text

local Fx = __K2L_Class("Fx")
Fx.____comparable = true

function Fx.new(raw)
    return setmetatable({raw = raw}, Fx)
end

function Fx:plus(o)
    return Fx.new(self.raw + o.raw)
end

function Fx:minus(o)
    return Fx.new(self.raw - o.raw)
end

function Fx:times(o)
    return Fx.new(self.raw * o.raw // (1 << 16))
end

function Fx:div(o)
    return Fx.new((self.raw << 16) // o.raw)
end

function Fx:unaryMinus()
    return Fx.new(-self.raw)
end

function Fx:compareTo(other)
    return __K2L_Compare(self.raw, other.raw)
end

function Fx:toDouble()
    return self.raw / 65536.0
end

function Fx:floor()
    return self.raw // 65536
end

function Fx:round()
    return (self.raw + 32768) // 65536
end

function Fx:sqrt()
    if self.raw <= 0 then
        return Fx.new(0)
    end
    local x = Fx.new(self.raw > 65536 and self.raw // 2 or 65536)
    for it = 0, 19 do
        x = Fx.new((x.raw + self:div(x).raw) // 2)
    end
    return x
end

function Fx:toString()
    local sign = self.raw < 0 and "-" or ""
    local a = math.abs(self.raw)
    local whole = a // (1 << 16)
    local frac = ((a & 65535) * 10000 + 32768) // (1 << 16)
    return frac >= 10000 and sign .. whole + 1 .. ".0000" or sign .. whole .. "." .. __K2L_StringPadStart(tostring(frac), 4, "0")
end

__K2L_DataClass(Fx, {"raw"})
Fx.____companion = true

function Fx:of(i)
    return Fx.new(((i << 16) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
end

function Fx:of__1(d)
    return Fx.new(__K2L_Num.round(d * 65536.0))
end

function Fx:____initCompanion()
    self.FRAC = 16
    self.ONE = 65536
    self.HALF = 32768
    self.ONE_D = 65536.0
end

Fx:____initCompanion()
local Money = __K2L_Class("Money")

function Money:parse(s)
    local negative = __K2L_StringStartsWith(s, "-")
    local body = __K2L_Text.removePrefix(s, "-")
    local whole = __K2L_StringToInt(__K2L_Text.substringBefore(body, "."), nil, true)
    local cents = __K2L_StringToInt(__K2L_Text.take(__K2L_StringPadEnd(__K2L_Text.substringAfter(body, ".", "0"), 2, "0"), 2), nil, true)
    local v = whole * 100 + cents
    return negative and -v or v
end

function Money:format(cents)
    local sign = cents < 0 and "-" or ""
    local a = math.abs(cents)
    local grouped = __K2L_Text.chunked(tostring(a // 100):reverse(), 3):joinToString(","):reverse()
    return sign .. "$" .. grouped .. "." .. __K2L_StringPadStart(tostring(a % 100), 2, "0")
end

function Money:scale(value, numerator, denominator)
    local product = value * numerator
    local q = product // denominator
    local r = product % denominator
    local twice = math.abs(r) * 2
    if twice > denominator then
        return q + self:sign(nil, product)
    elseif twice < denominator then
        return q
    elseif q % 2 == 0 then
        return q
    else
        return q + self:sign(nil, product)
    end
end

function Money:sign(____this, v)
    return v < 0 and -1 or 1
end

local function saturatingAdd(a, b)
    local r = a + b
    return __K2L_Num.coerceIn(r, -2147483648, 2147483647)
end

local function overflow()
    print("-- overflow")
    print(2147483647 + 1)
    print(-2147483648 - 1)
    print(2147483647 * 2)
    print(65536 * 65536)
    print(46341 * 46341)
    print(-(-2147483648))
    print(-2147483648 // -1)
    print(-2147483648 % -1)
    print(math.abs(-2147483648))
    print(saturatingAdd(2147483647, 5))
    print(saturatingAdd(-2147483648, -5))
    print(2147483647 + 1)
    print(4000000000)
    print(-1)
    print(4294967297)
    print(3000000000)
    print(200)
    print(-129)
    local h = 17
    for ____i = 1, #"fixed point" do
        local c = __K2L_StrByte("fixed point", ____i)
        h = 31 * h + c
    end
    print("hash " .. h)
    local lcg = 12345
    for it = 0, 4 do
        lcg = lcg * 1103515245 + 12345
    end
    print("lcg " .. lcg .. " " .. ((lcg & 0xFFFFFFFF) >> 16) .. " " .. lcg // 65536)
end

local function q16()
    print("-- Q16.16")
    local a = Fx:of__1(3.25)
    local b = Fx:of__1(-1.5)
    print(__K2L_Str(a) .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(a:plus(b)) .. " " .. __K2L_Str(a:minus(b)) .. " " .. __K2L_Str(a:times(b)) .. " " .. __K2L_Str(a:div(b)) .. " " .. __K2L_Str(a:unaryMinus()))
    print("raw " .. a.raw .. " " .. b.raw .. " " .. a:times(b).raw .. " " .. a:div(b).raw)
    print("floor " .. b:floor() .. " round " .. b:round() .. " " .. Fx:of__1(2.5):round() .. " " .. Fx:of__1(-2.5):round())
    print("sqrt " .. __K2L_Str(Fx:of(2):sqrt()) .. " " .. __K2L_Str(Fx:of(100):sqrt()) .. " " .. __K2L_Str(Fx:of__1(0.25):sqrt()))
    print("toDouble " .. Fx:of__1(1.0 / 3):toDouble() .. " " .. Fx.new(1):toDouble() .. " " .. Fx.new(-1):toDouble())
    print("max " .. __K2L_Str(Fx.new(2147483647)) .. " min " .. __K2L_Str(Fx.new(-2147483648)))
    print("wrap " .. __K2L_Str(Fx:of(30000):plus(Fx:of(30000))) .. " " .. __K2L_Str(Fx:of(200):times(Fx:of(200))))
    local values = __K2L_ListOf(Fx:of__1(1.75), Fx:of__1(-0.5), Fx:of__1(0.0), Fx:of__1(12.125))
    print("sorted " .. __K2L_Str(values:sorted()) .. " max " .. __K2L_Str(values:max()))
    local y = Fx:of(100)
    local v = Fx:of(0)
    local g = Fx:of__1(-9.81)
    local dt = Fx:of__1(1.0 / 60)
    local frames = 0
    while __K2L_Compare(y, Fx:of(0)) > 0 do
        v = v:plus(g:times(dt))
        y = y:plus(v:times(dt))
        frames = frames + 1
    end
    print("landed after " .. frames .. " frames at y=" .. __K2L_Str(y) .. " v=" .. __K2L_Str(v) .. " raw=" .. y.raw .. "," .. v.raw)
end

local function money()
    print("-- money")
    local prices = __K2L_ListOf("19.99", "0.05", "1234567.8", "-42.10", "7")
    local ____receiver = Money
    local cents = prices:map(function(...) return ____receiver:parse(...) end)
    print(__K2L_Str(cents))
    local ____receiver_1 = Money
    print(__K2L_Str(cents:map(function(...) return ____receiver_1:format(...) end)))
    local total = cents:sum()
    print("total " .. Money:format(total))
    local ____list = __K2L_ListOf(825, 1000, 1250)
    for ____i_2 = 1, ____list.size do
        local rate = ____list[____i_2]
        local ____sum = 0
        local ____items, ____n = cents:____array()
        for ____i_1 = 1, ____n do
            local it = ____items[____i_1]
            ____sum = ____sum + Money:scale(it, rate, 10000)
        end
        local tax = ____sum
        print("tax at " .. rate / 100.0 .. "%: " .. Money:format(tax))
    end
    local ____list_1 = __K2L_ListOf(5, 15, 25, -5, -15, 1, 3)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        ____count = ____count + 1
        ____out[____count] = Money:scale(it, 1, 10)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local split = Money:scale(10000, 1, 3)
    print("split $100 three ways: " .. Money:format(split) .. " x3 + " .. Money:format(10000 - split * 3))
    local balance = Money:parse("1000.00")
    for it = 0, 11 do
        balance = balance + Money:scale(balance, 5, 1200)
    end
    print("after a year at 5%: " .. Money:format(balance))
    local big = 92233720368547
    print("big " .. Money:format(big) .. " " .. Money:format(-big))
end

local function main()
    overflow()
    q16()
    money()
end

__K2L_RunMain(main)
return {Fx = Fx, Money = Money, saturatingAdd = saturatingAdd, overflow = overflow, q16 = q16, money = money}
