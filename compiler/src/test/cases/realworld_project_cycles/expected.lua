-- ==== eval/Eval.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_LazyFile = ____lualib.__K2L_LazyFile
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_StringReplace = ____lualib.__K2L_StringReplace

local ____exports = {}
package.loaded["eval.Eval"] = ____exports
local ____Parser = require("lang.Parser")
local ____main = require("main")
local Value = __K2L_Class("calc.eval.Value")
Value.I = __K2L_Class("calc.eval.Value$I", nil, Value)

function Value.I.new(n)
    return setmetatable({n = n}, Value.I)
end

__K2L_DataClass(Value.I, {"n"})
Value.Q = __K2L_Class("calc.eval.Value$Q", nil, Value)

function Value.Q.new(node)
    return setmetatable({node = node}, Value.Q)
end

__K2L_DataClass(Value.Q, {"node"})
____exports.Value = Value

local function isBuiltin(name)
    return ____exports.builtins:containsKey(name)
end

____exports.isBuiltin = isBuiltin

local function define(name, f)
    if ____exports.reserved:contains(name) then
        error(__K2L_IllegalArgumentException.new("'" .. name .. "' is reserved"))
    end
    local ____object = ____exports.builtins
    ____object:set(name, f)
    ____main.trace("defined " .. name)
end

____exports.define = define

local function evaluate(node, env)
    ____exports.evaluations = ____exports.evaluations + 1
    local ____mt = getmetatable(node)
    if ____mt == ____Parser.Node.Num then
        return Value.I.new(node.value)
    elseif ____mt == ____Parser.Node.Sym then
        local ____value_1 = env:get(node.name)
        if ____value_1 == nil then
            error(__K2L_IllegalStateException.new("unbound " .. node.name))
        end
        return Value.I.new(____value_1)
    elseif ____mt == ____Parser.Node.Call then
        local ____cast = node.items:first()
        if getmetatable(____cast) ~= ____Parser.Node.Sym then
            __K2L_CastFail(____cast, "calc.lang.Node.Sym")
        end
        local head = ____cast
        local ____subject = head.name
        if ____subject == "quote" then
            return Value.Q.new(node.items:get(1))
        elseif ____subject == "let" then
            local ____cast_3 = node.items:get(1)
            if getmetatable(____cast_3) ~= ____Parser.Node.Sym then
                __K2L_CastFail(____cast_3, "calc.lang.Node.Sym")
            end
            local name = ____cast_3.name
            local ____cast_4 = evaluate(node.items:get(2), env)
            if getmetatable(____cast_4) ~= Value.I then
                __K2L_CastFail(____cast_4, "calc.eval.Value.I")
            end
            local v = ____cast_4.n
            return evaluate(node.items:get(3), env:plus(__K2L_Pair.new(name, v)))
        elseif ____subject == "eval" then
            local ____cast_2 = node.items:get(1)
            if getmetatable(____cast_2) ~= ____Parser.Node.Sym then
                __K2L_CastFail(____cast_2, "calc.lang.Node.Sym")
            end
            local src = __K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(____cast_2.name, "_", " "), "[", "("), "]", ")")
            return evaluate(____Parser.parse(src), env)
        else
            local ____value = ____exports.builtins:get(head.name)
            if ____value == nil then
                error(__K2L_IllegalStateException.new("no builtin " .. head.name))
            end
            local f = ____value
            local ____list = node.items:drop(1)
            local ____out = {}
            local ____count = 0
            local ____items, ____n = ____list:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                local ____result
                do
                    local ____cast_1 = evaluate(it, env)
                    if getmetatable(____cast_1) ~= Value.I then
                        __K2L_CastFail(____cast_1, "calc.eval.Value.I")
                    end
                    ____result = ____cast_1.n
                end
                ____count = ____count + 1
                ____out[____count] = ____result
            end
            return Value.I.new(f(__K2L_ListWrap(____out, ____count)))
        end
    end
end

____exports.evaluate = evaluate

local ____lambda_1 = function(xs) return xs:sum() end
local ____lambda_2 = function(a, b) return a * b end
local ____lambda_3 = function(xs) return xs:fold(1, ____lambda_2) end
local ____lambda_4 = function(a, b) return a - b end
local ____lambda_5 = function(xs) return xs:max() end
__K2L_LazyFile(____exports, function()
    ____exports.reserved = ____Parser.keywords:plus("def")
    ____exports.builtins = __K2L_MapOf(__K2L_Pair.new("+", ____lambda_1), __K2L_Pair.new("*", ____lambda_3), __K2L_Pair.new("-", function(xs)
        if xs.size == 1 then
            return -xs:get(0)
        else
            return xs:drop(1):fold(xs:get(0), ____lambda_4)
        end
    end), __K2L_Pair.new("max", ____lambda_5))
    ____exports.evaluations = 0
end, {"reserved", "builtins", "evaluations"})

return ____exports
-- ==== lang/Parser.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_LazyFile = ____lualib.__K2L_LazyFile
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull

local ____exports = {}
package.loaded["lang.Parser"] = ____exports
local ____Eval = require("eval.Eval")
local ____main = require("main")
local parseNode, countNodes
local Node = __K2L_Class("calc.lang.Node")
Node.Num = __K2L_Class("calc.lang.Node$Num", Node)

function Node.Num.new(value)
    return setmetatable({value = value}, Node.Num)
end

__K2L_DataClass(Node.Num, {"value"})
Node.Sym = __K2L_Class("calc.lang.Node$Sym", Node)

function Node.Sym.new(name, builtin)
    return setmetatable({name = name, builtin = builtin}, Node.Sym)
end

__K2L_DataClass(Node.Sym, {"name", "builtin"})
Node.Call = __K2L_Class("calc.lang.Node$Call", Node)

function Node.Call.new(items)
    return setmetatable({items = items}, Node.Call)
end

__K2L_DataClass(Node.Call, {"items"})
____exports.Node = Node
local Cursor = __K2L_Class("calc.lang.Cursor")

function Cursor:____init(tokens)
    self.tokens = tokens
    self.pos = 0
end

function Cursor:peek()
    return self.tokens:getOrNull(self.pos)
end

function Cursor:next()
    local ____arg = self.tokens
    local ____old = self.pos
    self.pos = self.pos + 1
    return ____arg:get(____old)
end

local function tokenize(src)
    local ____list_1 = __K2L_StringSplit(__K2L_StringReplace(__K2L_StringReplace(src, "(", " ( "), ")", " ) "), " ")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if not __K2L_StringIsBlank(it) then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

____exports.tokenize = tokenize

local function parse(src)
    local cursor = Cursor.new(tokenize(src))
    local node = parseNode(cursor, 1)
    ____main.trace("parsed '" .. src .. "' into " .. countNodes(node) .. " nodes")
    return node
end

____exports.parse = parse

function parseNode(c, depth)
    ____exports.parsedNodes = ____exports.parsedNodes + 1
    if depth > ____exports.maxDepth then
        ____exports.maxDepth = depth
    end
    local tok = c:next()
    if tok == "(" then
        local items = __K2L_ListOf()
        while c:peek() ~= ")" do
            items:add(parseNode(c, depth + 1))
        end
        c:next()
        return Node.Call.new(items)
    end
    local ____receiver = __K2L_StringToIntOrNull(tok)
    return ____receiver and Node.Num.new(____receiver) or Node.Sym.new(tok, ____Eval.isBuiltin(tok))
end

function countNodes(n)
    if getmetatable(n) == Node.Call then
        local ____list_2 = n.items
        local ____sum = 0
        local ____items_2, ____n_2 = ____list_2:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____sum = ____sum + countNodes(it)
        end
        return 1 + ____sum
    else
        return 1
    end
end

____exports.countNodes = countNodes

local function run(src)
    return ____Eval.evaluate(parse(src), __K2L_MapOf())
end

____exports.run = run
__K2L_LazyFile(____exports, function()
    ____exports.keywords = __K2L_SetOf("let", "if", "quote")
    local ____list = ____Eval.builtins:getKeys()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if #it == 1 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    ____exports.operatorSymbols = __K2L_ListWrap(____out, ____count)
    ____exports.parsedNodes = 0
    ____exports.maxDepth = 0
end, {"keywords", "operatorSymbols", "parsedNodes", "maxDepth"})
return ____exports
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Unit = ____lualib.__K2L_Unit

local ____exports = {}
package.loaded.main = ____exports
local ____Eval = require("eval.Eval")
local ____Parser = require("lang.Parser")
local ____Report = require("report.Report")
____exports.traceCount = 0
local traces = __K2L_ListOf()
____exports.traces = traces

local function trace(msg)
    ____exports.traceCount = ____exports.traceCount + 1
    traces:add(msg)
end

____exports.trace = trace

local function show(v)
    local ____mt = getmetatable(v)
    if ____mt == ____Eval.Value.I then
        return tostring(v.n)
    elseif ____mt == ____Eval.Value.Q then
        return "'" .. __K2L_Str(v.node)
    end
end

____exports.show = show

local ____lambda_1 = function(xs) return xs:get(0) * xs:get(0) end
local ____lambda_2 = function(it) return 0 end
local ____lambda_3 = function() return ____Parser.run("(nope 1)") end
local function main()
    print("keywords " .. __K2L_Str(____Parser.keywords) .. " reserved " .. __K2L_Str(____Eval.reserved))
    print(__K2L_Str(____Eval.builtins:getKeys()) .. " operators " .. __K2L_Str(____Parser.operatorSymbols))
    print(show(____Parser.run("(+ 1 2 (* 3 4))")))
    print(show(____Parser.run("(let x 5 (- x 1 1))")))
    print(show(____Parser.run("(quote (a b))")))
    print(____Report.Stats:line())
    ____Report.resetDepth()
    ____Eval.define("sq", ____lambda_1)
    print(show(____Parser.run("(sq (max 3 9 4))")))
    print(show(____Parser.run("(eval [+_2_[sq_3]])")))
    local ____receiver = __K2L_RunCatching(function()
        ____Eval.define("let", ____lambda_2)
        return __K2L_Unit
    end):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    local ____receiver_1 = __K2L_RunCatching(____lambda_3):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    print(____Report.Stats:line())
    print("traces " .. ____exports.traceCount .. ":")
    local ____list = traces
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
end

if ... ~= "main" then
    __K2L_RunMain(main)
end
return ____exports
-- ==== report/Report.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class

local ____exports = {}
package.loaded["report.Report"] = ____exports
local ____Parser = require("lang.Parser")
local ____Eval = require("eval.Eval")
local ____main = require("main")
local Stats = __K2L_Class("calc.report.Stats")

function Stats:____init()
    self.reports = 0
end

function Stats:line()
    self.reports = self.reports + 1
    return "report#" .. self.reports .. " nodes=" .. ____Parser.parsedNodes .. " evals=" .. ____Eval.evaluations .. " depth=" .. ____Parser.maxDepth .. " traces=" .. ____main.traceCount
end

Stats:____init()
____exports.Stats = Stats

local function resetDepth()
    ____Parser.maxDepth = 0
end

____exports.resetDepth = resetDepth
return ____exports
