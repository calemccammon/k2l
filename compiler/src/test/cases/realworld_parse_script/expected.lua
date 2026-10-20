local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local T = __K2L_Class("T")
__K2L_ClassInfo(T, "T", "T", "class")

function T:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function T:toString()
    return self.name
end

function T:compareTo(other)
    return self.ordinal - other.ordinal
end

T.NUM = T.new("NUM", 0)
T.STR = T.new("STR", 1)
T.ID = T.new("ID", 2)
T.KW = T.new("KW", 3)
T.PUNCT = T.new("PUNCT", 4)
T.EOF = T.new("EOF", 5)
T.____values = {T.NUM, T.STR, T.ID, T.KW, T.PUNCT, T.EOF}
local Pos = __K2L_Class("Pos")
__K2L_ClassInfo(Pos, "Pos", "Pos", "class")

function Pos:____init(line, col)
    self.line = line
    self.col = col
end

function Pos.new(line, col)
    return setmetatable({line = line, col = col}, Pos)
end

function Pos:toString()
    return self.line .. ":" .. self.col
end

function Pos:hashCode()
    return (31 * self.line + self.col + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pos:equals(other)
    return getmetatable(other) == Pos and self.line == other.line and self.col == other.col
end

local Tok = __K2L_Class("Tok")
__K2L_ClassInfo(Tok, "Tok", "Tok", "class")

function Tok:____init(____type, text, pos)
    self.type = ____type
    self.text = text
    self.pos = pos
end

function Tok.new(____type, text, pos)
    return setmetatable({type = ____type, text = text, pos = pos}, Tok)
end

function Tok:toString()
    return "Tok(type=" .. __K2L_Str(self.type) .. ", text=" .. self.text .. ", pos=" .. __K2L_Str(self.pos) .. ")"
end

function Tok:hashCode()
    return (31 * (31 * __K2L_Hash(self.type) + __K2L_Hash(self.text)) + self.pos:hashCode() + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Tok:equals(other)
    return getmetatable(other) == Tok and self.type == other.type and self.text == other.text and self.pos:equals(other.pos)
end

local ScriptError = __K2L_Class("ScriptError", __K2L_Exception)
__K2L_ClassInfo(ScriptError, "ScriptError", "ScriptError", "class")

function ScriptError:____init(msg, pos)
    __K2L_Exception.____init(self, msg .. " at " .. __K2L_Str(pos))
    self.pos = pos
end

local LexError = __K2L_Class("LexError", ScriptError)
__K2L_ClassInfo(LexError, "LexError", "LexError", "class")

function LexError:____init(msg, pos)
    ScriptError.____init(self, msg, pos)
end

local SyntaxError = __K2L_Class("SyntaxError", ScriptError)
__K2L_ClassInfo(SyntaxError, "SyntaxError", "SyntaxError", "class")

function SyntaxError:____init(msg, pos)
    ScriptError.____init(self, msg, pos)
end

local RuntimeErr = __K2L_Class("RuntimeErr", ScriptError)
__K2L_ClassInfo(RuntimeErr, "RuntimeErr", "RuntimeErr", "class")

function RuntimeErr:____init(msg, pos)
    ScriptError.____init(self, msg, pos)
end

local keywords = __K2L_ReadOnlySetOf("let", "fn", "if", "else", "while", "return", "true", "false", "and", "or", "not", "nil")
local Lexer = __K2L_Class("Lexer")
__K2L_ClassInfo(Lexer, "Lexer", "Lexer", "class")

function Lexer:____init(src)
    self.src = src
    self.i = 0
    self.line = 1
    self.col = 1
end

function Lexer:peek(off)
    if off == nil then
        off = 0
    end
    return self.i + off < __K2L_Utf16.len(self.src) and __K2L_Text.get(self.src, self.i + off) or "\000"
end

function Lexer:advance()
    local ____arg = self.src
    local ____old = self.i
    self.i = self.i + 1
    local c = __K2L_Text.get(____arg, ____old)
    if c == "\n" then
        self.line = self.line + 1
        self.col = 1
    else
        self.col = self.col + 1
    end
    return c
end

function Lexer:lex()
    local out = __K2L_ListOf()
    while self.i < __K2L_Utf16.len(self.src) do
        local c = self:peek()
        local start = Pos.new(self.line, self.col)
        if c == "#" then
            while self.i < __K2L_Utf16.len(self.src) and self:peek() ~= "\n" do
                self:advance()
            end
        elseif __K2L_Utf16Case.isWhitespace(c) then
            self:advance()
        elseif __K2L_Utf16Case.isDigit(c) then
            local sb = __K2L_StringBuilder.new()
            while __K2L_Utf16Case.isDigit(self:peek()) or self:peek() == "." and __K2L_Utf16Case.isDigit(self:peek(1)) do
                sb:append(self:advance())
            end
            out:add(Tok.new(T.NUM, sb:toString(), start))
        elseif c == "\"" then
            out:add(Tok.new(T.STR, self:string(start), start))
        elseif __K2L_Utf16Case.isLetter(c) or c == "_" then
            local sb = __K2L_StringBuilder.new()
            while __K2L_Utf16Case.isLetterOrDigit(self:peek()) or self:peek() == "_" do
                sb:append(self:advance())
            end
            local w = sb:toString()
            out:add(Tok.new(keywords:contains(w) and T.KW or T.ID, w, start))
        else
            local two = __K2L_Utf16.norm(c .. self:peek(1))
            if __K2L_ReadOnlySetOf("==", "!=", "<=", ">=", "->"):contains(two) then
                self:advance()
                self:advance()
                out:add(Tok.new(T.PUNCT, two, start))
            elseif __K2L_Text.contains("+-*/%<>=(){},;", c) then
                out:add(Tok.new(T.PUNCT, self:advance(), start))
            else
                error(LexError.new(__K2L_Utf16.norm("unexpected '" .. c .. "'"), start))
            end
        end
    end
    out:add(Tok.new(T.EOF, "<eof>", Pos.new(self.line, self.col)))
    return out
end

function Lexer:string(start)
    self:advance()
    local sb = __K2L_StringBuilder.new()
    while true do
        if self.i >= __K2L_Utf16.len(self.src) or self:peek() == "\n" then
            error(LexError.new("unterminated string", start))
        end
        local c = self:advance()
        if c == "\"" then
            return sb:toString()
        elseif c == "\\" then
            local e = self:advance()
            if e == "n" then
                sb:append("\n")
            elseif e == "t" then
                sb:append("\t")
            elseif e == "\"" or e == "\\" then
                sb:append(e)
            else
                error(LexError.new(__K2L_Utf16.norm("bad escape '\\" .. e .. "'"), Pos.new(self.line, self.col - 2)))
            end
        else
            sb:append(c)
        end
    end
end

local Node = __K2L_Class("Node")
__K2L_ClassInfo(Node, "Node", "Node", "class")

function Node:____init(pos)
    self.pos = pos
end

function Node.new(pos)
    return setmetatable({pos = pos}, Node)
end

local NumLit = __K2L_Class("NumLit", Node)
__K2L_ClassInfo(NumLit, "NumLit", "NumLit", "class")

function NumLit:____init(v, p)
    Node.____init(self, p)
    self.v = v
end

local StrLit = __K2L_Class("StrLit", Node)
__K2L_ClassInfo(StrLit, "StrLit", "StrLit", "class")

function StrLit:____init(v, p)
    Node.____init(self, p)
    self.v = v
end

local BoolLit = __K2L_Class("BoolLit", Node)
__K2L_ClassInfo(BoolLit, "BoolLit", "BoolLit", "class")

function BoolLit:____init(v, p)
    Node.____init(self, p)
    self.v = v
end

local NilLit = __K2L_Class("NilLit", Node)
__K2L_ClassInfo(NilLit, "NilLit", "NilLit", "class")

function NilLit:____init(p)
    Node.____init(self, p)
end

local Name = __K2L_Class("Name", Node)
__K2L_ClassInfo(Name, "Name", "Name", "class")

function Name:____init(id, p)
    Node.____init(self, p)
    self.id = id
end

local Bin = __K2L_Class("Bin", Node)
__K2L_ClassInfo(Bin, "Bin", "Bin", "class")

function Bin:____init(op, l, r, p)
    Node.____init(self, p)
    self.op = op
    self.l = l
    self.r = r
end

local Un = __K2L_Class("Un", Node)
__K2L_ClassInfo(Un, "Un", "Un", "class")

function Un:____init(op, e, p)
    Node.____init(self, p)
    self.op = op
    self.e = e
end

local CallN = __K2L_Class("CallN", Node)
__K2L_ClassInfo(CallN, "CallN", "CallN", "class")

function CallN:____init(callee, args, p)
    Node.____init(self, p)
    self.callee = callee
    self.args = args
end

local FnLit = __K2L_Class("FnLit", Node)
__K2L_ClassInfo(FnLit, "FnLit", "FnLit", "class")

function FnLit:____init(params, body, p)
    Node.____init(self, p)
    self.params = params
    self.body = body
end

local LetS = __K2L_Class("LetS", Node)
__K2L_ClassInfo(LetS, "LetS", "LetS", "class")

function LetS:____init(id, e, p)
    Node.____init(self, p)
    self.id = id
    self.e = e
end

local AssignS = __K2L_Class("AssignS", Node)
__K2L_ClassInfo(AssignS, "AssignS", "AssignS", "class")

function AssignS:____init(id, e, p)
    Node.____init(self, p)
    self.id = id
    self.e = e
end

local IfS = __K2L_Class("IfS", Node)
__K2L_ClassInfo(IfS, "IfS", "IfS", "class")

function IfS:____init(c, t, f, p)
    Node.____init(self, p)
    self.c = c
    self.t = t
    self.f = f
end

local WhileS = __K2L_Class("WhileS", Node)
__K2L_ClassInfo(WhileS, "WhileS", "WhileS", "class")

function WhileS:____init(c, body, p)
    Node.____init(self, p)
    self.c = c
    self.body = body
end

local ReturnS = __K2L_Class("ReturnS", Node)
__K2L_ClassInfo(ReturnS, "ReturnS", "ReturnS", "class")

function ReturnS:____init(e, p)
    Node.____init(self, p)
    self.e = e
end

local Parser = __K2L_Class("Parser")
__K2L_ClassInfo(Parser, "Parser", "Parser", "class")

function Parser:____init(toks)
    self.toks = toks
    self.k = 0
    self.levels = __K2L_ReadOnlyListOf(__K2L_SingletonListOf("or"), __K2L_SingletonListOf("and"), __K2L_ReadOnlyListOf("==", "!="), __K2L_ReadOnlyListOf("<", "<=", ">", ">="), __K2L_ReadOnlyListOf("+", "-"), __K2L_ReadOnlyListOf("*", "/", "%"))
end

function Parser:getCur()
    return self.toks:get(self.k)
end

function Parser:at(text)
    return (self:getCur().type == T.PUNCT or self:getCur().type == T.KW) and self:getCur().text == text
end

function Parser:eat(text)
    if not self:at(text) then
        error(SyntaxError.new("expected '" .. text .. "' but found '" .. self:getCur().text .. "'", self:getCur().pos))
    end
    local ____arg_1 = self.toks
    local ____old_1 = self.k
    self.k = self.k + 1
    return ____arg_1:get(____old_1)
end

function Parser:program()
    local out = __K2L_List.new()
    while self:getCur().type ~= T.EOF do
        out:add(self:statement())
    end
    return out
end

function Parser:block()
    self:eat("{")
    local out = __K2L_List.new()
    while not self:at("}") do
        if self:getCur().type == T.EOF then
            error(SyntaxError.new("unclosed block", self:getCur().pos))
        end
        out:add(self:statement())
    end
    self:eat("}")
    return out
end

function Parser:statement()
    local p = self:getCur().pos
    if self:at("let") then
        self.k = self.k + 1
        local id = self:ident()
        self:eat("=")
        local ____value_2 = LetS.new(id, self:expr(), p)
        self:eat(";")
        return ____value_2
    elseif self:at("if") then
        self.k = self.k + 1
        return self:ifTail(p)
    elseif self:at("while") then
        self.k = self.k + 1
        return WhileS.new(self:expr(), self:block(), p)
    elseif self:at("return") then
        self.k = self.k + 1
        local e
        if self:at(";") then
            e = nil
        else
            e = self:expr()
        end
        self:eat(";")
        return ReturnS.new(e, p)
    elseif self:getCur().type == T.ID and self.toks:get(self.k + 1).text == "=" then
        local id = self:ident()
        self.k = self.k + 1
        local ____value_1 = AssignS.new(id, self:expr(), p)
        self:eat(";")
        return ____value_1
    else
        local ____value = self:expr()
        self:eat(";")
        return ____value
    end
end

function Parser:ifTail(p)
    local c = self:expr()
    local t = self:block()
    local f
    if self:at("else") then
        self.k = self.k + 1
        if self:at("if") then
            local q = self:getCur().pos
            self.k = self.k + 1
            f = __K2L_SingletonListOf(self:ifTail(q))
        else
            f = self:block()
        end
    else
        f = nil
    end
    return IfS.new(c, t, f, p)
end

function Parser:ident()
    if self:getCur().type ~= T.ID then
        error(SyntaxError.new("expected identifier but found '" .. self:getCur().text .. "'", self:getCur().pos))
    end
    local ____arg_2 = self.toks
    local ____old_2 = self.k
    self.k = self.k + 1
    return ____arg_2:get(____old_2).text
end

function Parser:expr(level)
    if level == nil then
        level = 0
    end
    if level == self.levels.size then
        return self:unary()
    end
    local left = self:expr(level + 1)
    while true do
        local ____list = self.levels:get(level)
        local ____result = false
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if self:at(it) then
                ____result = true
                break
            end
        end
        if not ____result then
            break
        end
        local ____arg_3 = self.toks
        local ____old_3 = self.k
        self.k = self.k + 1
        local op = ____arg_3:get(____old_3)
        left = Bin.new(op.text, left, self:expr(level + 1), op.pos)
    end
    return left
end

function Parser:unary()
    local p = self:getCur().pos
    if self:at("-") or self:at("not") then
        local ____arg_4 = self.toks
        local ____old_4 = self.k
        self.k = self.k + 1
        local op = ____arg_4:get(____old_4).text
        return Un.new(op, self:unary(), p)
    end
    local e = self:primary()
    while self:at("(") do
        local cp = self:getCur().pos
        self.k = self.k + 1
        local args = __K2L_List.new()
        if not self:at(")") then
            repeat
                args:add(self:expr())
                local ____value_3 = self:at(",")
                if ____value_3 then
                    self.k = self.k + 1
                end
            until not ____value_3
        end
        self:eat(")")
        e = CallN.new(e, args, cp)
    end
    return e
end

function Parser:primary()
    local t = self:getCur()
    self.k = self.k + 1
    local ____subject = t.type
    if ____subject == T.NUM then
        return NumLit.new(__K2L_StringToDouble(t.text), t.pos)
    elseif ____subject == T.STR then
        return StrLit.new(t.text, t.pos)
    elseif ____subject == T.ID then
        return Name.new(t.text, t.pos)
    elseif ____subject == T.KW then
        local ____subject_1 = t.text
        if ____subject_1 == "true" or ____subject_1 == "false" then
            return BoolLit.new(t.text == "true", t.pos)
        elseif ____subject_1 == "nil" then
            return NilLit.new(t.pos)
        elseif ____subject_1 == "fn" then
            return self:fnTail(t.pos)
        else
            error(SyntaxError.new("unexpected keyword '" .. t.text .. "'", t.pos))
        end
    elseif ____subject == T.PUNCT then
        if t.text == "(" then
            local ____value_4 = self:expr()
            self:eat(")")
            return ____value_4
        else
            error(SyntaxError.new("unexpected '" .. t.text .. "'", t.pos))
        end
    elseif ____subject == T.EOF then
        error(SyntaxError.new("unexpected end of input", t.pos))
    end
end

function Parser:fnTail(p)
    self:eat("(")
    local ps = __K2L_List.new()
    if not self:at(")") then
        repeat
            ps:add(self:ident())
            local ____value_5 = self:at(",")
            if ____value_5 then
                self.k = self.k + 1
            end
        until not ____value_5
    end
    self:eat(")")
    if not self:at("->") then
        return FnLit.new(ps, self:block(), p)
    end
    self.k = self.k + 1
    local e = self:expr()
    return FnLit.new(ps, __K2L_SingletonListOf(ReturnS.new(e, e.pos)), p)
end

local Env = __K2L_Class("Env")
__K2L_ClassInfo(Env, "Env", "Env", "class")

function Env:____init(parent)
    self.parent = parent
    self.vars = __K2L_HashMap.new()
end

function Env:define(n, v)
    local ____object = self.vars
    ____object:set(n, v)
end

function Env:lookup(n, p)
    if self.vars:containsKey(n) then
        return self.vars:get(n)
    elseif self.parent ~= nil then
        return self.parent:lookup(n, p)
    else
        error(RuntimeErr.new("undefined variable '" .. n .. "'", p))
    end
end

function Env:assign(n, v, p)
    if self.vars:containsKey(n) then
        local ____object_1 = self.vars
        ____object_1:set(n, v)
    elseif self.parent ~= nil then
        self.parent:assign(n, v, p)
    else
        error(RuntimeErr.new("assignment to undeclared '" .. n .. "'", p))
    end
end

local Closure = __K2L_Class("Closure")
__K2L_ClassInfo(Closure, "Closure", "Closure", "class")

function Closure:____init(fn, env)
    self.fn = fn
    self.env = env
end

function Closure.new(fn, env)
    return setmetatable({fn = fn, env = env}, Closure)
end

function Closure:toString()
    return "<fn/" .. self.fn.params.size .. ">"
end

local Native = __K2L_Class("Native")
__K2L_ClassInfo(Native, "Native", "Native", "class")

function Native:____init(name, arity, f)
    self.name = name
    self.arity = arity
    self.f = f
end

function Native.new(name, arity, f)
    return setmetatable({name = name, arity = arity, f = f}, Native)
end

local ReturnSignal = __K2L_Class("ReturnSignal", __K2L_RuntimeException)
__K2L_ClassInfo(ReturnSignal, "ReturnSignal", "ReturnSignal", "class")

function ReturnSignal:____init(value)
    __K2L_RuntimeException.____init(self)
    self.value = value
end

local function show(v)
    if v == nil then
        return "nil"
    elseif math.type(v) == "float" then
        return v == math.floor(v) + 0.0 and not __K2L_Num.isInfinite(v) and tostring(__K2L_DoubleToLong(v)) or __K2L_Str(v)
    elseif getmetatable(v) == Native then
        return "<native " .. v.name .. ">"
    else
        return __K2L_Str(v)
    end
end

local Interp = __K2L_Class("Interp")
__K2L_ClassInfo(Interp, "Interp", "Interp", "class")

local ____lambda_1 = function(it) return show(it) end
local ____lambda_2 = function(args) return show(args:get(0)) end
function Interp:____init(out)
    self.out = out
    local ____value_6 = Env.new(nil)
    ____value_6:define("print", Native.new("print", -1, function(args)
        self.out:append(__K2L_Utf16.norm(args:joinToString(" ", nil, nil, nil, nil, ____lambda_1))):append("\n")
        return nil
    end))
    ____value_6:define("len", Native.new("len", 1, function(args)
        local ____cast = args:get(0)
        local ____receiver = type(____cast) == "string" and ____cast or nil
        local ____result_1
        if ____receiver ~= nil then
            local ____cast_1 = args:get(0)
            ____result_1 = __K2L_Utf16.len(type(____cast_1) == "string" and ____cast_1 or nil)
        end
        local ____receiver_1 = ____result_1
        return ____receiver_1 and ____receiver_1 + 0.0
    end))
    ____value_6:define("str", Native.new("str", 1, ____lambda_2))
    self.globals = ____value_6
    self.steps = 0
end

function Interp:run(prog)
    self:exec(prog, self.globals)
end

function Interp:exec(body, env)
    local ____mod = body.____modCount
    for ____i_1 = 1, body.size do
        local s = body[____i_1]
        self:stmt(s, env)
        if body.____modCount ~= ____mod and body:____comodified(____i_1) then
            break
        end
    end
end

function Interp:stmt(s, env)
    self.steps = self.steps + 1
    if self.steps > 10000 then
        error(RuntimeErr.new("step limit exceeded", s.pos))
    end
    local ____mt = getmetatable(s)
    if ____mt == LetS then
        env:define(s.id, self:eval(s.e, env))
    elseif ____mt == AssignS then
        env:assign(s.id, self:eval(s.e, env), s.pos)
    elseif ____mt == IfS then
        if self:truthy(self:eval(s.c, env)) then
            self:exec(s.t, Env.new(env))
        else
            local ____receiver_3 = s.f
            if ____receiver_3 ~= nil then
                self:exec(____receiver_3, Env.new(env))
            end
        end
    elseif ____mt == WhileS then
        while self:truthy(self:eval(s.c, env)) do
            self:exec(s.body, Env.new(env))
        end
    elseif ____mt == ReturnS then
        local ____receiver_2 = s.e
        error(ReturnSignal.new(____receiver_2 and self:eval(____receiver_2, env)))
    else
        self:eval(s, env)
    end
end

function Interp:truthy(v)
    return v ~= nil and not __K2L_Equals(v, false)
end

function Interp:eval(e, env)
    local ____mt_1 = getmetatable(e)
    if ____mt_1 == NumLit then
        return e.v
    elseif ____mt_1 == StrLit then
        return e.v
    elseif ____mt_1 == BoolLit then
        return e.v
    elseif ____mt_1 == NilLit then
        return nil
    elseif ____mt_1 == Name then
        return env:lookup(e.id, e.pos)
    elseif ____mt_1 == FnLit then
        return Closure.new(e, env)
    elseif ____mt_1 == Un then
        if e.op == "not" then
            return not self:truthy(self:eval(e.e, env))
        else
            return -self:num(self:eval(e.e, env), e.pos)
        end
    elseif ____mt_1 == Bin then
        return self:binary(e, env)
    elseif ____mt_1 == CallN then
        local ____arg_5 = self:eval(e.callee, env)
        local ____list_1 = e.args
        local ____out = {}
        local ____count = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_2 = 1, ____n_1 do
            local it = ____items_1[____i_2]
            ____count = ____count + 1
            ____out[____count] = self:eval(it, env)
        end
        return self:call(____arg_5, __K2L_ListWrap(____out, ____count), e.pos)
    else
        error(RuntimeErr.new("not an expression", e.pos))
    end
end

function Interp:num(v, p)
    local ____value_7 = math.type(v) == "float" and v or nil
    if ____value_7 == nil then
        error(RuntimeErr.new("expected number, got " .. show(v), p))
    end
    return ____value_7
end

function Interp:binary(e, env)
    if e.op == "and" then
        local ____value_8 = self:eval(e.l, env)
        local ____result_2
        if self:truthy(____value_8) then
            ____result_2 = self:eval(e.r, env)
        else
            ____result_2 = ____value_8
        end
        return ____result_2
    end
    if e.op == "or" then
        local ____value_9 = self:eval(e.l, env)
        local ____result_3
        if self:truthy(____value_9) then
            ____result_3 = ____value_9
        else
            ____result_3 = self:eval(e.r, env)
        end
        return ____result_3
    end
    local l = self:eval(e.l, env)
    local r = self:eval(e.r, env)
    local ____subject_2 = e.op
    if ____subject_2 == "==" then
        return __K2L_Equals(l, r)
    elseif ____subject_2 == "!=" then
        return not __K2L_Equals(l, r)
    elseif ____subject_2 == "+" then
        return (type(l) == "string" or type(r) == "string") and show(l) .. show(r) or self:num(l, e.pos) + self:num(r, e.pos)
    elseif ____subject_2 == "-" then
        return self:num(l, e.pos) - self:num(r, e.pos)
    elseif ____subject_2 == "*" then
        return self:num(l, e.pos) * self:num(r, e.pos)
    elseif ____subject_2 == "/" then
        local ____value_10 = self:num(r, e.pos)
        local ____result_4
        if ____value_10 == 0.0 then
            error(RuntimeErr.new("division by zero", e.pos))
        else
            ____result_4 = self:num(l, e.pos) / ____value_10
        end
        return ____result_4
    elseif ____subject_2 == "%" then
        return self:num(l, e.pos) % self:num(r, e.pos)
    elseif ____subject_2 == "<" then
        return self:num(l, e.pos) < self:num(r, e.pos)
    elseif ____subject_2 == "<=" then
        return self:num(l, e.pos) <= self:num(r, e.pos)
    elseif ____subject_2 == ">" then
        return self:num(l, e.pos) > self:num(r, e.pos)
    else
        return self:num(l, e.pos) >= self:num(r, e.pos)
    end
end

function Interp:call(f, args, p)
    local ____mt_2 = getmetatable(f)
    if ____mt_2 == Native then
        if f.arity >= 0 and f.arity ~= args.size then
            error(RuntimeErr.new(f.name .. " expects " .. f.arity .. " args, got " .. args.size, p))
        end
        return f.f(args)
    elseif ____mt_2 == Closure then
        if f.fn.params.size ~= args.size then
            error(RuntimeErr.new("arity mismatch: expected " .. f.fn.params.size .. ", got " .. args.size, p))
        end
        local ____local = Env.new(f.env)
        local ____list_2 = f.fn.params:zip(args)
        local ____mod_1 = ____list_2.____modCount
        for ____i_3 = 1, ____list_2.size do
            local ____it = ____list_2[____i_3]
            do
                local n, v = ____it.first, ____it.second
                ____local:define(n, v)
            end
            if ____list_2.____modCount ~= ____mod_1 and ____list_2:____comodified(____i_3) then
                break
            end
        end
        local ____ok, ____result_5, ____returned = __K2L_DeepPcall(function()
            self:exec(f.fn.body, ____local)
            return true, nil
        end)
        if ____ok then
            if ____result_5 then
                return ____returned
            end
        else
            local ____error = __K2L_ToThrowable(____result_5)
            if getmetatable(____error) == ReturnSignal then
                local r = ____error
                return r.value
            else
                error(____error, 0)
            end
        end
    else
        error(RuntimeErr.new("cannot call " .. show(f), p))
    end
end

local function runScript(name, src)
    local out = __K2L_StringBuilder.new()
    local interp = Interp.new(out)
    local ____ok_1, ____result_6 = __K2L_DeepPcall(function()
        interp:run(Parser.new(Lexer.new(src):lex()):program())
        io.write(__K2L_Utf16.out(__K2L_Str(out)))
        print(__K2L_Utf16.out("[" .. name .. "] ok, " .. interp.steps .. " steps"))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_6)
        if __K2L_InstanceOf(____error_1, ScriptError) then
            local e = ____error_1
            io.write(__K2L_Utf16.out(__K2L_Str(out)))
            local lineText = __K2L_StringLines(src):get(e.pos.line - 1)
            print(__K2L_Utf16.out("[" .. name .. "] " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message)))
            print(__K2L_Utf16.out("  | " .. lineText))
            print(__K2L_Utf16.out("  | " .. __K2L_Text.repeatCount(" ", e.pos.col - 1) .. "^"))
        else
            error(____error_1, 0)
        end
    end
end

local function main()
    runScript("fib", __K2L_Text.trimIndent("\n        # recursive and iterative fibonacci\n        let fib = fn(n) { if n < 2 { return n; } return fib(n - 1) + fib(n - 2); };\n        let i = 0;\n        while i <= 10 { print(\"fib\", i, \"=\", fib(i)); i = i + 3; }\n        "))
    runScript("closures", __K2L_Text.trimIndent("\n        let counter = fn() { let c = 0; return fn() { c = c + 1; return c; }; };\n        let a = counter(); let b = counter();\n        a(); a();\n        print(\"a:\", a(), \"b:\", b());\n        let compose = fn(f, g) -> fn(x) -> f(g(x));\n        let inc = fn(x) -> x + 1;\n        let dbl = fn(x) -> x * 2;\n        print(compose(inc, dbl)(5), compose(dbl, inc)(5));\n        print(\"len:\", len(\"héllo\\tworld\"), str(7 / 2), -7 % 3, not nil and \"yes\");\n        print(\"mix \" + 1 + true + nil);\n        "))
    runScript("fizz", __K2L_Text.trimIndent("\n        let n = 1;\n        let s = \"\";\n        while n <= 15 {\n          if n % 15 == 0 { s = s + \"FB \"; } else if n % 3 == 0 { s = s + \"F \"; } else if n % 5 == 0 { s = s + \"B \"; } else { s = s + n + \" \"; }\n          n = n + 1;\n        }\n        print(s);\n        "))
    runScript("divzero", "let x = 10;\nlet y = x - 10;\nprint(\"before\");\nprint(x / y);")
    runScript("undef", "let a = 1;\nprint(a + b);")
    runScript("arity", "let f = fn(a, b) -> a;\nf(1);")
    runScript("syntax", "let x = (1 + 2;\n")
    runScript("lex", "let s = \"ok\";\nlet t = 3 @ 4;")
    runScript("escape", "print(\"a\\qb\");")
    runScript("unterminated", "print(1);\nprint(\"never closed);")
    runScript("block", "if true { print(1);")
    runScript("loop", "let x = 0;\nwhile true { x = x + 1; }")
    runScript("notfn", "let five = 5;\nfive(1, 2);")
    runScript("type", "print(\"a\" - 1);")
end

__K2L_DeepMain(main)
return {T = T, Pos = Pos, Tok = Tok, ScriptError = ScriptError, LexError = LexError, SyntaxError = SyntaxError, RuntimeErr = RuntimeErr, keywords = keywords, Lexer = Lexer, Node = Node, NumLit = NumLit, StrLit = StrLit, BoolLit = BoolLit, NilLit = NilLit, Name = Name, Bin = Bin, Un = Un, CallN = CallN, FnLit = FnLit, LetS = LetS, AssignS = AssignS, IfS = IfS, WhileS = WhileS, ReturnS = ReturnS, Parser = Parser, Env = Env, Closure = Closure, Native = Native, ReturnSignal = ReturnSignal, show = show, Interp = Interp, runScript = runScript}
