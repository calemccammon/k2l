local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local Host = __K2L_Class("Host")

function Host:____init(name)
    self.name = name
end

Host.In = __K2L_Class("Host$In")

function Host.In:____init(____outer, n)
    self.____outer = ____outer
    self.n = n
end

function Host.In:show()
    return self.____outer.name .. "/" .. self.n
end

function Host:refs()
    return __K2L_ReadOnlyListOf(1, 2):map(function(...) return Host.In.new(self, ...) end):map(function(it) return it:show() end)
end

function Host:bound()
    return (function(...) return Host.In.new(self, ...) end)(9):show()
end

local Pair2 = __K2L_Class("Pair2")

function Pair2:____init(a)
    self.a = a
end

Pair2.Part = __K2L_Class("Pair2$Part")

function Pair2.Part:____init(____outer, b)
    self.____outer = ____outer
    self.b = b
end

function Pair2.Part:joined()
    return self.____outer.a .. self.b
end

local function localInner()
    local prefix = "p"
    local Local = __K2L_Class("MainKt$localInner$Local")
    function Local:____init(label)
        self.label = label
        self.count = 0
    end
    Local.Inner = __K2L_Class("MainKt$localInner$Local$Inner")
    function Local.Inner:____init(____outer, step)
        self.____outer = ____outer
        self.step = step
    end
    function Local.Inner:bump()
        self.____outer.count = self.____outer.count + self.step
        return prefix .. ":" .. self.____outer.label .. ":" .. self.____outer.count
    end
    Local.Inner.Deep = __K2L_Class("MainKt$localInner$Local$Inner$Deep")
    function Local.Inner.Deep:____init(____outer)
        self.____outer = ____outer
    end
    function Local.Inner.Deep:path()
        return self.____outer.____outer.label .. ">" .. self.____outer.step .. ">" .. self.____outer.____outer.count
    end
    function Local:make(step)
        return Local.Inner.new(self, step)
    end
    local ____local = Local.new("L")
    local inner = ____local:make(2)
    local first = inner:bump()
    local second = Local.Inner.new(____local, 5):bump()
    local deep = Local.Inner.Deep.new(inner):path()
    return first .. " " .. second .. " " .. deep
end

local function main()
    local h = Host.new("host")
    print(__K2L_Str(h:refs()))
    print(h:bound())
    print(localInner())
    local make = Host.In.new
    print(make(Host.new("other"), 7):show())
    local partOf = Pair2.Part.new
    print(partOf(Pair2.new("x"), "y"):joined())
    local bound = function(...) return Host.In.new(h, ...) end
    print(bound(3):show())
end

main()
return {Host = Host, Pair2 = Pair2, localInner = localInner}
