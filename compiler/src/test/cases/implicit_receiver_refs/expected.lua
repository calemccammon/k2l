local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local Util = __K2L_Class("Util")

function Util:____init()
    self.calls = 0
end

function Util:twice(x)
    self.calls = self.calls + 1
    return x * 2
end

function Util:all(xs)
    return xs:map(function(...) return self:twice(...) end)
end

function Util:counter()
    return __K2L_PropertyRef.new("calls", "/Util.calls", function() return self.calls end, function(value)
        self.calls = value
    end, self)
end

Util:____init()
local Scaler = __K2L_Class("Scaler")

function Scaler:____init(k)
    self.k = k
    self.total = 0
end

function Scaler:scale(x)
    local ____value = x * self.k
    self.total = self.total + ____value
    return ____value
end

function Scaler:scaleAll(xs)
    return xs:map(function(...) return self:scale(...) end)
end

function Scaler:scaleAllThis(xs)
    return xs:map(function(...) return self:scale(...) end)
end

function Scaler:totalRef()
    return __K2L_PropertyRef.new("total", "/Scaler.total", function() return self.total end, function(value)
        self.total = value
    end, self)
end

function Scaler:kRef()
    return __K2L_PropertyRef.new("k", "k@412", function() return self.k end, nil, self)
end

Scaler.Report = __K2L_Class("Scaler$Report")

function Scaler.Report:____init(____outer)
    self.____outer = ____outer
end

function Scaler.Report:lines(xs)
    return xs:map(function(...) return self.____outer:scale(...) end):map(function(...) return self:format(...) end)
end

function Scaler.Report:format(x)
    return "<" .. x .. ">"
end

function Scaler:parse(s)
    return Scaler.new(__K2L_StringToInt(s))
end

function Scaler:parseAll(xs)
    return xs:map(function(...) return self:parse(...) end):map(function(it) return it.k end)
end

local function main()
    print(__K2L_Str(Util:all(__K2L_ReadOnlyListOf(1, 2))))
    local ____arg = __K2L_ReadOnlyListOf(3, 4)
    local ____receiver = Util
    print(__K2L_Str(____arg:map(function(...) return ____receiver:twice(...) end)))
    print(Util:counter():get() .. " " .. Util:counter().name)
    local s = Scaler.new(3)
    print(__K2L_Str(s:scaleAll(__K2L_ReadOnlyListOf(1, 2))) .. " " .. __K2L_Str(s:scaleAllThis(__K2L_SingletonListOf(5))))
    local ref = s:totalRef()
    print(ref:get() .. " " .. ref.name)
    ref:set(100)
    print(s.total .. " " .. s:kRef():get())
    print(__K2L_Str(Scaler.Report.new(s):lines(__K2L_ReadOnlyListOf(1, 10))))
    print(__K2L_Str(Scaler:parseAll(__K2L_ReadOnlyListOf("7", "8"))))
    local ____arg_1 = __K2L_SingletonListOf("9")
    local ____receiver_1 = Scaler
    print(__K2L_Str(____arg_1:map(function(...) return ____receiver_1:parse(...) end):map(function(it) return it.k end)))
    local ____value_1 = Scaler.new(10)
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2):map(function(...) return ____value_1:scale(...) end)))
end

main()
return {Util = Util, Scaler = Scaler}
