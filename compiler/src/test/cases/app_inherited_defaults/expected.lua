local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf

local Report = __K2L_Class("Report")
local Base = __K2L_Class("Base", nil, Report)

function Base:____init(name)
    self.name = name
end

function Base:greet(greeting, target)
    if greeting == nil then
        greeting = "hello"
    end
    if target == nil then
        target = self.name:upper()
    end
    return greeting .. " " .. target
end

local Leaf = __K2L_Class("Leaf", Base)

function Leaf:____init(name)
    Base.____init(self, name)
end

function Leaf:render(indent, width)
    if indent == nil then
        indent = ""
    end
    if width == nil then
        width = #indent + 10
    end
    return indent .. self.name .. "/" .. width
end

function Leaf:greet(greeting, target)
    if greeting == nil then
        greeting = "hello"
    end
    if target == nil then
        target = self.name:upper()
    end
    return "leaf: " .. Base.greet(self, greeting, target)
end

local Branch = __K2L_Class("Branch", Leaf)

function Branch:____init(name, kids)
    Leaf.____init(self, name)
    self.kids = kids
end

function Branch:render(prefix, max)
    if prefix == nil then
        prefix = ""
    end
    if max == nil then
        max = #prefix + 10
    end
    return __K2L_SingletonListOf(prefix .. self.name .. "/" .. max):plusAll(self.kids:map(function(it) return it:render(prefix .. "  ") end)):joinToString("\n")
end

function Branch:greet(hi, who)
    if hi == nil then
        hi = "hello"
    end
    if who == nil then
        who = self.name:upper()
    end
    return "branch: " .. hi .. " " .. who
end

local function main()
    local tree = Branch.new("root", __K2L_ReadOnlyListOf(Leaf.new("a"), Branch.new("b", __K2L_SingletonListOf(Leaf.new("c")))))
    print(tree:render())
    print(tree:render(">"))
    local r = Leaf.new("x")
    print(r:render() .. " " .. r:render(nil, 3))
    print(Leaf.new("y"):greet() .. " | " .. Leaf.new("y"):greet("hi") .. " | " .. tree:greet() .. " | " .. tree:greet(nil, "you"))
end

main()
return {Report = Report, Base = Base, Leaf = Leaf, Branch = Branch}
