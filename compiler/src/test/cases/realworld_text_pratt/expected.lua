local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local Kind = __K2L_Class("Kind")
__K2L_ClassInfo(Kind, "Kind", "Kind", "class")

function Kind:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Kind:toString()
    return self.name
end

function Kind:compareTo(other)
    return self.ordinal - other.ordinal
end

Kind.NUM = Kind.new("NUM", 0)
Kind.IDENT = Kind.new("IDENT", 1)
Kind.OP = Kind.new("OP", 2)
Kind.LPAREN = Kind.new("LPAREN", 3)
Kind.RPAREN = Kind.new("RPAREN", 4)
Kind.COMMA = Kind.new("COMMA", 5)
Kind.QUESTION = Kind.new("QUESTION", 6)
Kind.COLON = Kind.new("COLON", 7)
Kind.EOF = Kind.new("EOF", 8)
Kind.____values = {Kind.NUM, Kind.IDENT, Kind.OP, Kind.LPAREN, Kind.RPAREN, Kind.COMMA, Kind.QUESTION, Kind.COLON, Kind.EOF}
local Token = __K2L_Class("Token")
__K2L_ClassInfo(Token, "Token", "Token", "class")

function Token:____init(kind, text, pos)
    self.kind = kind
    self.text = text
    self.pos = pos
end

function Token.new(kind, text, pos)
    return setmetatable({kind = kind, text = text, pos = pos}, Token)
end

function Token:toString()
    return self.kind == Kind.EOF and "EOF@" .. self.pos or __K2L_Str(self.kind) .. "('" .. self.text .. "')@" .. self.pos
end

function Token:hashCode()
    return (31 * (31 * __K2L_Hash(self.kind) + __K2L_Hash(self.text)) + self.pos + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Token:equals(other)
    return getmetatable(other) == Token and self.kind == other.kind and self.text == other.text and self.pos == other.pos
end

local ParseError = __K2L_Class("ParseError", __K2L_RuntimeException)
__K2L_ClassInfo(ParseError, "ParseError", "ParseError", "class")

function ParseError:____init(message, pos)
    __K2L_RuntimeException.____init(self, message)
    self.pos = pos
end

local function tokenize(src)
    local out = __K2L_List.new()
    local i = 0
    local twoCharOps = __K2L_ReadOnlySetOf("<=", ">=", "==", "!=", "&&", "||", "**")
    while i < __K2L_Utf16.len(src) do
        local c = __K2L_Text.get(src, i)
        if __K2L_Utf16Case.isWhitespace(c) then
            i = i + 1
        elseif __K2L_Utf16Case.isDigit(c) or c == "." and i + 1 < __K2L_Utf16.len(src) and __K2L_Utf16Case.isDigit(__K2L_Text.get(src, i + 1)) then
            local start = i
            while i < __K2L_Utf16.len(src) and (__K2L_Utf16Case.isDigit(__K2L_Text.get(src, i)) or __K2L_Text.get(src, i) == "." or __K2L_Text.get(src, i) == "_") do
                i = i + 1
            end
            if i < __K2L_Utf16.len(src) and (__K2L_Text.get(src, i) == "e" or __K2L_Text.get(src, i) == "E") then
                i = i + 1
                if i < __K2L_Utf16.len(src) and (__K2L_Text.get(src, i) == "+" or __K2L_Text.get(src, i) == "-") then
                    i = i + 1
                end
                while i < __K2L_Utf16.len(src) and __K2L_Utf16Case.isDigit(__K2L_Text.get(src, i)) do
                    i = i + 1
                end
            end
            out:add(Token.new(Kind.NUM, __K2L_StringReplace(__K2L_Text.substring(src, start, i), "_", ""), start))
        elseif __K2L_Utf16Case.isLetter(c) or c == "_" then
            local start = i
            while i < __K2L_Utf16.len(src) and (__K2L_Utf16Case.isLetterOrDigit(__K2L_Text.get(src, i)) or __K2L_Text.get(src, i) == "_") do
                i = i + 1
            end
            out:add(Token.new(Kind.IDENT, __K2L_Text.substring(src, start, i), start))
        elseif c == "(" then
            local ____arg_5 = Kind.LPAREN
            local ____old_5 = i
            i = i + 1
            out:add(Token.new(____arg_5, "(", ____old_5))
        elseif c == ")" then
            local ____arg_4 = Kind.RPAREN
            local ____old_4 = i
            i = i + 1
            out:add(Token.new(____arg_4, ")", ____old_4))
        elseif c == "," then
            local ____arg_3 = Kind.COMMA
            local ____old_3 = i
            i = i + 1
            out:add(Token.new(____arg_3, ",", ____old_3))
        elseif c == "?" then
            local ____arg_2 = Kind.QUESTION
            local ____old_2 = i
            i = i + 1
            out:add(Token.new(____arg_2, "?", ____old_2))
        elseif c == ":" then
            local ____arg_1 = Kind.COLON
            local ____old_1 = i
            i = i + 1
            out:add(Token.new(____arg_1, ":", ____old_1))
        elseif i + 1 < __K2L_Utf16.len(src) and twoCharOps:contains(__K2L_Text.substring(src, i, i + 2)) then
            out:add(Token.new(Kind.OP, __K2L_Text.substring(src, i, i + 2), i))
            i = i + 2
        elseif __K2L_Text.contains("+-*/%^<>!", c) then
            local ____arg = Kind.OP
            local ____old = i
            i = i + 1
            out:add(Token.new(____arg, c, ____old))
        else
            error(ParseError.new(__K2L_Utf16.norm("unexpected character '" .. c .. "' (U+" .. __K2L_Text.padStart(__K2L_Utf16Case.uppercase(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16)), 4, "0") .. ")"), i))
        end
    end
    out:add(Token.new(Kind.EOF, "", __K2L_Utf16.len(src)))
    return out
end

local Expr = __K2L_Class("Expr")
__K2L_ClassInfo(Expr, "Expr", "Expr", "interface")
local Num = __K2L_Class("Num", nil, Expr)
__K2L_ClassInfo(Num, "Num", "Num", "class")

function Num:____init(v)
    self.v = v
end

function Num.new(v)
    return setmetatable({v = v}, Num)
end

function Num:toString()
    return "Num(v=" .. __K2L_Str(self.v) .. ")"
end

function Num:hashCode()
    return __K2L_Hash(self.v)
end

function Num:equals(other)
    return getmetatable(other) == Num and self.v == other.v
end

local Var = __K2L_Class("Var", nil, Expr)
__K2L_ClassInfo(Var, "Var", "Var", "class")

function Var:____init(name)
    self.name = name
end

function Var.new(name)
    return setmetatable({name = name}, Var)
end

function Var:toString()
    return "Var(name=" .. self.name .. ")"
end

function Var:hashCode()
    return __K2L_Hash(self.name)
end

function Var:equals(other)
    return getmetatable(other) == Var and self.name == other.name
end

local Unary = __K2L_Class("Unary", nil, Expr)
__K2L_ClassInfo(Unary, "Unary", "Unary", "class")

function Unary:____init(op, e)
    self.op = op
    self.e = e
end

function Unary.new(op, e)
    return setmetatable({op = op, e = e}, Unary)
end

function Unary:toString()
    return "Unary(op=" .. self.op .. ", e=" .. __K2L_Str(self.e) .. ")"
end

function Unary:hashCode()
    return (31 * __K2L_Hash(self.op) + __K2L_Hash(self.e) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Unary:equals(other)
    return getmetatable(other) == Unary and self.op == other.op and __K2L_Equals(self.e, other.e)
end

local Binary = __K2L_Class("Binary", nil, Expr)
__K2L_ClassInfo(Binary, "Binary", "Binary", "class")

function Binary:____init(op, l, r)
    self.op = op
    self.l = l
    self.r = r
end

function Binary.new(op, l, r)
    return setmetatable({op = op, l = l, r = r}, Binary)
end

function Binary:toString()
    return "Binary(op=" .. self.op .. ", l=" .. __K2L_Str(self.l) .. ", r=" .. __K2L_Str(self.r) .. ")"
end

function Binary:hashCode()
    return (31 * (31 * __K2L_Hash(self.op) + __K2L_Hash(self.l)) + __K2L_Hash(self.r) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Binary:equals(other)
    return getmetatable(other) == Binary and self.op == other.op and __K2L_Equals(self.l, other.l) and __K2L_Equals(self.r, other.r)
end

local Call = __K2L_Class("Call", nil, Expr)
__K2L_ClassInfo(Call, "Call", "Call", "class")

function Call:____init(fn, args)
    self.fn = fn
    self.args = args
end

function Call.new(fn, args)
    return setmetatable({fn = fn, args = args}, Call)
end

function Call:toString()
    return "Call(fn=" .. self.fn .. ", args=" .. __K2L_Str(self.args) .. ")"
end

function Call:hashCode()
    return (31 * __K2L_Hash(self.fn) + __K2L_Hash(self.args) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Call:equals(other)
    return getmetatable(other) == Call and self.fn == other.fn and __K2L_Equals(self.args, other.args)
end

local Cond = __K2L_Class("Cond", nil, Expr)
__K2L_ClassInfo(Cond, "Cond", "Cond", "class")

function Cond:____init(c, t, f)
    self.c = c
    self.t = t
    self.f = f
end

function Cond.new(c, t, f)
    return setmetatable({c = c, t = t, f = f}, Cond)
end

function Cond:toString()
    return "Cond(c=" .. __K2L_Str(self.c) .. ", t=" .. __K2L_Str(self.t) .. ", f=" .. __K2L_Str(self.f) .. ")"
end

function Cond:hashCode()
    return (31 * (31 * __K2L_Hash(self.c) + __K2L_Hash(self.t)) + __K2L_Hash(self.f) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Cond:equals(other)
    return getmetatable(other) == Cond and __K2L_Equals(self.c, other.c) and __K2L_Equals(self.t, other.t) and __K2L_Equals(self.f, other.f)
end

local Pratt = __K2L_Class("Pratt")
__K2L_ClassInfo(Pratt, "Pratt", "Pratt", "class")

function Pratt:____init(tokens)
    self.tokens = tokens
    self.p = 0
end

function Pratt:peek()
    return self.tokens:get(self.p)
end

function Pratt:next()
    local ____arg_6 = self.tokens
    local ____old_6 = self.p
    self.p = self.p + 1
    return ____arg_6:get(____old_6)
end

function Pratt:infixPower(op)
    if op == "||" then
        return __K2L_Pair.new(1, 2)
    elseif op == "&&" then
        return __K2L_Pair.new(3, 4)
    elseif op == "==" or op == "!=" then
        return __K2L_Pair.new(5, 6)
    elseif op == "<" or op == ">" or op == "<=" or op == ">=" then
        return __K2L_Pair.new(7, 8)
    elseif op == "+" or op == "-" then
        return __K2L_Pair.new(9, 10)
    elseif op == "*" or op == "/" or op == "%" then
        return __K2L_Pair.new(11, 12)
    elseif op == "**" or op == "^" then
        return __K2L_Pair.new(16, 15)
    else
        return nil
    end
end

function Pratt:parseAll()
    local e = self:expr(0)
    if self:peek().kind ~= Kind.EOF then
        error(ParseError.new("unexpected " .. __K2L_Text.ifEmpty(self:peek().text, function() return self:peek().kind.name end), self:peek().pos))
    end
    return e
end

function Pratt:expr(minBp)
    local t = self:next()
    local lhs
    local ____subject = t.kind
    if ____subject == Kind.NUM then
        local ____value_1 = __K2L_StringToDoubleOrNull(t.text)
        if ____value_1 == nil then
            error(ParseError.new("malformed number '" .. t.text .. "'", t.pos))
        end
        lhs = Num.new(____value_1)
    elseif ____subject == Kind.IDENT then
        lhs = self:peek().kind == Kind.LPAREN and self:call(t) or Var.new(t.text)
    elseif ____subject == Kind.LPAREN then
        local ____value = self:expr(0)
        self:expect(Kind.RPAREN, "')'")
        lhs = ____value
    elseif ____subject == Kind.OP then
        if t.text == "-" or t.text == "!" or t.text == "+" then
            lhs = Unary.new(t.text, self:expr(13))
        else
            error(ParseError.new("operator '" .. t.text .. "' needs a left operand", t.pos))
        end
    elseif ____subject == Kind.EOF then
        error(ParseError.new("unexpected end of input", t.pos))
    else
        error(ParseError.new("unexpected '" .. t.text .. "'", t.pos))
    end
    while true do
        do
            local op = self:peek()
            if op.kind == Kind.QUESTION then
                if minBp > 0 then
                    break
                end
                self:next()
                local a = self:expr(0)
                self:expect(Kind.COLON, "':'")
                local b = self:expr(0)
                lhs = Cond.new(lhs, a, b)
                goto ____continue
            end
            if op.kind ~= Kind.OP then
                break
            end
            local ____value_2 = self:infixPower(op.text)
            if ____value_2 == nil then
                error(ParseError.new("unknown operator '" .. op.text .. "'", op.pos))
            end
            local l, r = ____value_2.first, ____value_2.second
            if l < minBp then
                break
            end
            self:next()
            lhs = Binary.new(op.text, lhs, self:expr(r))
        end
        ::____continue::
    end
    return lhs
end

function Pratt:call(name)
    self:expect(Kind.LPAREN, "'('")
    local args = __K2L_ListOf()
    if self:peek().kind ~= Kind.RPAREN then
        repeat
            args:add(self:expr(0))
        until not (self:peek().kind == Kind.COMMA and self:next().kind == Kind.COMMA)
    end
    self:expect(Kind.RPAREN, "')' after arguments of " .. name.text)
    return Call.new(name.text, args)
end

function Pratt:expect(kind, what)
    local t = self:next()
    if t.kind ~= kind then
        error(ParseError.new("expected " .. what .. " but got " .. (t.kind == Kind.EOF and "end of input" or "'" .. t.text .. "'"), t.pos))
    end
end

local function show(e)
    local ____mt = getmetatable(e)
    if ____mt == Num then
        return math.fmod(e.v, 1.0) == 0.0 and tostring(__K2L_DoubleToLong(e.v)) or __K2L_Str(e.v)
    elseif ____mt == Var then
        return e.name
    elseif ____mt == Unary then
        return "(" .. e.op .. show(e.e) .. ")"
    elseif ____mt == Binary then
        return "(" .. show(e.l) .. " " .. e.op .. " " .. show(e.r) .. ")"
    elseif ____mt == Call then
        return e.fn .. __K2L_Utf16.norm(e.args:joinToString(", ", "(", ")", nil, nil, function(it) return show(it) end))
    elseif ____mt == Cond then
        return "(" .. show(e.c) .. " ? " .. show(e.t) .. " : " .. show(e.f) .. ")"
    end
end

local functions = __K2L_ReadOnlyMapOf(__K2L_Pair.new("max", function(a) return a:maxOrNull() or 0.0 / 0.0 end), __K2L_Pair.new("min", function(a) return a:minOrNull() or 0.0 / 0.0 end), __K2L_Pair.new("sqrt", function(a) return math.sqrt(a:single()) end), __K2L_Pair.new("abs", function(a) return math.abs(a:single()) end), __K2L_Pair.new("hypot", function(a) return __K2L_Num.hypot(a:get(0), a:get(1)) end), __K2L_Pair.new("avg", function(a) return a:average() end))

local function eval(e, env)
    local ____mt_1 = getmetatable(e)
    if ____mt_1 == Num then
        return e.v
    elseif ____mt_1 == Var then
        local ____value_4 = env:get(e.name)
        if ____value_4 == nil then
            error(__K2L_IllegalArgumentException.new("unknown variable '" .. e.name .. "'"))
        end
        return ____value_4
    elseif ____mt_1 == Unary then
        local ____subject_3 = e.op
        if ____subject_3 == "-" then
            return -eval(e.e, env)
        elseif ____subject_3 == "!" then
            return eval(e.e, env) == 0.0 and 1.0 or 0.0
        else
            return eval(e.e, env)
        end
    elseif ____mt_1 == Binary then
        local a = eval(e.l, env)
        local ____subject_1 = e.op
        if ____subject_1 == "&&" then
            return a ~= 0.0 and eval(e.r, env) ~= 0.0 and 1.0 or 0.0
        elseif ____subject_1 == "||" then
            return (a ~= 0.0 or eval(e.r, env) ~= 0.0) and 1.0 or 0.0
        else
            local b = eval(e.r, env)
            local ____subject_2 = e.op
            if ____subject_2 == "+" then
                return a + b
            elseif ____subject_2 == "-" then
                return a - b
            elseif ____subject_2 == "*" then
                return a * b
            elseif ____subject_2 == "/" then
                return a / b
            elseif ____subject_2 == "%" then
                return math.fmod(a, b)
            elseif ____subject_2 == "**" or ____subject_2 == "^" then
                return a ^ b
            elseif ____subject_2 == "<" then
                return a < b and 1.0 or 0.0
            elseif ____subject_2 == ">" then
                return a > b and 1.0 or 0.0
            elseif ____subject_2 == "<=" then
                return a <= b and 1.0 or 0.0
            elseif ____subject_2 == ">=" then
                return a >= b and 1.0 or 0.0
            elseif ____subject_2 == "==" then
                return a == b and 1.0 or 0.0
            else
                return a ~= b and 1.0 or 0.0
            end
        end
    elseif ____mt_1 == Call then
        local ____value_3 = functions:get(e.fn)
        if ____value_3 == nil then
            error(__K2L_IllegalArgumentException.new("unknown function " .. e.fn .. "/" .. e.args.size))
        end
        local ____list = e.args
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = eval(it, env)
        end
        return ____value_3(__K2L_ListWrap(____out, ____count))
    elseif ____mt_1 == Cond then
        return eval(e.c, env) ~= 0.0 and eval(e.t, env) or eval(e.f, env)
    end
end

local function caret(src, pos)
    return src .. "\n" .. __K2L_Text.repeatCount(" ", pos) .. "^"
end

local function main()
    local env = __K2L_ReadOnlyMapOf(__K2L_Pair.new("x", 3.0), __K2L_Pair.new("y", -4.5), __K2L_Pair.new("pi", 3.141592653589793), __K2L_Pair.new("n", 10.0))
    print(__K2L_Utf16.out(__K2L_Str(tokenize("max(1, 2.5e3) ** -x"))))
    local programs = __K2L_ReadOnlyListOf("1 + 2 * 3", "(1 + 2) * 3", "2 ** 3 ** 2", "-x ** 2", "10 - 4 - 3", "1_000_000 / 8", "x > 2 && y < 0 ? hypot(x, y) : 0", "n % 3 == 1 || !(x == 3)", "max(x, y, n, 7) - min(1, 2)", "avg(1, 2, 3, 4) * sqrt(16)", "pi * x ^ 2", "1 / 0", "0 / 0 == 0 / 0", ".5 + 1.25e-1", "x ? y ? 1 : 2 : 3")
    local ____mod = programs.____modCount
    for ____i_1 = 1, programs.size do
        local src = programs[____i_1]
        local ast = Pratt.new(tokenize(src)):parseAll()
        local v = eval(ast, env)
        print(__K2L_Utf16.out(__K2L_StringFormat("%-36s => %-40s = %s", src, show(ast), v == __K2L_Num.round(v) and not __K2L_Num.isInfinite(v) and __K2L_StringFormat("%.0f", v) or __K2L_StringFormat("%.6f", v))))
        if programs.____modCount ~= ____mod and programs:____comodified(____i_1) then
            break
        end
    end
    local broken = __K2L_ReadOnlyListOf("1 +", "(1 + 2", "max(1, 2", "3 $ 4", "* 5", "1 2", "a ? b", "1.2.3", "sqrt(1, 2)", "foo(1)", "z + 1", "x é 2")
    local ____mod_1 = broken.____modCount
    for ____i_2 = 1, broken.size do
        local src = broken[____i_2]
        local ____ok, ____result = pcall(function()
            local v = eval(Pratt.new(tokenize(src)):parseAll(), env)
            print(__K2L_Utf16.out(src .. " = " .. __K2L_Str(v)))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if getmetatable(____error) == ParseError then
                local e = ____error
                print(__K2L_Utf16.out("parse error: " .. __K2L_Str(e.message) .. " at " .. e.pos))
                print(__K2L_Utf16.out(__K2L_Text.prependIndent(caret(src, e.pos), "  | ")))
            elseif __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                print(__K2L_Utf16.out("eval error: " .. __K2L_Str(e.message)))
            elseif __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
                local e = ____error
                print(__K2L_Utf16.out("eval error (" .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. "): " .. __K2L_Str(e.message)))
            else
                error(____error, 0)
            end
        end
        if broken.____modCount ~= ____mod_1 and broken:____comodified(____i_2) then
            break
        end
    end
end

main()
return {Kind = Kind, Token = Token, ParseError = ParseError, tokenize = tokenize, Expr = Expr, Num = Num, Var = Var, Unary = Unary, Binary = Binary, Call = Call, Cond = Cond, Pratt = Pratt, show = show, functions = functions, eval = eval, caret = caret}
