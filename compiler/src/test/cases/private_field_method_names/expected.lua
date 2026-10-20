local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Str = ____lualib.__K2L_Str

local Countdown = __K2L_Class("Countdown")

function Countdown:____init(from)
    self.from = from
    self.____next = self.from
end

function Countdown:hasNext()
    return self.____next > 0
end

function Countdown:next()
    if not self:hasNext() then
        error(__K2L_NoSuchElementException.new("done"))
    end
    local ____old = self.____next
    self.____next = self.____next - 1
    return ____old
end

function Countdown:from__1()
    return "from " .. self.from
end

local Fib = __K2L_Class("Fib")

function Fib:____init()
    self.current = 0
    self.____next = 1
end

function Fib:getCurrent()
    return self.current
end

function Fib:setCurrent(value)
    self.current = value
end

function Fib:hasNext()
    return true
end

function Fib:next()
    local r = self:getCurrent()
    local ____value = self.____next
    self.____next = self.____next + self:getCurrent()
    self:setCurrent(____value)
    return r
end

function Fib:current__1()
    return self:getCurrent()
end

local Buffer = __K2L_Class("Buffer")

function Buffer:____init(size)
    self.size = size
    self.items = __K2L_List.new()
end

function Buffer:size__1()
    return self.items.size
end

function Buffer:add(s)
    if self.items.size < self.size then
        self.items:add(s)
    end
    return self
end

function Buffer:capacity()
    return self.size
end

function Buffer:items__1()
    return self.items:toList()
end

local function main()
    local c = Countdown.new(3)
    print(__K2L_Str(__K2L_AsSequence(c):toList()) .. " " .. tostring(c:hasNext()) .. " " .. c:from__1())
    print(__K2L_Str(__K2L_RunCatching(function() return c:next() end):exceptionOrNull()))
    local f = Fib.new()
    print(__K2L_Str(__K2L_ListOfSize(10, function(it) return f:next() end)) .. " " .. f:current__1())
    local b = Buffer.new(2):add("a"):add("b"):add("c")
    print(b:size__1() .. " " .. b:capacity() .. " " .. __K2L_Str(b:items__1()))
    for _, x in __K2L_Iterator.iter(Countdown.new(2)) do
        io.write(x .. " ")
    end
    print()
end

__K2L_DeepMain(main)
return {Countdown = Countdown, Fib = Fib, Buffer = Buffer}
