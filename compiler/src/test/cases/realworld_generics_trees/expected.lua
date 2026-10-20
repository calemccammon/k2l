local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Tree = __K2L_Class("generics.trees.Tree")
Tree.Empty = __K2L_Class("generics.trees.Tree$Empty", nil, Tree)

function Tree.Empty:toString()
    return "Empty"
end

function Tree.Empty:hashCode()
    return -2077107160
end

Tree.Node = __K2L_Class("generics.trees.Tree$Node", nil, Tree)

function Tree.Node:____init(left, value, right)
    self.left = left
    self.value = value
    self.right = right
end

function Tree.Node.new(left, value, right)
    return setmetatable({left = left, value = value, right = right}, Tree.Node)
end

function Tree.Node:toString()
    return "Node(left=" .. __K2L_Str(self.left) .. ", value=" .. __K2L_Str(self.value) .. ", right=" .. __K2L_Str(self.right) .. ")"
end

function Tree.Node:hashCode()
    return (31 * (31 * __K2L_Hash(self.left) + __K2L_Hash(self.value)) + __K2L_Hash(self.right) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Tree.Node:equals(other)
    return getmetatable(other) == Tree.Node and __K2L_Equals(self.left, other.left) and __K2L_Equals(self.value, other.value) and __K2L_Equals(self.right, other.right)
end

local function insert(self, x)
    if __K2L_Equals(self, Tree.Empty) then
        return Tree.Node.new(Tree.Empty, x, Tree.Empty)
    elseif getmetatable(self) == Tree.Node then
        if __K2L_Compare(x, self.value) < 0 then
            return Tree.Node.new(insert(self.left, x), self.value, self.right)
        elseif __K2L_Compare(x, self.value) > 0 then
            return Tree.Node.new(self.left, self.value, insert(self.right, x))
        else
            return self
        end
    end
end

local function contains(____this, x)
    if __K2L_Equals(____this, Tree.Empty) then
        return false
    elseif getmetatable(____this) == Tree.Node then
        if __K2L_Equals(x, ____this.value) then
            return true
        elseif __K2L_Compare(x, ____this.value) < 0 then
            return contains(____this.left, x)
        else
            return contains(____this.right, x)
        end
    end
end

local function inOrder(____this_1)
    if __K2L_Equals(____this_1, Tree.Empty) then
        return __K2L_ReadOnlyListOf()
    elseif getmetatable(____this_1) == Tree.Node then
        return inOrder(____this_1.left):plus(____this_1.value):plusAll(inOrder(____this_1.right))
    end
end

local function getHeight(____this_2)
    if __K2L_Equals(____this_2, Tree.Empty) then
        return 0
    elseif getmetatable(____this_2) == Tree.Node then
        return 1 + math.max(getHeight(____this_2.left), getHeight(____this_2.right))
    end
end

local function map(____this_3, f)
    if __K2L_Equals(____this_3, Tree.Empty) then
        return Tree.Empty
    elseif getmetatable(____this_3) == Tree.Node then
        return Tree.Node.new(map(____this_3.left, f), f(____this_3.value), map(____this_3.right, f))
    end
end

local function fold(____this_4, empty, combine)
    if __K2L_Equals(____this_4, Tree.Empty) then
        return empty
    elseif getmetatable(____this_4) == Tree.Node then
        return combine(fold(____this_4.left, empty, combine), ____this_4.value, fold(____this_4.right, empty, combine))
    end
end

local ____lambda_1 = function(t, x) return insert(t, x) end
local function treeOf(...)
    local xs = __K2L_ArrayOf(...)
    return xs:fold(Tree.Empty, ____lambda_1)
end

local function render(____this_5)
    if __K2L_Equals(____this_5, Tree.Empty) then
        return "."
    elseif getmetatable(____this_5) == Tree.Node then
        return __K2L_Equals(____this_5.left, Tree.Empty) and __K2L_Equals(____this_5.right, Tree.Empty) and __K2L_Str(____this_5.value) or "(" .. __K2L_Str(____this_5.value) .. " " .. render(____this_5.left) .. " " .. render(____this_5.right) .. ")"
    end
end

local Rose = __K2L_Class("generics.trees.Rose")

function Rose:____init(value, children)
    if children == nil then
        children = __K2L_ReadOnlyListOf()
    end
    self.value = value
    self.children = children
end

function Rose:map(f)
    local ____arg = f(self.value)
    local ____list = self.children
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:map(f)
    end
    return Rose.new(____arg, __K2L_ListWrap(____out, ____count))
end

function Rose:fold(f)
    local ____arg_1 = self.value
    local ____list_1 = self.children
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:fold(f)
    end
    return f(____arg_1, __K2L_ListWrap(____out_1, ____count_1))
end

function Rose:flatten()
    return __K2L_SequenceBuilder(function(____this_6)
        ____this_6:yield(self.value)
        local ____list_2 = self.children
        local ____mod = ____list_2.____modCount
        for ____i_2 = 1, ____list_2.size do
            local c = ____list_2[____i_2]
            ____this_6:yieldAll(c:flatten())
            if ____list_2.____modCount ~= ____mod and ____list_2:____comodified(____i_2) then
                break
            end
        end
    end)
end

function Rose:paths()
    if self.children:isEmpty() then
        return __K2L_SingletonListOf(__K2L_SingletonListOf(self.value))
    else
        local ____list_3 = self.children
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_3, ____n_3 = ____list_3:____array()
        for ____i_4 = 1, ____n_3 do
            local c = ____items_3[____i_4]
            local ____result
            do
                local ____list_4 = c:paths()
                local ____out_3 = {}
                local ____count_3 = 0
                local ____items_2, ____n_2 = ____list_4:____array()
                for ____i_3 = 1, ____n_2 do
                    local it = ____items_2[____i_3]
                    ____count_3 = ____count_3 + 1
                    ____out_3[____count_3] = __K2L_SingletonListOf(self.value):plusAll(it)
                end
                ____result = __K2L_ListWrap(____out_3, ____count_3)
            end
            local ____inner, ____m = ____result:____array()
            for ____j = 1, ____m do
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = ____inner[____j]
            end
        end
        return __K2L_ListWrap(____out_2, ____count_2)
    end
end

function Rose:toString()
    return "Rose(value=" .. __K2L_Str(self.value) .. ", children=" .. __K2L_Str(self.children) .. ")"
end

function Rose:hashCode()
    return (31 * __K2L_Hash(self.value) + __K2L_Hash(self.children) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Rose:equals(other)
    return getmetatable(other) == Rose and __K2L_Equals(self.value, other.value) and __K2L_Equals(self.children, other.children)
end

local function rose(value, ...)
    local children = __K2L_ArrayOf(...)
    return Rose.new(value, children:toList())
end

local Expr = __K2L_Class("generics.trees.Expr")
Expr.Lit = __K2L_Class("generics.trees.Expr$Lit", Expr)

function Expr.Lit:____init(value)
    self.value = value
end

function Expr.Lit.new(value)
    return setmetatable({value = value}, Expr.Lit)
end

function Expr.Lit:toString()
    return "Lit(value=" .. __K2L_Str(self.value) .. ")"
end

function Expr.Lit:hashCode()
    return __K2L_Hash(self.value)
end

function Expr.Lit:equals(other)
    return getmetatable(other) == Expr.Lit and __K2L_Equals(self.value, other.value)
end

Expr.Var = __K2L_Class("generics.trees.Expr$Var", Expr)

function Expr.Var:____init(name)
    self.name = name
end

function Expr.Var.new(name)
    return setmetatable({name = name}, Expr.Var)
end

function Expr.Var:toString()
    return "Var(name=" .. self.name .. ")"
end

function Expr.Var:hashCode()
    return __K2L_Hash(self.name)
end

function Expr.Var:equals(other)
    return getmetatable(other) == Expr.Var and self.name == other.name
end

Expr.Bin = __K2L_Class("generics.trees.Expr$Bin", Expr)

function Expr.Bin:____init(op, left, right)
    self.op = op
    self.left = left
    self.right = right
end

function Expr.Bin.new(op, left, right)
    return setmetatable({op = op, left = left, right = right}, Expr.Bin)
end

function Expr.Bin:toString()
    return "Bin(op=" .. self.op .. ", left=" .. __K2L_Str(self.left) .. ", right=" .. __K2L_Str(self.right) .. ")"
end

function Expr.Bin:hashCode()
    return (31 * (31 * __K2L_Hash(self.op) + __K2L_Hash(self.left)) + __K2L_Hash(self.right) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Bin:equals(other)
    return getmetatable(other) == Expr.Bin and self.op == other.op and __K2L_Equals(self.left, other.left) and __K2L_Equals(self.right, other.right)
end

Expr.Neg = __K2L_Class("generics.trees.Expr$Neg", Expr)

function Expr.Neg:____init(inner)
    self.inner = inner
end

function Expr.Neg.new(inner)
    return setmetatable({inner = inner}, Expr.Neg)
end

function Expr.Neg:toString()
    return "Neg(inner=" .. __K2L_Str(self.inner) .. ")"
end

function Expr.Neg:hashCode()
    return __K2L_Hash(self.inner)
end

function Expr.Neg:equals(other)
    return getmetatable(other) == Expr.Neg and __K2L_Equals(self.inner, other.inner)
end

local Domain = __K2L_Class("generics.trees.Domain")

function Domain:show(a)
    return __K2L_Str(a)
end

local Ints = __K2L_Class("generics.trees.Ints", nil, Domain)

function Ints:plus(a, b)
    return a + b
end

function Ints:times(a, b)
    return a * b
end

function Ints:negate(a)
    return -a
end

local Bools = __K2L_Class("generics.trees.Bools", nil, Domain)

function Bools:plus(a, b)
    return a or b
end

function Bools:times(a, b)
    return a and b
end

function Bools:negate(a)
    return not a
end

function Bools:show(a)
    return a and "T" or "F"
end

local Texts = __K2L_Class("generics.trees.Texts", nil, Domain)

function Texts:plus(a, b)
    return a .. "|" .. b
end

function Texts:times(a, b)
    return __K2L_StringToList(a):flatMap(function(x)
        return __K2L_StringToList(b):map(function(y) return x .. y end)
    end):joinToString("")
end

function Texts:negate(a)
    return a:reverse()
end

local function eval(____this_7, d, env)
    local ____mt = getmetatable(____this_7)
    if ____mt == Expr.Lit then
        return ____this_7.value
    elseif ____mt == Expr.Var then
        local ____value = env:get(____this_7.name)
        if ____value == nil then
            error(__K2L_IllegalArgumentException.new("unbound variable " .. ____this_7.name))
        end
        return ____value
    elseif ____mt == Expr.Neg then
        return d:negate(eval(____this_7.inner, d, env))
    elseif ____mt == Expr.Bin then
        local ____subject = ____this_7.op
        if ____subject == "+" then
            return d:plus(eval(____this_7.left, d, env), eval(____this_7.right, d, env))
        elseif ____subject == "*" then
            return d:times(eval(____this_7.left, d, env), eval(____this_7.right, d, env))
        else
            error(__K2L_UnsupportedOperationException.new("operator " .. ____this_7.op))
        end
    end
end

local function variables(____this_8)
    local ____mt_1 = getmetatable(____this_8)
    if ____mt_1 == Expr.Lit then
        return __K2L_ReadOnlySetOf()
    elseif ____mt_1 == Expr.Var then
        return __K2L_ReadOnlySetOf(____this_8.name)
    elseif ____mt_1 == Expr.Neg then
        return variables(____this_8.inner)
    elseif ____mt_1 == Expr.Bin then
        return variables(____this_8.left):plusAll(variables(____this_8.right))
    end
end

local function show(____this_9)
    local ____mt_2 = getmetatable(____this_9)
    if ____mt_2 == Expr.Lit then
        return __K2L_Str(____this_9.value)
    elseif ____mt_2 == Expr.Var then
        return ____this_9.name
    elseif ____mt_2 == Expr.Neg then
        return "-" .. show(____this_9.inner)
    elseif ____mt_2 == Expr.Bin then
        return "(" .. show(____this_9.left) .. " " .. ____this_9.op .. " " .. show(____this_9.right) .. ")"
    end
end

local ____lambda_2 = function(l, _, r) return l + 1 + r end
local ____lambda_3 = function(l, v, r) return l + v + r end
local ____lambda_4 = function(it) return "n" .. it end
local ____lambda_5 = function(l, v, r) return r or v or l end
local ____lambda_6 = function(it) return #it end
local ____lambda_7 = function(v, cs) return v + cs:sum() end
local ____lambda_8 = function(_, cs) return 1 + (cs:maxOrNull() or 0) end
local ____lambda_9 = function(_, cs) return cs:isEmpty() and 1 or cs:sum() end
local ____lambda_10 = function(____p1) return ____p1:upper() end
local function main()
    print("== search tree")
    local t = treeOf(50, 30, 70, 20, 40, 60, 80, 30, 65)
    print("inOrder=" .. __K2L_Str(inOrder(t)) .. " height=" .. getHeight(t) .. " size=" .. fold(t, 0, ____lambda_2))
    print("render=" .. render(t))
    print("contains 65=" .. tostring(contains(t, 65)) .. " 66=" .. tostring(contains(t, 66)) .. " sum=" .. fold(t, 0, ____lambda_3))
    local labels = map(t, ____lambda_4)
    local anyTree = labels
    print("labels=" .. __K2L_Str(inOrder(labels):take(3)) .. " any height=" .. getHeight(anyTree) .. " empty=" .. __K2L_Str(inOrder(Tree.Empty)) .. " " .. getHeight(Tree.Empty))
    local words = treeOf("pear", "apple", "fig", "kiwi", "banana")
    print("words=" .. __K2L_Str(inOrder(words)) .. " max=" .. __K2L_Str(fold(words, nil, ____lambda_5)) .. " render=" .. render(words))
    print("equal=" .. tostring(__K2L_Equals(treeOf(2, 1, 3), treeOf(2, 3, 1))) .. " " .. tostring(__K2L_Equals(treeOf(1, 2, 3), treeOf(2, 1, 3))) .. " empty=" .. __K2L_Str(Tree.Empty))
    print("== rose tree")
    local org = rose("ceo", rose("cto", rose("dev1"), rose("dev2")), rose("cfo", rose("acct")), rose("coo"))
    print("flatten=" .. __K2L_Str(org:flatten():toList()))
    local ____list_5 = org:paths()
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_4, ____n_4 = ____list_5:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_4[____i_5]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it:joinToString("/")
    end
    print("paths=" .. __K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print("lengths=" .. org:map(____lambda_6):fold(____lambda_7))
    print("depth=" .. org:fold(____lambda_8) .. " leaves=" .. org:fold(____lambda_9))
    local ____list_6 = org:map(____lambda_10).children
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_5, ____n_5 = ____list_6:____array()
    for ____i_6 = 1, ____n_5 do
        local it = ____items_5[____i_6]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = it.value
    end
    print("upper=" .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_5)))
    print("== expressions")
    local e = Expr.Bin.new("+", Expr.Bin.new("*", Expr.Var.new("x"), Expr.Lit.new(3)), Expr.Neg.new(Expr.Var.new("y")))
    print(show(e) .. " = " .. eval(e, Ints, __K2L_ReadOnlyMapOf(__K2L_Pair.new("x", 4), __K2L_Pair.new("y", 5))) .. " vars=" .. __K2L_Str(variables(e)))
    local b = Expr.Bin.new("*", Expr.Var.new("p"), Expr.Neg.new(Expr.Bin.new("+", Expr.Var.new("q"), Expr.Lit.new(false))))
    local ____list_7 = __K2L_ReadOnlyListOf(true, false)
    for ____i_8 = 1, ____list_7.size do
        local p = ____list_7[____i_8]
        local ____list_8 = __K2L_ReadOnlyListOf(true, false)
        for ____i_7 = 1, ____list_8.size do
            local q = ____list_8[____i_7]
            io.write(Bools:show(eval(b, Bools, __K2L_ReadOnlyMapOf(__K2L_Pair.new("p", p), __K2L_Pair.new("q", q)))) .. " ")
        end
    end
    print()
    local s = Expr.Bin.new("+", Expr.Bin.new("*", Expr.Lit.new("ab"), Expr.Var.new("v")), Expr.Neg.new(Expr.Lit.new("xyz")))
    print(show(s) .. " = " .. Texts:show(eval(s, Texts, __K2L_SingletonMapOf(__K2L_Pair.new("v", "12")))))
    local shared = Expr.Var.new("z")
    local reused = __K2L_ReadOnlyListOf(shared, Expr.Lit.new(1), Expr.Lit.new("a"))
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_6, ____n_6 = reused:____array()
    for ____i_9 = 1, ____n_6 do
        local it = ____items_6[____i_9]
        ____count_6 = ____count_6 + 1
        ____out_6[____count_6] = show(it)
    end
    local ____arg_2 = __K2L_Str(__K2L_ListWrap(____out_6, ____count_6))
    local ____out_7 = {}
    local ____count_7 = 0
    local ____items_7, ____n_7 = reused:____array()
    for ____i_10 = 1, ____n_7 do
        local it = ____items_7[____i_10]
        local ____inner_1, ____m_1 = variables(it):____array()
        for ____j_1 = 1, ____m_1 do
            ____count_7 = ____count_7 + 1
            ____out_7[____count_7] = ____inner_1[____j_1]
        end
    end
    print("reused=" .. ____arg_2 .. " vars=" .. __K2L_Str(__K2L_ListWrap(____out_7, ____count_7)))
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        eval(e, Ints, __K2L_SingletonMapOf(__K2L_Pair.new("x", 1)))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local ex = ____error
            print("error: " .. __K2L_Str(ex.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_2 = __K2L_DeepPcall(function()
        eval(Expr.Bin.new("/", Expr.Lit.new(1), Expr.Lit.new(2)), Ints, __K2L_ReadOnlyMapOf())
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_1, __K2L_UnsupportedOperationException) then
            local ex = ____error_1
            print("error: " .. __K2L_Str(ex.message))
        else
            error(____error_1, 0)
        end
    end
end

__K2L_DeepMain(main)
return {Tree = Tree, insert = insert, contains = contains, inOrder = inOrder, getHeight = getHeight, map = map, fold = fold, treeOf = treeOf, render = render, Rose = Rose, rose = rose, Expr = Expr, Domain = Domain, Ints = Ints, Bools = Bools, Texts = Texts, eval = eval, variables = variables, show = show}
