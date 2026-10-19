local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Str = ____lualib.__K2L_Str

local Color = __K2L_Class("Color")

function Color:____init1(name, ordinal)
    self.name = name
    self.ordinal = ordinal
    self.weight = 1
    self.code = "none"
end

function Color.new1(name, ordinal)
    local self = setmetatable({}, Color)
    self:____init1(name, ordinal)
    return self
end

function Color:____init2(name, ordinal, code)
    self.name = name
    self.ordinal = ordinal
    self.weight = 1
    self.code = code
end

function Color.new2(name, ordinal, code)
    local self = setmetatable({}, Color)
    self:____init2(name, ordinal, code)
    return self
end

function Color:____init3(name, ordinal, code, weight)
    Color.____init2(self, name, ordinal, code)
    self.weight = weight
end

function Color.new3(name, ordinal, code, weight)
    local self = setmetatable({}, Color)
    self:____init3(name, ordinal, code, weight)
    return self
end

function Color:describe()
    return self.name .. "#" .. self.ordinal .. " " .. self.code .. " x" .. self.weight
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new2("RED", 0, "r")
Color.GREEN = Color.new3("GREEN", 1, "g", 2)
Color.BLUE = Color.new1("BLUE", 2)
Color.____values = {Color.RED, Color.GREEN, Color.BLUE}

local function main()
    local ____list = __K2L_EnumValues(Color)
    for ____i = 1, ____list.size do
        local c = ____list[____i]
        print(c:describe())
    end
    print(__K2L_EnumValueOf(Color, "GREEN").ordinal)
    print(__K2L_Str(Color.BLUE))
    print(Color.RED == __K2L_EnumValueOf(Color, "RED"))
end

main()
return {Color = Color}
