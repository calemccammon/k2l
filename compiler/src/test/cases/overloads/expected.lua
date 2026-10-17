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

local function describe(x)
    return "int " .. x
end

local function describe__1(x)
    return "string " .. x
end

local function describe__2(x, y)
    return "pair " .. x .. "," .. y
end

local Printer = __K2L_Class("Printer")

function Printer:print(x)
    return "Printer.int " .. x
end

function Printer:print__1(x)
    return "Printer.string " .. x
end

local LoudPrinter = __K2L_Class("LoudPrinter", Printer)

function LoudPrinter:print__1(x)
    return "LOUD " .. Printer.print__1(self, x):upper()
end

function LoudPrinter:print__2(x)
    return "LoudPrinter.bool " .. tostring(x)
end

local function main()
    print(describe(1))
    print(describe__1("a"))
    print(describe__2(1, 2))
    local p = LoudPrinter.new()
    print(p:print(3))
    print(p:print__1("hey"))
    local lp = LoudPrinter.new()
    print(lp:print__2(true))
    print(Printer.new():print__1("plain"))
end

main()
return {describe = describe, describe__1 = describe__1, describe__2 = describe__2, Printer = Printer, LoudPrinter = LoudPrinter}
