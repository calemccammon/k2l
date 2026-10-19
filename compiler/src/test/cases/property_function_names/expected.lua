local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith

local Source = __K2L_Class("Source")
local Base = __K2L_Class("Base")

function Base:size__1()
    return 1
end

function Base:total()
    return self:size__1() * 10
end

local Derived = __K2L_Class("Derived", Base)

function Derived:____init()
    self.size = 5
end

function Derived:size__1()
    return self.size + 1
end

local Inbox = __K2L_Class("Inbox", nil, Source)

function Inbox:____init(items)
    self.items = items
end

function Inbox:items__1()
    return self.items:toList()
end

function Inbox:count()
    return self.items.size
end

function Inbox:count__1(prefix)
    return self.items:count(function(it) return __K2L_StringStartsWith(it, prefix) end)
end

local Holder = __K2L_Class("Holder")

function Holder:____init()
    self.values = __K2L_ListOf(1, 2)
end

function Holder:values__1()
    return self.values:map(function(it) return it * 2 end)
end

local function main()
    local box = Inbox.new(__K2L_ListOf("a", "ab"))
    local s = box
    print(__K2L_Str(s:items__1()))
    print(box:count())
    print(box:count__1("ab"))
    print(Derived.new():total())
    print(Derived.new().size)
    print(__K2L_Str(Holder.new():values__1()))
    local f = function(self, ...) return self:values__1(...) end
    print(__K2L_Str(f(Holder.new())))
end

main()
return {Source = Source, Base = Base, Derived = Derived, Inbox = Inbox, Holder = Holder}
