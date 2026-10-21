local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DeepRecursive = ____lualib.__K2L_DeepRecursive
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized
local __K2L_Unit = ____lualib.__K2L_Unit

local ____exports = {}
local Tree = __K2L_Class("Tree")

function Tree:____init(left, right)
    self.left = left
    self.right = right
end

function Tree.new(left, right)
    return setmetatable({left = left, right = right}, Tree)
end

local depthOf = __K2L_DeepRecursive.new(function(self, tree)
    return tree == nil and 0 or math.max(self:callRecursive(tree.left), self:callRecursive(tree.right)) + 1
end)
local countDown = __K2L_DeepRecursive.new(function(____this, n)
    return n == 0 and 0 or n + ____this:callRecursive(n - 1)
end)
local isEven = __K2L_DeepRecursive.new(function(____this_1, n)
    if n == 0 then
        return true
    else
        return (____exports.isOdd or __K2L_Uninitialized("isOdd")):callRecursive(n - 1)
    end
end)

local function fib()
    local memo = __K2L_HashMap.new()
    return __K2L_DeepRecursive.new(function(____this_2, n)
        if n < 2 then
            return n
        else
            local ____value_1 = memo:get(n)
            if ____value_1 == nil then
                local ____value = ____this_2:callRecursive(n - 1) + ____this_2:callRecursive(n - 2)
                memo:set(n, ____value)
                ____value_1 = ____value
            end
            return ____value_1
        end
    end)
end

local Parser = __K2L_Class("Parser")

function Parser:____init(text)
    self.text = text
    self.pos = 0
    self.nesting = __K2L_DeepRecursive.new(function(____this_3, it)
        local best = 0
        while self.pos < #self.text and (self.pos >= 0 and __K2L_StrByte(self.text, self.pos + 1) or __K2L_IndexError(self.pos, #self.text, "string")) == 91 do
            self.pos = self.pos + 1
            best = math.max(best, ____this_3:callRecursive(__K2L_Unit) + 1)
            if self.pos >= #self.text or (self.pos >= 0 and __K2L_StrByte(self.text, self.pos + 1) or __K2L_IndexError(self.pos, #self.text, "string")) ~= 93 then
                error(__K2L_IllegalStateException.new("expected ] at " .. self.pos))
            end
            self.pos = self.pos + 1
        end
        return best
    end)
end

local function main()
    ____exports.isOdd = __K2L_DeepRecursive.new(function(____this_4, n)
        if n == 0 then
            return false
        else
            return isEven:callRecursive(n - 1)
        end
    end)
    local tree = nil
    for it = 0, 99999 do
        tree = Tree.new(tree, nil)
    end
    print("depth: " .. depthOf:invoke(tree))
    print("small: " .. depthOf:invoke(Tree.new(Tree.new(nil, nil), Tree.new(nil, Tree.new(nil, nil)))))
    print("sum: " .. countDown:invoke(100000))
    print("again: " .. countDown:invoke(10))
    print("even: " .. tostring(isEven:invoke(100000)) .. ", " .. tostring(isEven:invoke(99999)) .. ", odd: " .. tostring((____exports.isOdd or __K2L_Uninitialized("isOdd")):invoke(7)))
    print("fib: " .. fib():invoke(70))
    local failing = __K2L_DeepRecursive.new(function(____this_5, n)
        if n == 0 then
            error(__K2L_IllegalArgumentException.new("bottom reached"))
        end
        return ____this_5:callRecursive(n - 1) + 1
    end)
    local ____ok, ____result = __K2L_DeepPcall(function()
        failing:invoke(50000)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local recovering = __K2L_DeepRecursive.new(function(____this_6, n)
        if n == 0 then
            error(__K2L_ArithmeticException.new("zero"))
        elseif n == 1000 then
            local ____ok_1, ____result_1, ____returned_1 = __K2L_DeepPcall(function()
                return true, ____this_6:callRecursive(n - 1)
            end)
            if ____ok_1 then
                if ____result_1 then
                    return ____returned_1
                end
            else
                local ____error_1 = __K2L_ToThrowable(____result_1)
                if __K2L_InstanceOf(____error_1, __K2L_ArithmeticException) then
                    local e = ____error_1
                    return -1
                else
                    error(____error_1, 0)
                end
            end
        else
            return ____this_6:callRecursive(n - 1) + 1
        end
    end)
    print("recovered: " .. recovering:invoke(30000))
    print("nesting: " .. Parser.new("[[[]][]]").nesting:invoke(__K2L_Unit))
    print("deep nesting: " .. Parser.new(("["):rep(20000) .. ("]"):rep(20000)).nesting:invoke(__K2L_Unit))
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        Parser.new("[[]").nesting:invoke(__K2L_Unit)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("parse error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
end

____exports.Tree = Tree
____exports.depthOf = depthOf
____exports.countDown = countDown
____exports.isEven = isEven
____exports.fib = fib
____exports.Parser = Parser
__K2L_DeepMain(main)
return ____exports
