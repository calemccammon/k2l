local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class

local A = __K2L_Class("A")

function A:____init()
    self.x = 1
    self.y = "a"
end

function A:getX()
    return self.x
end

function A:getY()
    return self.y
end

function A:setY(value)
    self.y = value
end

function A:fromA()
    return "A sees " .. self:getX() .. " " .. self:getY()
end

local B = __K2L_Class("B", A)

function B:____init()
    A.____init(self)
    self.x__B = 2
    self.y__B = "b"
end

function B:getX()
    return self.x__B
end

function B:getY()
    return self.y__B
end

function B:setY(value)
    self.y__B = value
end

function B:both()
    return A.getX(self) .. " " .. self:getX() .. " " .. A.getY(self) .. " " .. self:getY()
end

local C = __K2L_Class("C", B)

function C:____init()
    B.____init(self)
    self.y__C = "c"
end

function C:getY()
    return self.y__C
end

function C:setY(value)
    self.y__C = value
end

function C:both()
    return B.both(self) .. " | " .. B.getY(self) .. " " .. self:getY()
end

local Plain = __K2L_Class("Plain")

function Plain:____init(name)
    self.name = name
end

function Plain.new(name)
    return setmetatable({name = name}, Plain)
end

function Plain:getName()
    return self.name
end

local Named = __K2L_Class("Named", Plain)

function Named:____init(name)
    Plain.____init(self, "base")
    self.name__Named = name
end

function Named:getName()
    return self.name__Named
end

function Named:show()
    return Plain.getName(self) .. " " .. self:getName()
end

local function main()
    local b = B.new()
    print(b:both())
    print(b:fromA())
    b:setY("changed")
    print(b:both())
    local a = b
    print(a:getX())
    print(a:getY())
    local c = C.new()
    print(c:both())
    c:setY("z")
    print(c:both())
    print(Named.new("n"):show())
end

main()
return {A = A, B = B, C = C, Plain = Plain, Named = Named}
