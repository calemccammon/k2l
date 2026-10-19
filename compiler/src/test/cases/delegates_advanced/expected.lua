local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Lazy = ____lualib.__K2L_Lazy

local Cell
local Logged = __K2L_Class("Logged")

function Logged:____init(tag)
    self.tag = tag
end

function Logged:provideDelegate(thisRef, property)
    print("providing " .. self.tag .. "." .. property.name .. " for " .. (thisRef == nil and "nothing" or "an object"))
    return Cell.new(self.tag .. ":" .. property.name)
end

Cell = __K2L_Class("Cell")

function Cell:____init(label)
    self.label = label
    self.stored = 0
end

function Cell:getValue(thisRef, property)
    print("get " .. self.label)
    return self.stored
end

function Cell:setValue(thisRef, property, value)
    print("set " .. self.label .. " = " .. value)
    self.stored = value
end

local Bare = __K2L_Class("Bare")

function Bare:____init(raw)
    self.raw = raw
end

local function getValue(self, thisRef, property)
    return property.name .. "=" .. self.raw
end

local function setValue(____this, thisRef, property, value)
    ____this.raw = value:upper()
end

local Counter = __K2L_Class("Counter")

function Counter:____init(n)
    self.n = n
end

local function getValue__1(____this_1, thisRef, property)
    local ____old = ____this_1.n
    ____this_1.n = ____this_1.n + 1
    return ____old
end

local Named = __K2L_Class("Named")

function Named:____init(prefix)
    self.prefix = prefix
end

local Fixed = __K2L_Class("Fixed")

function Fixed:____init(text)
    self.text = text
end

function Fixed:getValue(thisRef, property)
    return self.text
end

local function provideDelegate(____this_2, thisRef, property)
    return Fixed.new(____this_2.prefix .. property.name)
end

local Base = __K2L_Class("Base")

function Base:____init()
    self.____title_delegate = __K2L_Lazy(function()
        print("base title")
        return "base"
    end)
    self.____level_delegate = Cell.new("base-level")
end

function Base:getTitle()
    return self.____title_delegate:getValue()
end

function Base:getLevel()
    return self.____level_delegate:getValue(self, {name = "level"})
end

function Base:setLevel(value)
    self.____level_delegate:setValue(self, {name = "level"}, value)
end

function Base:describe()
    return self:getTitle() .. "/" .. self:getLevel()
end

local Derived = __K2L_Class("Derived", Base)

function Derived:____init()
    Base.____init(self)
    self.____title_delegate__Derived = __K2L_Lazy(function()
        print("derived title")
        return "derived"
    end)
    self.____level_delegate__Derived = Cell.new("derived-level")
end

function Derived:getTitle()
    return self.____title_delegate__Derived:getValue()
end

function Derived:getLevel()
    return self.____level_delegate__Derived:getValue(self, {name = "level"})
end

function Derived:setLevel(value)
    self.____level_delegate__Derived:setValue(self, {name = "level"}, value)
end

function Derived:superTitle()
    return Base.getTitle(self)
end

local Plain = __K2L_Class("Plain")

function Plain:____init()
    self.size = 1
    self.____note_delegate = __K2L_Lazy(function() return "from lazy" end)
end

function Plain:getSize()
    return self.size
end

function Plain:getNote()
    return self.____note_delegate:getValue()
end

local Delegating = __K2L_Class("Delegating", Plain)

function Delegating:____init()
    Plain.____init(self)
    self.____size_delegate__Delegating = __K2L_Lazy(function() return 42 end)
    self.note = "plain now"
end

function Delegating:getSize()
    return self.____size_delegate__Delegating:getValue()
end

function Delegating:getNote()
    return self.note
end

local HasName = __K2L_Class("HasName")
local Lazily = __K2L_Class("Lazily", nil, HasName)

function Lazily:____init()
    self.____name_delegate__Lazily = __K2L_Lazy(function() return "lazy name" end)
end

function Lazily:getName()
    return self.____name_delegate__Lazily:getValue()
end

local Members = __K2L_Class("Members")

function Members:____init()
    self.____tracked_delegate = Logged.new("member"):provideDelegate(self, {name = "tracked"})
    self.____bare_delegate = Bare.new("x")
    self.____settable_delegate = Bare.new("y")
    self.____counter_delegate = Counter.new(10)
    self.____greeting_delegate = provideDelegate(Named.new("hi-"), self, {name = "greeting"})
end

function Members:getTracked()
    return self.____tracked_delegate:getValue(self, {name = "tracked"})
end

function Members:setTracked(value)
    self.____tracked_delegate:setValue(self, {name = "tracked"}, value)
end

function Members:getBare()
    return getValue(self.____bare_delegate, self, {name = "bare"})
end

function Members:getSettable()
    return getValue(self.____settable_delegate, self, {name = "settable"})
end

function Members:setSettable(value)
    setValue(self.____settable_delegate, self, {name = "settable"}, value)
end

function Members:getCounter()
    return getValue__1(self.____counter_delegate, self, {name = "counter"})
end

function Members:getGreeting()
    return self.____greeting_delegate:getValue(self, {name = "greeting"})
end

local ____top_delegate = Logged.new("top"):provideDelegate(nil, {name = "top"})
local ____topBare_delegate = Bare.new("z")

local function main()
    local m = Members.new()
    print("created")
    m:setTracked(5)
    print(m:getTracked())
    print(m:getBare())
    m:setSettable("abc")
    print(m:getSettable())
    print(m:getCounter())
    print(m:getCounter())
    print(m:getGreeting())
    print(____top_delegate:getValue(nil, {name = "top"}))
    print(getValue(____topBare_delegate, nil, {name = "topBare"}))
    setValue(____topBare_delegate, nil, {name = "topBare"}, "q")
    print(getValue(____topBare_delegate, nil, {name = "topBare"}))
    local ________local_delegate = Logged.new("local"):provideDelegate(nil, {name = "local"})
    ________local_delegate:setValue(nil, {name = "local"}, 3)
    print(________local_delegate:getValue(nil, {name = "local"}))
    local ____localBare_delegate = Bare.new("l")
    print(getValue(____localBare_delegate, nil, {name = "localBare"}))
    local b = Base.new()
    print(b:describe())
    b:setLevel(2)
    print(b:getLevel())
    local d = Derived.new()
    print(d:describe())
    d:setLevel(7)
    print(d:getLevel())
    print(d:superTitle())
    local asBase = d
    print(asBase:getTitle())
    print(asBase:getLevel())
    local dg = Delegating.new()
    print(dg:getSize())
    print(dg:getNote())
    local plain = dg
    print(plain:getSize())
    print(plain:getNote())
    print(Plain.new():getNote())
    local named = Lazily.new()
    print(named:getName())
end

main()
return {Logged = Logged, Cell = Cell, Bare = Bare, getValue = getValue, setValue = setValue, Counter = Counter, getValue__1 = getValue__1, Named = Named, Fixed = Fixed, provideDelegate = provideDelegate, Base = Base, Derived = Derived, Plain = Plain, Delegating = Delegating, HasName = HasName, Lazily = Lazily, Members = Members, ____top_delegate = ____top_delegate, ____topBare_delegate = ____topBare_delegate}
