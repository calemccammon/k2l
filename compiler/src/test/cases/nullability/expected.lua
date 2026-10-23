local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Node = __K2L_Class("Node")

function Node.new(value, ____next)
    return setmetatable({value = value, next = ____next}, Node)
end

function Node:describe()
    return "Node(" .. self.value .. ")"
end

local function length(s)
    return s and #s or -1
end

local function firstValue(n)
    local ____receiver = n and n.next
    return ____receiver and ____receiver.value
end

local function orDefault(flag)
    local ____value = flag
    if ____value == nil then
        ____value = true
    end
    return ____value
end

local function parse(s)
    if s == nil then
        return 0
    end
    local text = s
    return #text * 10
end

local function main()
    print(length("abc"))
    print(length(nil))
    local list = Node.new(1, Node.new(2, nil))
    print(__K2L_Str(firstValue(list)))
    print(__K2L_Str(firstValue(Node.new(3, nil))))
    print(__K2L_Str(firstValue(nil)))
    print(orDefault(false))
    print(orDefault(nil))
    print(parse("hello"))
    print(parse(nil))
    local maybe = nil
    local ____receiver_1 = maybe
    if ____receiver_1 ~= nil then
        ____receiver_1:describe()
    end
    local ____receiver_2 = maybe
    print(__K2L_Str(____receiver_2 and ____receiver_2:describe()))
    maybe = list
    local ____receiver_3 = maybe
    print(__K2L_Str(____receiver_3 and ____receiver_3:describe()))
    print(__K2L_NotNull(maybe).value)
    local s = "x"
    if s ~= nil then
        print(#s)
    end
    local name = nil
    print(name or "anonymous")
    print(#(name or "a"))
end

__K2L_RunMain(main)
return {Node = Node, length = length, firstValue = firstValue, orDefault = orDefault, parse = parse}
