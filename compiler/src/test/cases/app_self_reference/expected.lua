local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local tree, countdown, greetingName
local Node = __K2L_Class("Node")

function Node:____init(name, children)
    self.name = name
    self.children = children
end

tree = Node.new("root", function()
    return __K2L_ReadOnlyListOf(Node.new("leaf", function() return __K2L_ReadOnlyListOf() end), Node.new("loop", function() return __K2L_SingletonListOf(tree) end))
end)
countdown = function(n)
    return n == 0 and __K2L_SingletonListOf(0) or __K2L_SingletonListOf(n):plusAll(countdown(n - 1))
end
local ____greeting_delegate = __K2L_Lazy(function() return "hello from " .. greetingName() end)

function greetingName()
    return "lazy"
end

local function main()
    print(__K2L_Str(tree.children():map(function(it) return it.name end)))
    print(tree.children():get(1).children():single() == tree)
    print(__K2L_Str(countdown(4)))
    print(____greeting_delegate:getValue())
end

main()
return {Node = Node, tree = tree, countdown = countdown, ____greeting_delegate = ____greeting_delegate, greetingName = greetingName}
