local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local Counter = __K2L_Class("app.Counter")
local count__1, step

local function advance(by)
    count__1 = count__1 + by
end

local function reset()
    count__1 = 0
end

function Counter:____init()
    count__1 = 0
    step = 2
end

function Counter:tick()
    advance(step)
    return count__1
end

function Counter:reference()
    return reset
end

local ____lambda_1 = function() return count__1 end
function Counter:property()
    return __K2L_PropertyRef.new("count", "app/Counter.count", ____lambda_1, function(value)
        count__1 = value
    end)
end

Counter:____init()
local Account = __K2L_Class("app.Account")

local function check(self, amount)
    return amount <= self.balance
end

local function check__1(self, text)
    return #text > 0
end

local function label(self)
    return self.owner:upper()
end

local function nonEmpty(self)
    return check__1(self, self.owner)
end

function Account:____init(owner)
    self.owner = owner
    self.balance = 0
    self.pin = 0
end

function Account:deposit(amount)
    self.balance = self.balance + amount
    return self
end

function Account:withdraw(amount)
    local ____value = check(self, amount)
    if ____value then
        self.balance = self.balance - amount
    end
    return ____value
end

function Account:sameOwner(other)
    return label(other) == label(self)
end

function Account:labels(accounts)
    local ____arg = accounts:map(label)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = accounts:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = label(it)
    end
    return ____arg:plusAll(__K2L_ListWrap(____out, ____count))
end

function Account:bound()
    return function(...) return nonEmpty(self, ...) end
end

function Account:changePin(p)
    self.pin = p
end

local Ledger = __K2L_Class("app.Ledger")

local function check__2(self, amount)
    return amount > 100
end

function Ledger:large(amount)
    return check__2(self, amount)
end

local Shadows = __K2L_Class("app.Shadows")

local function total__1(self, xs)
    return xs:sum()
end

function Shadows:run(total, count)
    return total + count + total__1(self, __K2L_ListOf(1, 2))
end

local Machine = __K2L_Class("app.Machine")
local made

local function nextId()
    made = made + 1
    return made
end

local function describe(self)
    return "machine " .. self.id
end

function Machine:____init()
    self.id = nextId()
end

Machine.Part = __K2L_Class("app.Machine$Part")

function Machine.Part:____init(____outer)
    self.____outer = ____outer
end

function Machine.Part:owner()
    return "part of " .. describe(self.____outer)
end

function Machine:create()
    return Machine.new()
end

function Machine:____initCompanion()
    made = 0
end

Machine:____initCompanion()
local Lazy = __K2L_Class("app.Lazy")

local function ____load(what)
    print("loading " .. what)
    return 41
end

function Lazy:____init()
    self.start = ____load("Lazy")
    print("Lazy ready")
end

Lazy.Reader = __K2L_Class("app.Lazy$Reader")

function Lazy.Reader:read()
    return Lazy.start + 1
end

function Lazy:direct()
    return self.start
end

__K2L_LazyObject(Lazy, "____init")
local Greeter = __K2L_Class("app.Greeter")

local function prefix(self)
    return "Hello, "
end

function Greeter:greet()
    return prefix(self) .. self.name
end

local English = __K2L_Class("app.English", nil, Greeter)

function English.new(name)
    return setmetatable({name = name}, English)
end

local Op = __K2L_Class("app.Op")

local function limit(self, v)
    return v < 0 and 0 or v
end

function Op:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Op:clamp(v)
    return limit(self, v)
end

function Op:toString()
    return self.name
end

function Op:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____ADD = __K2L_Class("Op", Op)
    function ____ADD:apply(a, b)
        return self:clamp(a + b)
    end
    Op.ADD = ____ADD.new("ADD", 0)
end
do
    local ____SUB = __K2L_Class("Op", Op)
    function ____SUB:apply(a, b)
        return self:clamp(a - b)
    end
    Op.SUB = ____SUB.new("SUB", 1)
end
Op.____values = {Op.ADD, Op.SUB}
local Exposed = __K2L_Class("app.Exposed")

function Exposed:helper()
    return "kept"
end

function Exposed:call()
    return self:helper()
end

local Late = __K2L_Class("app.Late")
local config

function Late:ready()
    return config ~= nil
end

function Late:set(value)
    config = value
end

function Late:get()
    return config or __K2L_Uninitialized("config")
end

local Matrix = __K2L_Class("app.Matrix")

function Matrix.new(cells)
    return setmetatable({cells = cells}, Matrix)
end

function Matrix:get(i)
    return self.cells[i + 1] or __K2L_IndexError(i, self.cells.size, "array")
end

function Matrix:first()
    return self:get(0)
end

local Recursion = __K2L_Class("app.Recursion")
local odd

local function even(n)
    if n == 0 then
        return true
    else
        return odd(n - 1)
    end
end

function odd(n)
    if n == 0 then
        return false
    else
        return even(n - 1)
    end
end

function Recursion:isEven(n)
    return even(n)
end

local function main()
    print(Counter:tick())
    print(Counter:tick())
    Counter:reference()()
    print(Counter:tick())
    local count = Counter:property()
    print(count())
    local a = Account.new("ada"):deposit(10)
    print(a:withdraw(3))
    print(a:withdraw(30))
    print(a:sameOwner(Account.new("ADA")))
    print(__K2L_Str(a:labels(__K2L_ListOf(a, Account.new("bob")))))
    print(a:bound()())
    a:changePin(42)
    print(a.pin)
    print(Ledger.new():large(500))
    print(Shadows.new():run(1, 2))
    local m = Machine:create()
    print(Machine:create().id)
    print(Machine.Part.new(m):owner())
    print("before reader")
    print(Lazy.Reader.new():read())
    print(Lazy:direct())
    print(English.new("Bob"):greet())
    print(Op.ADD:apply(1, 2))
    print(Op.SUB:apply(1, 2))
    print(Exposed:call())
    print(Late:ready())
    Late:set("on")
    print(Late:ready())
    print(Late:get())
    print(Matrix.new(__K2L_ArrayOf(7, 8)):first())
    print(Recursion:isEven(10))
end

__K2L_RunMain(main)
return {Counter = Counter, Account = Account, Ledger = Ledger, Shadows = Shadows, Machine = Machine, Lazy = Lazy, Greeter = Greeter, English = English, Op = Op, Exposed = Exposed, Late = Late, Matrix = Matrix, Recursion = Recursion}
