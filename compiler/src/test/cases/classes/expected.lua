local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Counter = __K2L_Class("Counter")

function Counter:____init(step)
    self.step = step
    self.count = 0
    print("Counter created with step " .. self.step)
end

function Counter:getDoubled()
    return self.count * 2
end

function Counter:increment()
    self.count = self.count + self.step
    return self
end

function Counter:reset()
    self.count = 0
end

local Temperature = __K2L_Class("Temperature")

function Temperature:____init(celsius)
    self.celsius = celsius
end

function Temperature.new(celsius)
    return setmetatable({celsius = celsius}, Temperature)
end

function Temperature:getCelsius()
    return self.celsius
end

function Temperature:setCelsius(value)
    print("setting " .. value)
    self.celsius = value < -273.15 and -273.15 or value
end

function Temperature:getFahrenheit()
    return self:getCelsius() * 9 / 5 + 32
end

local Account = __K2L_Class("Account")

function Account:____init(owner)
    self.owner = owner
    self.balance = 0
end

function Account:____init1(owner, initial)
    Account.____init(self, owner)
    self.balance = initial
    print("secondary constructor for " .. owner)
end

function Account.new1(owner, initial)
    local self = setmetatable({}, Account)
    self:____init1(owner, initial)
    return self
end

function Account:deposit(amount)
    self.balance = self.balance + amount
end

function Account:toString()
    return "Account(" .. self.owner .. ", " .. self.balance .. ")"
end

local function main()
    local c = Counter.new(3)
    c:increment():increment()
    print(c.count)
    print(c:getDoubled())
    c:reset()
    print(c.count)
    local t = Temperature.new(20.0)
    print(t:getFahrenheit())
    t:setCelsius(-300.0)
    print(t:getCelsius())
    local a = Account.new1("Ada", 100)
    a:deposit(50)
    a.balance = a.balance - 30
    print(__K2L_Str(a))
    print("account: " .. __K2L_Str(a))
    local b = Account.new("Bob")
    b.balance = b.balance + 1
    print(b:toString())
    print(a == b)
    print(a == a)
end

__K2L_RunMain(main)
return {Counter = Counter, Temperature = Temperature, Account = Account}
