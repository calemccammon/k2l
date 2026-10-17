-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring")
    end
    local interfaces = {...}
    for _, iface in ipairs(interfaces) do
        cls.____interfaces[iface] = true
        for super in pairs(iface.____interfaces) do
            cls.____interfaces[super] = true
        end
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end

local function shout(self)
    return self:upper() .. "!"
end

local function isEven(____this)
    return math.fmod(____this, 2) == 0
end

local function orEmptyText(____this_1)
    return ____this_1 or ""
end

local Vec = __K2L_Class("Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

local function length2(____this_2)
    return ____this_2.x * ____this_2.x + ____this_2.y * ____this_2.y
end

local function scaled(____this_3, k)
    return Vec.new(____this_3.x * k, ____this_3.y * k)
end

local function describe(____this_4)
    return "(" .. ____this_4.x .. ", " .. ____this_4.y .. ") len2=" .. length2(____this_4)
end

local function main()
    print(shout("hi"))
    print(isEven(4))
    print(isEven(7))
    local missing = nil
    print(#orEmptyText(missing))
    print(orEmptyText("x"))
    local v = Vec.new(3, 4)
    print(length2(v))
    print(describe(scaled(v, 2)))
    local shout = shout
    print(shout("ref"))
end

main()
return {shout = shout, isEven = isEven, orEmptyText = orEmptyText, Vec = Vec, length2 = length2, scaled = scaled, describe = describe}
