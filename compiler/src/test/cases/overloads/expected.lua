local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class

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
