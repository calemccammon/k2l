local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local function show(label, x)
    print(label .. " " .. __K2L_Str(x) .. " " .. __K2L_Str(1.0 / x))
end

local Holder = __K2L_Class("Holder")

function Holder:____init(value)
    self.value = value
end

function Holder.new(value)
    return setmetatable({value = value}, Holder)
end

local function main()
    local inputs = __K2L_ReadOnlyListOf(0.0, -0.0, -0.4, -0.5, -0.6, 0.4, 0.5, -1.5, 2.5, 0.0 / 0.0, math.huge, -math.huge)
    local ____mod = inputs.____modCount
    for ____i = 1, inputs.size do
        local x = inputs[____i]
        print("x=" .. __K2L_Str(x))
        show("  floor", x == 0 and x * 1.0 or math.floor(x) + 0.0)
        show("  ceil", __K2L_Num.ceil(x))
        show("  round", __K2L_Num.round(x))
        show("  truncate", __K2L_Num.truncate(x))
        show("  abs", math.abs(x))
        show("  absoluteValue", math.abs(x))
        show("  sign", __K2L_Num.signDouble(x))
        show("  .sign", __K2L_Num.signDouble(x))
        show("  withSign(-1)", __K2L_Bits.withSign(x, -1.0))
        show("  withSign(-0.0)", __K2L_Bits.withSign(x, -0.0))
        show("  withSign(0.0)", __K2L_Bits.withSign(x, 0.0))
        show("  Math.floor", x == 0 and x * 1.0 or math.floor(x) + 0.0)
        show("  Math.ceil", __K2L_Num.ceil(x))
        show("  Math.rint", __K2L_Num.round(x))
        show("  Math.abs", math.abs(x))
        show("  Math.signum", __K2L_Num.signDouble(x))
        show("  Math.copySign", __K2L_Bits.withSign(1.0, x))
        if x == x and not __K2L_Num.isInfinite(x) then
            print("  roundToInt " .. __K2L_Num.roundToInt(x) .. " roundToLong " .. __K2L_Num.roundToLong(x) .. " Math.round " .. __K2L_Num.roundToLong(x) .. " toInt " .. __K2L_DoubleToInt(x))
        end
        if inputs.____modCount ~= ____mod and inputs:____comodified(____i) then
            break
        end
    end
    local h = Holder.new(-0.0)
    show("floor of field", h.value == 0 and h.value * 1.0 or math.floor(h.value) + 0.0)
    show("floor of expression", __K2L_Num.floor(h.value * 1.0))
    show("floor of -0.25", __K2L_Num.floor(__K2L_SingletonListOf(-0.25):get(0)))
    local ____list = __K2L_ReadOnlyListOf(-0.0 == 0 and -0.0 * 1.0 or math.floor(-0.0) + 0.0, __K2L_Num.ceil(-0.5))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = 1.0 / it
    end
    print("floor in a list: " .. __K2L_Str(__K2L_ListWrap(____out, ____count)))
end

__K2L_Main(main)
return {show = show, Holder = Holder}
