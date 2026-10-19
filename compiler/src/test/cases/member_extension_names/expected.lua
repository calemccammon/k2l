local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str

local Holder = __K2L_Class("Holder")

function Holder:____init()
    self.counter = 0
end

function Holder:getX(____this)
    return #____this
end

function Holder:getX__1(____this_1)
    return ____this_1
end

function Holder:getY()
    return 1
end

function Holder:getY__1(____this_2)
    return 2
end

function Holder:shout(____this_3)
    return ____this_3 .. "!"
end

function Holder:getZ(____this_4)
    return #____this_4 + self.counter
end

function Holder:setZ(____this_4, v)
    self.counter = v
end

function Holder:getZ__1(____this_5)
    return ____this_5 * 2 + self.counter
end

function Holder:setZ__1(____this_5, v)
    self.counter = v * 10
end

function Holder:run()
    self:setZ("ab", 5)
    local a = self:getZ("abc")
    self:setZ__1(7, 3)
    local b = self:getZ__1(4)
    self:setZ("q", self:getZ("q") + 1)
    return a .. " " .. b .. " " .. self.counter
end

local Parent = __K2L_Class("Parent")

function Parent:getTag(____this_6)
    return "parent:" .. ____this_6
end

function Parent:getTag__1(____this_7)
    return "int:" .. ____this_7
end

function Parent:tags()
    return self:getTag("s") .. " " .. self:getTag__1(1)
end

local Child = __K2L_Class("Child", Parent)

function Child:getTag(____this_8)
    return "child:" .. ____this_8
end

function Child:getTag__2(____this_9)
    return "double:" .. __K2L_Str(____this_9)
end

function Child:more()
    return self:getTag__2(2.5) .. " " .. self:getTag("t")
end

local function main()
    local h = Holder.new()
    print(h:getX("a") + h:getX__1(1) + h:getY__1("b") + h:getY() + #h:shout("c"))
    print(h:run())
    print(Parent.new():tags())
    local c = Child.new()
    print(c:tags())
    print(c:more())
end

main()
return {Holder = Holder, Parent = Parent, Child = Child}
