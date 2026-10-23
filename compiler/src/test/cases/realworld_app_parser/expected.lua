local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsWhitespace = ____lualib.__K2L_IsWhitespace
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate
local __K2L_Unit = ____lualib.__K2L_Unit

local term, factor, json
local Input = __K2L_Class("parsing.Input")

function Input.new(text, pos)
    if pos == nil then
        pos = 0
    end
    return setmetatable({text = text, pos = pos}, Input)
end

function Input:getAtEnd()
    return self.pos >= #self.text
end

function Input:peek()
    return __K2L_Text.getOrNull(self.text, self.pos)
end

function Input:advance(n)
    if n == nil then
        n = 1
    end
    return Input.new(self.text, self.pos + n)
end

function Input:toString()
    return self:getAtEnd() and "<end>" or "'" .. __K2L_Text.take(__K2L_Text.substring(self.text, self.pos), 8) .. "'@" .. self.pos
end

__K2L_DataClass(Input, {"text", "pos"})
local ParseResult = __K2L_Class("parsing.ParseResult")
ParseResult.Success = __K2L_Class("parsing.ParseResult$Success", ParseResult)

function ParseResult.Success.new(value, rest)
    return setmetatable({value = value, rest = rest}, ParseResult.Success)
end

__K2L_DataClass(ParseResult.Success, {"value", "rest"})
ParseResult.Failure = __K2L_Class("parsing.ParseResult$Failure", ParseResult)

function ParseResult.Failure.new(expected, at)
    return setmetatable({expected = expected, at = at}, ParseResult.Failure)
end

__K2L_DataClass(ParseResult.Failure, {"expected", "at"})

function ParseResult:fold(onSuccess, onFailure)
    local ____mt = getmetatable(self)
    if ____mt == ParseResult.Success then
        return onSuccess(self.value, self.rest)
    elseif ____mt == ParseResult.Failure then
        return onFailure(self.expected, self.at)
    end
end

local Parser = __K2L_Class("parsing.Parser")

function Parser:pure(value)
    return __K2L_FunInterface(Parser, "parse", function(it) return ParseResult.Success.new(value, it) end)
end

function Parser:fail(expected)
    return __K2L_FunInterface(Parser, "parse", function(it)
        return ParseResult.Failure.new(expected, it)
    end)
end

local function map(self, f)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local r = self:parse(input)
        local ____mt_1 = getmetatable(r)
        if ____mt_1 == ParseResult.Success then
            return ParseResult.Success.new(f(r.value), r.rest)
        elseif ____mt_1 == ParseResult.Failure then
            return r
        end
    end)
end

local function flatMap(____this, f)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local r = ____this:parse(input)
        local ____mt_2 = getmetatable(r)
        if ____mt_2 == ParseResult.Success then
            return f(r.value):parse(r.rest)
        elseif ____mt_2 == ParseResult.Failure then
            return r
        end
    end)
end

local function ____or(____this_1, other)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local a = ____this_1:parse(input)
        local ____mt_3 = getmetatable(a)
        if ____mt_3 == ParseResult.Success then
            return a
        elseif ____mt_3 == ParseResult.Failure then
            local b = other:parse(input)
            local ____mt_4 = getmetatable(b)
            if ____mt_4 == ParseResult.Success then
                return b
            elseif ____mt_4 == ParseResult.Failure then
                return a.at.pos >= b.at.pos and a or b
            end
        end
    end)
end

local function ____then(____this_2, ____next)
    return flatMap(____this_2, function(a)
        return map(____next, function(b) return __K2L_Pair.new(a, b) end)
    end)
end

local function skipThen(____this_3, ____next)
    return flatMap(____this_3, function(it) return ____next end)
end

local function thenSkip(____this_4, ____next)
    return flatMap(____this_4, function(a)
        return map(____next, function(it) return a end)
    end)
end

local function many(____this_5)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local items = __K2L_ListOf()
        local current = input
        while true do
            local r = ____this_5:parse(current)
            if getmetatable(r) ~= ParseResult.Success or r.rest.pos == current.pos then
                break
            end
            items:add(r.value)
            current = r.rest
        end
        return ParseResult.Success.new(items, current)
    end)
end

local function many1(____this_6)
    return map(____then(____this_6, many(____this_6)), function(____destructured)
        local h, t = ____destructured.first, ____destructured.second
        return __K2L_ListOf(h):plusAll(t)
    end)
end

local ____lambda_1 = function(it) return it end
local function optional(____this_7)
    return ____or(map(____this_7, ____lambda_1), Parser:pure(nil))
end

local function sepBy(____this_8, sep)
    return ____or(map(____then(____this_8, many(skipThen(sep, ____this_8))), function(____destructured_1)
        local h, t = ____destructured_1.first, ____destructured_1.second
        return __K2L_ListOf(h):plusAll(t)
    end), Parser:pure(__K2L_ListOf()))
end

local function named(____this_9, name)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local r = ____this_9:parse(input)
        local ____mt_5 = getmetatable(r)
        if ____mt_5 == ParseResult.Success then
            return r
        elseif ____mt_5 == ParseResult.Failure then
            return ParseResult.Failure.new(r.at.pos == input.pos and name or r.expected, r.at)
        end
    end)
end

local function lazyParser(block)
    local ____p_delegate = __K2L_Lazy(block)
    return __K2L_FunInterface(Parser, "parse", function(it) return ____p_delegate:getValue():parse(it) end)
end

local function satisfy(what, test)
    return __K2L_FunInterface(Parser, "parse", function(input)
        local c = input:peek()
        return c ~= nil and test(c) and ParseResult.Success.new(c, input:advance()) or ParseResult.Failure.new(what, input)
    end)
end

local function char(c)
    return satisfy("'" .. c .. "'", function(it) return it == c end)
end

local ws = map(many(satisfy("space", function(it) return __K2L_IsWhitespace[it] == true end)), function(it) return __K2L_Unit end)

local function token(p)
    return thenSkip(p, ws)
end

local function symbol(s)
    return token(__K2L_FunInterface(Parser, "parse", function(input)
        return input.text:sub(input.pos + 1, input.pos + #s) == s and ParseResult.Success.new(s, input:advance(#s)) or ParseResult.Failure.new("\"" .. s .. "\"", input)
    end))
end

local digit = satisfy("digit", function(it) return __K2L_IsDigit[it] == true end)
local number = named(token(map(____then(many1(digit), optional(skipThen(char("."), many1(digit)))), function(____destructured_2)
    local whole, frac = ____destructured_2.first, ____destructured_2.second
    return __K2L_StringToDouble(whole:joinToString("") .. (frac and "." .. frac:joinToString("") or ""))
end)), "number")
local identifier = named(token(map(____then(satisfy("letter", function(it) return __K2L_IsLetter[it] == true end), many(satisfy("letter or digit", function(it)
    return __K2L_IsLetterOrDigit[it] == true or it == "_"
end))), function(____destructured_3)
    local h, t = ____destructured_3.first, ____destructured_3.second
    return h .. t:joinToString("")
end)), "identifier")
local Expr = __K2L_Class("parsing.Expr")
Expr.Num = __K2L_Class("parsing.Expr$Num", nil, Expr)

function Expr.Num.new(v)
    return setmetatable({v = v}, Expr.Num)
end

__K2L_DataClass(Expr.Num, {"v"})
Expr.Var = __K2L_Class("parsing.Expr$Var", nil, Expr)

function Expr.Var.new(name)
    return setmetatable({name = name}, Expr.Var)
end

__K2L_DataClass(Expr.Var, {"name"})
Expr.Bin = __K2L_Class("parsing.Expr$Bin", nil, Expr)

function Expr.Bin.new(op, l, r)
    return setmetatable({op = op, l = l, r = r}, Expr.Bin)
end

__K2L_DataClass(Expr.Bin, {"op", "l", "r"})
Expr.Neg = __K2L_Class("parsing.Expr$Neg", nil, Expr)

function Expr.Neg.new(e)
    return setmetatable({e = e}, Expr.Neg)
end

__K2L_DataClass(Expr.Neg, {"e"})
Expr.Call = __K2L_Class("parsing.Expr$Call", nil, Expr)

function Expr.Call.new(fn, args)
    return setmetatable({fn = fn, args = args}, Expr.Call)
end

__K2L_DataClass(Expr.Call, {"fn", "args"})

local function chainLeft(operand, ops)
    return map(____then(operand, many(____then(token(satisfy("operator", function(it) return __K2L_StringContains(ops, it) end)), operand))), function(____destructured_4)
        local first, rest = ____destructured_4.first, ____destructured_4.second
        return rest:fold(first, function(acc, ____destructured_5)
            local op, r = ____destructured_5.first, ____destructured_5.second
            return Expr.Bin.new(op, acc, r)
        end)
    end)
end

local expr = lazyParser(function() return chainLeft(term, "+-") end)
term = lazyParser(function() return chainLeft(factor, "*/%") end)

local ____lambda_2 = function(it) return Expr.Num.new(it) end
local ____lambda_3 = function(it) return Expr.Neg.new(it) end
factor = lazyParser(function()
    local call = map(____then(identifier, optional(thenSkip(skipThen(symbol("("), sepBy(expr, symbol(","))), symbol(")")))), function(____destructured_6)
        local name, args = ____destructured_6.first, ____destructured_6.second
        return args == nil and Expr.Var.new(name) or Expr.Call.new(name, args)
    end)
    return ____or(____or(____or(map(number, ____lambda_2), call), map(skipThen(symbol("-"), factor), ____lambda_3)), thenSkip(skipThen(symbol("("), expr), symbol(")")))
end)

local EvalException = __K2L_Class("parsing.EvalException", __K2L_Exception)

function EvalException:____init(message)
    __K2L_Exception.____init(self, message)
end

local function eval(e, env)
    local ____mt_6 = getmetatable(e)
    if ____mt_6 == Expr.Num then
        return e.v
    elseif ____mt_6 == Expr.Var then
        local ____value_1 = env:get(e.name)
        if ____value_1 == nil then
            error(EvalException.new("unknown variable " .. e.name))
        end
        return ____value_1
    elseif ____mt_6 == Expr.Neg then
        return -eval(e.e, env)
    elseif ____mt_6 == Expr.Bin then
        local ____destructured_7 = __K2L_Pair.new(eval(e.l, env), eval(e.r, env))
        local l, r = ____destructured_7.first, ____destructured_7.second
        local ____subject_1 = e.op
        if ____subject_1 == "+" then
            return l + r
        elseif ____subject_1 == "-" then
            return l - r
        elseif ____subject_1 == "*" then
            return l * r
        elseif ____subject_1 == "/" then
            if r == 0.0 then
                error(EvalException.new("division by zero"))
            else
                return l / r
            end
        else
            return l % r
        end
    elseif ____mt_6 == Expr.Call then
        local ____list = e.args
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = eval(it, env)
        end
        local args = __K2L_ListWrap(____out, ____count)
        local ____subject = e.fn
        if ____subject == "max" then
            local ____value = args:maxOrNull()
            if ____value == nil then
                error(EvalException.new("max of nothing"))
            end
            return ____value
        elseif ____subject == "min" then
            return args:min()
        elseif ____subject == "sum" then
            return args:sum(0.0)
        else
            error(EvalException.new("unknown function " .. e.fn .. "/" .. args.size))
        end
    end
end

local function show(e)
    local ____mt_7 = getmetatable(e)
    if ____mt_7 == Expr.Num then
        return e.v % 1.0 == 0.0 and tostring(__K2L_Truncate(e.v)) or tostring(e.v)
    elseif ____mt_7 == Expr.Var then
        return e.name
    elseif ____mt_7 == Expr.Neg then
        return "-" .. show(e.e)
    elseif ____mt_7 == Expr.Bin then
        return "(" .. show(e.l) .. " " .. e.op .. " " .. show(e.r) .. ")"
    elseif ____mt_7 == Expr.Call then
        return e.fn .. "(" .. e.args:joinToString(", ", nil, nil, nil, nil, show) .. ")"
    end
end

local ____lambda_4 = function(v)
    return __K2L_FunInterface(Parser, "parse", function(input)
        return input:getAtEnd() and ParseResult.Success.new(v, input) or ParseResult.Failure.new("end of input", input)
    end)
end
local function parseAll(____this_10, text)
    return flatMap(skipThen(ws, ____this_10), ____lambda_4):parse(Input.new(text))
end

local Json = __K2L_Class("parsing.Json")
Json.Str = __K2L_Class("parsing.Json$Str", Json)

function Json.Str.new(s)
    return setmetatable({s = s}, Json.Str)
end

__K2L_DataClass(Json.Str, {"s"})
Json.Num = __K2L_Class("parsing.Json$Num", Json)

function Json.Num.new(n)
    return setmetatable({n = n}, Json.Num)
end

__K2L_DataClass(Json.Num, {"n"})
Json.Arr = __K2L_Class("parsing.Json$Arr", Json)

function Json.Arr.new(items)
    return setmetatable({items = items}, Json.Arr)
end

__K2L_DataClass(Json.Arr, {"items"})
Json.Obj = __K2L_Class("parsing.Json$Obj", Json)

function Json.Obj.new(fields)
    return setmetatable({fields = fields}, Json.Obj)
end

__K2L_DataClass(Json.Obj, {"fields"})
Json.Null = __K2L_Class("parsing.Json$Null", Json)

local ____lambda_5 = function(it) return it:render() end
function Json:render()
    local ____mt_8 = getmetatable(self)
    if ____mt_8 == Json.Str then
        return "\"" .. self.s .. "\""
    elseif ____mt_8 == Json.Num then
        return self.n % 1.0 == 0.0 and tostring(__K2L_Truncate(self.n)) or tostring(self.n)
    elseif ____mt_8 == Json.Arr then
        return self.items:joinToString(",", "[", "]", nil, nil, ____lambda_5)
    elseif ____mt_8 == Json.Obj then
        return self.fields:getEntries():joinToString(",", "{", "}", nil, nil, function(____destructured_8)
            local k, v = ____destructured_8.key, ____destructured_8.value
            return "\"" .. k .. "\":" .. v:render()
        end)
    elseif __K2L_Equals(self, Json.Null) then
        return "null"
    end
end

local jsonString = named(map(token(thenSkip(skipThen(char("\""), many(satisfy("character", function(it) return it ~= "\"" end))), char("\""))), function(it) return it:joinToString("") end), "string")

local ____lambda_6 = function(it) return Json.Str.new(it) end
local ____lambda_7 = function(it) return Json.Num.new(it) end
local ____lambda_8 = function(it) return Json.Arr.new(it) end
local ____lambda_9 = function(it) return Json.Obj.new(it:toMap()) end
local ____lambda_10 = function(it) return Json.Null end
json = lazyParser(function()
    local arr = thenSkip(skipThen(symbol("["), sepBy(json, symbol(","))), symbol("]"))
    local field = ____then(thenSkip(jsonString, symbol(":")), json)
    local obj = thenSkip(skipThen(symbol("{"), sepBy(field, symbol(","))), symbol("}"))
    return ____or(____or(____or(____or(map(jsonString, ____lambda_6), map(number, ____lambda_7)), map(arr, ____lambda_8)), map(obj, ____lambda_9)), map(symbol("null"), ____lambda_10))
end)

local ____lambda_11 = function(expected, at)
    return "syntax error: expected " .. expected .. " at " .. __K2L_Str(at)
end
local ____lambda_12 = function(v, _) return v:render() end
local ____lambda_13 = function(exp, at)
    return "error: expected " .. exp .. " at " .. __K2L_Str(at)
end
local ____lambda_14 = function(it) return it * 2 end
local function main()
    local env = __K2L_MapOf(__K2L_Pair.new("x", 3.0), __K2L_Pair.new("y", 4.0), __K2L_Pair.new("rate", 0.5))
    local inputs = __K2L_ListOf("1 + 2 * 3", "(1 + 2) * 3", "x * x + y * y", "-x + 10 / 4", "max(x, y, 2) * rate", "sum(1, 2, 3, 4) % 3", "min()", "unknown + 1", "foo(1)", "7 / (y - 4)", "2 *", "(1 + 2", "3 $ 4", "  12.5  ")
    for ____i_1 = 1, inputs.size do
        local text = inputs[____i_1]
        local line = parseAll(expr, text):fold(function(e, _)
            local ____ok, ____result, ____returned = pcall(function()
                return true, show(e) .. " = " .. eval(e, env)
            end)
            if ____ok then
                if ____result then
                    return ____returned
                end
            else
                local ____error = __K2L_ToThrowable(____result)
                if getmetatable(____error) == EvalException then
                    local ex = ____error
                    return show(e) .. " fails: " .. __K2L_Str(ex.message)
                elseif __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
                    local ex = ____error
                    return show(e) .. " fails: " .. __K2L_Str(__K2L_SimpleName(ex))
                else
                    error(____error, 0)
                end
            end
        end, ____lambda_11)
        print(text .. "  =>  " .. line)
    end
    local docs = __K2L_ListOf("{\"name\": \"k2l\", \"tags\": [\"lua\", \"kotlin\"], \"stars\": 42, \"meta\": {\"license\": null}}", "[1, 2.5, [], {}]", "{\"a\": [1, 2,]}", "{\"unterminated\": \"abc")
    for ____i_2 = 1, docs.size do
        local d = docs[____i_2]
        print(parseAll(json, d):fold(____lambda_12, ____lambda_13))
    end
    local r = parseAll(json, "{\"k\": [1, 2, 3]}")
    if getmetatable(r) == ParseResult.Success then
        local ____cast = r.value
        if getmetatable(____cast) ~= Json.Obj then
            __K2L_CastFail(____cast, "parsing.Json.Obj")
        end
        local ____cast_1 = ____cast.fields:get("k")
        if getmetatable(____cast_1) ~= Json.Arr then
            __K2L_CastFail(____cast_1, "parsing.Json.Arr")
        end
        local items = ____cast_1.items
        local ____arg = items.size
        local ____sum = 0.0
        local ____items_1, ____n_1 = items:____array()
        for ____i_3 = 1, ____n_1 do
            local it = ____items_1[____i_3]
            local ____result_1
            if getmetatable(it) ~= Json.Num then
                __K2L_CastFail(it, "parsing.Json.Num")
            end
            ____result_1 = it.n
            ____sum = ____sum + ____result_1
        end
        print("k has " .. ____arg .. " items, sum " .. ____sum)
    end
    print(__K2L_Str(map(Parser:pure(5), ____lambda_14):parse(Input.new("rest"))))
    print(__K2L_Str(Parser:fail("nothing"):parse(Input.new(""))))
    print(__K2L_Str(many(____or(char("a"), char("b"))):parse(Input.new("abbac"))))
end

__K2L_RunMain(main)
return {Input = Input, ParseResult = ParseResult, Parser = Parser, map = map, flatMap = flatMap, ____or = ____or, ____then = ____then, skipThen = skipThen, thenSkip = thenSkip, many = many, many1 = many1, optional = optional, sepBy = sepBy, named = named, lazyParser = lazyParser, satisfy = satisfy, char = char, ws = ws, token = token, symbol = symbol, digit = digit, number = number, identifier = identifier, Expr = Expr, chainLeft = chainLeft, expr = expr, term = term, factor = factor, EvalException = EvalException, eval = eval, show = show, parseAll = parseAll, Json = Json, jsonString = jsonString, json = json}
