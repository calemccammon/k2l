local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith

local Greeter = __K2L_Class("app.Greeter")
local Counter = __K2L_Class("app.Counter")
local Animal = __K2L_Class("app.Animal")

function Animal:____init(name)
    self.name = name
end

function Animal.new(name)
    return setmetatable({name = name}, Animal)
end

function Animal:sound()
    return "..."
end

function Animal:describe()
    return self.name .. " says " .. self:sound()
end

local Ticker = __K2L_Class("app.Ticker", nil, Counter)

function Ticker:____init()
    self.n = 0
end

function Ticker:next()
    self.n = self.n + 1
    return self.n
end

local Shop = __K2L_Class("app.Shop")

function Shop:____init(title)
    self.title = title
    self.visits = 0
    local ____this = self
    local ____object = __K2L_Class("app.Shop$counter$1", nil, Counter)
    function ____object:____init()
        self.count = 10
    end
    function ____object:next()
        local ____old = self.count
        self.count = self.count + 1
        return ____old + ____this.visits
    end
    ____object:____init()
    self.counter = ____object
end

function Shop:greeter()
    local ____this_1 = self
    local ____object_1 = __K2L_Class("app.Shop$greeter$1", nil, Greeter)
    function ____object_1:greet(name)
        ____this_1.visits = ____this_1.visits + 1
        return "Welcome to " .. ____this_1.title .. ", " .. name .. " (visit " .. ____this_1.visits .. ")"
    end
    return ____object_1
end

Shop.Desk = __K2L_Class("app.Shop$Desk")

function Shop.Desk:____init(____outer)
    self.____outer = ____outer
end

function Shop.Desk:helper()
    local ____this_2 = self
    local ____this_3 = self.____outer
    local ____object_2 = __K2L_Class("app.Shop$Desk$helper$1", nil, Greeter)
    function ____object_2:greet(name)
        return ____this_3.title .. " desk helps " .. name
    end
    return ____object_2
end

local function makeCounter(start)
    local current = start
    local ____object_3 = __K2L_Class("app.MainKt$makeCounter$c$1", nil, Counter)
    function ____object_3:next()
        current = current + 2
        return current
    end
    local c = ____object_3
    c:next()
    print("current after one call: " .. current)
    return c
end

local function use(g)
    return g:greet("Ann")
end

local ____lambda_1 = function(name) return "Hi " .. name end
local function main()
    local ____object_4 = __K2L_Class("app.MainKt$main$1", nil, Greeter)
    function ____object_4:greet(name)
        return "Hi " .. name
    end
    print(use(____object_4))
    local ____object_5 = __K2L_Class("app.MainKt$main$dog$1", Animal, Counter)
    function ____object_5:____init()
        Animal.____init(self, "Rex")
        print("init of the dog object")
        self.barks = 0
    end
    function ____object_5:sound()
        self.barks = self.barks + 1
        return "woof"
    end
    function ____object_5:next()
        return self.barks
    end
    ____object_5:____init()
    local dog = ____object_5
    print(dog:describe() .. " " .. dog:describe() .. " " .. dog:next())
    print(tostring(__K2L_InstanceOf(dog, Animal)) .. " " .. tostring(__K2L_InstanceOf(dog, Counter)) .. " " .. dog.name)
    local ____object_6 = __K2L_Class("app.MainKt$main$point$1")
    function ____object_6:____init()
        self.x = 3
        self.y = 4
    end
    function ____object_6:sum()
        return self.x + self.y
    end
    ____object_6:____init()
    local point = ____object_6
    point.y = 10
    print(point:sum())
    local counter = makeCounter(5)
    print(counter:next() .. " " .. counter:next())
    local shop = Shop.new("Corner")
    local g = shop:greeter()
    print(g:greet("Bo"))
    print(g:greet("Cy"))
    print(shop.counter:next() + shop.counter:next())
    print(Shop.Desk.new(shop):helper():greet("Di"))
    local ____object_7 = __K2L_Class("app.MainKt$main$ticker$1", nil, Counter)
    function ____object_7:____init()
        self.____delegate_Counter = Ticker.new()
    end
    function ____object_7:next(...)
        return self.____delegate_Counter:next(...)
    end
    ____object_7:____init()
    local ticker = ____object_7
    print(ticker:next() .. " " .. ticker:next())
    local made = __K2L_IntRange.new(1, 3):map(function(i)
        local ____object_8 = __K2L_Class("app.MainKt$main$made$1$1", nil, Counter)
        function ____object_8:next()
            return i * 100
        end
        return ____object_8
    end)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = made:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:next()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(made:get(0) == made:get(1))
    local Local = __K2L_Class("app.MainKt$main$Local")
    print(__K2L_Str(__K2L_SimpleName(point)) .. " " .. __K2L_Str("Local"))
    print(__K2L_StringStartsWith(__K2L_Str(point), "app.MainKt$main$point$1@"))
end

__K2L_RunMain(main)
return {Greeter = Greeter, Counter = Counter, Animal = Animal, Ticker = Ticker, Shop = Shop, makeCounter = makeCounter, use = use}
