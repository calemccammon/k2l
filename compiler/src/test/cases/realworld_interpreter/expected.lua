local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsWhitespace = ____lualib.__K2L_IsWhitespace
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate

local Env
local LangException = __K2L_Class("calc.LangException", __K2L_Exception)

function LangException:____init(message, line, cause)
    __K2L_Exception.____init(self, message, cause)
    self.line = line
end

function LangException:toString()
    return __K2L_Str(__K2L_SimpleName(self)) .. "(line " .. self.line .. "): " .. __K2L_Str(self.message)
end

local SyntaxError = __K2L_Class("calc.SyntaxError", LangException)

function SyntaxError:____init(message, line)
    LangException.____init(self, message, line)
end

local RuntimeError = __K2L_Class("calc.RuntimeError", LangException)

function RuntimeError:____init(message, line, cause)
    LangException.____init(self, message, line, cause)
end

local TokenType = __K2L_Class("calc.TokenType")

function TokenType:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function TokenType:toString()
    return self.name
end

function TokenType:compareTo(other)
    return self.ordinal - other.ordinal
end

TokenType.NUMBER = TokenType.new("NUMBER", 0)
TokenType.STRING = TokenType.new("STRING", 1)
TokenType.IDENT = TokenType.new("IDENT", 2)
TokenType.KEYWORD = TokenType.new("KEYWORD", 3)
TokenType.OP = TokenType.new("OP", 4)
TokenType.LPAREN = TokenType.new("LPAREN", 5)
TokenType.RPAREN = TokenType.new("RPAREN", 6)
TokenType.LBRACE = TokenType.new("LBRACE", 7)
TokenType.RBRACE = TokenType.new("RBRACE", 8)
TokenType.COMMA = TokenType.new("COMMA", 9)
TokenType.SEMI = TokenType.new("SEMI", 10)
TokenType.EOF = TokenType.new("EOF", 11)
TokenType.____values = {TokenType.NUMBER, TokenType.STRING, TokenType.IDENT, TokenType.KEYWORD, TokenType.OP, TokenType.LPAREN, TokenType.RPAREN, TokenType.LBRACE, TokenType.RBRACE, TokenType.COMMA, TokenType.SEMI, TokenType.EOF}
local Token = __K2L_Class("calc.Token")

function Token.new(____type, text, line)
    return setmetatable({type = ____type, text = text, line = line}, Token)
end

function Token:toString()
    return self.type == TokenType.EOF and "<eof>" or __K2L_Str(self.type) .. " '" .. self.text .. "'"
end

__K2L_DataClass(Token, {"type", "text", "line"})
local Lexer = __K2L_Class("calc.Lexer")
local TWO_CHAR_OPS, SINGLE, readString, skipBlanks

local function peekChar(self, offset)
    if offset == nil then
        offset = 0
    end
    return __K2L_Text.getOrNull(self.src, self.pos + offset)
end

local function ____next(self)
    skipBlanks(self)
    local ____value = peekChar(self)
    if ____value == nil then
        return Token.new(TokenType.EOF, "", self.line)
    end
    local c = ____value
    local start = self.pos
    if __K2L_IsDigit[c] == true then
        while true do
            local ____receiver_1 = peekChar(self)
            if (____receiver_1 and (__K2L_IsDigit[____receiver_1] == true or ____receiver_1 == ".")) ~= true then
                break
            end
            self.pos = self.pos + 1
        end
        return Token.new(TokenType.NUMBER, __K2L_Text.substring(self.src, start, self.pos), self.line)
    elseif __K2L_IsLetter[c] == true or c == "_" then
        while true do
            local ____receiver = peekChar(self)
            if (____receiver and (__K2L_IsLetterOrDigit[____receiver] == true or ____receiver == "_")) ~= true then
                break
            end
            self.pos = self.pos + 1
        end
        local word = __K2L_Text.substring(self.src, start, self.pos)
        return Token.new(Lexer.KEYWORDS:contains(word) and TokenType.KEYWORD or TokenType.IDENT, word, self.line)
    elseif c == "\"" then
        return readString(self)
    else
        local two = __K2L_Text.substring(self.src, self.pos, math.min(self.pos + 2, #self.src))
        if TWO_CHAR_OPS:contains(two) then
            self.pos = self.pos + 2
            return Token.new(TokenType.OP, two, self.line)
        elseif SINGLE:containsKey(c) then
            self.pos = self.pos + 1
            return Token.new(SINGLE:getValue(c), c, self.line)
        elseif __K2L_StringContains("+-*/%<>=!", c) then
            self.pos = self.pos + 1
            return Token.new(TokenType.OP, c, self.line)
        else
            error(SyntaxError.new("unexpected character '" .. c .. "'", self.line))
        end
    end
end

function readString(self)
    self.pos = self.pos + 1
    local sb = __K2L_StringBuilder.new()
    while true do
        local ____value_1 = peekChar(self)
        if ____value_1 == nil then
            error(SyntaxError.new("unterminated string", self.line))
        end
        local ch = ____value_1
        self.pos = self.pos + 1
        if ch == "\"" then
            break
        end
        if ch == "\\" then
            local esc = peekChar(self)
            if esc == "n" then
                sb:append("\n")
            elseif esc == "t" then
                sb:append("\t")
            else
                if esc == nil then
                    error(SyntaxError.new("bad escape", self.line))
                end
                sb:append(esc)
            end
            self.pos = self.pos + 1
        else
            sb:append(ch)
        end
    end
    return Token.new(TokenType.STRING, sb:toString(), self.line)
end

function skipBlanks(self)
    while true do
        local ____value_2 = peekChar(self)
        if ____value_2 == nil then
            return
        end
        local c = ____value_2
        if c == "\n" then
            self.line = self.line + 1
            self.pos = self.pos + 1
        elseif __K2L_IsWhitespace[c] == true then
            self.pos = self.pos + 1
        elseif c == "#" then
            while peekChar(self) ~= nil and peekChar(self) ~= "\n" do
                self.pos = self.pos + 1
            end
        else
            return
        end
    end
end

function Lexer:____init(src)
    self.src = src
    self.pos = 0
    self.line = 1
end

function Lexer:tokens()
    local ____builder = __K2L_ListOf()
    while true do
        local t = ____next(self)
        ____builder:add(t)
        if t.type == TokenType.EOF then
            break
        end
    end
    return ____builder
end

function Lexer:____initCompanion()
    self.KEYWORDS = __K2L_SetOf("let", "fun", "if", "else", "while", "return", "print", "true", "false")
    TWO_CHAR_OPS = __K2L_ListOf("==", "!=", "<=", ">=", "&&", "||")
    SINGLE = __K2L_MapOf(__K2L_Pair.new("(", TokenType.LPAREN), __K2L_Pair.new(")", TokenType.RPAREN), __K2L_Pair.new("{", TokenType.LBRACE), __K2L_Pair.new("}", TokenType.RBRACE), __K2L_Pair.new(",", TokenType.COMMA), __K2L_Pair.new(";", TokenType.SEMI))
end

__K2L_LazyObject(Lexer, "____initCompanion")
local Expr = __K2L_Class("calc.Expr")
Expr.Num = __K2L_Class("calc.Expr$Num", nil, Expr)

function Expr.Num.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Num)
end

__K2L_DataClass(Expr.Num, {"value", "line"})
Expr.Str = __K2L_Class("calc.Expr$Str", nil, Expr)

function Expr.Str.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Str)
end

__K2L_DataClass(Expr.Str, {"value", "line"})
Expr.Bool = __K2L_Class("calc.Expr$Bool", nil, Expr)

function Expr.Bool.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Bool)
end

__K2L_DataClass(Expr.Bool, {"value", "line"})
Expr.Var = __K2L_Class("calc.Expr$Var", nil, Expr)

function Expr.Var.new(name, line)
    return setmetatable({name = name, line = line}, Expr.Var)
end

__K2L_DataClass(Expr.Var, {"name", "line"})
Expr.Unary = __K2L_Class("calc.Expr$Unary", nil, Expr)

function Expr.Unary.new(op, operand, line)
    return setmetatable({op = op, operand = operand, line = line}, Expr.Unary)
end

__K2L_DataClass(Expr.Unary, {"op", "operand", "line"})
Expr.Binary = __K2L_Class("calc.Expr$Binary", nil, Expr)

function Expr.Binary.new(left, op, right, line)
    return setmetatable({left = left, op = op, right = right, line = line}, Expr.Binary)
end

__K2L_DataClass(Expr.Binary, {"left", "op", "right", "line"})
Expr.Call = __K2L_Class("calc.Expr$Call", nil, Expr)

function Expr.Call.new(callee, args, line)
    return setmetatable({callee = callee, args = args, line = line}, Expr.Call)
end

__K2L_DataClass(Expr.Call, {"callee", "args", "line"})
local Stmt = __K2L_Class("calc.Stmt")
Stmt.Let = __K2L_Class("calc.Stmt$Let", Stmt)

function Stmt.Let.new(name, init)
    return setmetatable({name = name, init = init}, Stmt.Let)
end

__K2L_DataClass(Stmt.Let, {"name", "init"})
Stmt.Assign = __K2L_Class("calc.Stmt$Assign", Stmt)

function Stmt.Assign.new(name, value)
    return setmetatable({name = name, value = value}, Stmt.Assign)
end

__K2L_DataClass(Stmt.Assign, {"name", "value"})
Stmt.Print = __K2L_Class("calc.Stmt$Print", Stmt)

function Stmt.Print.new(expr)
    return setmetatable({expr = expr}, Stmt.Print)
end

__K2L_DataClass(Stmt.Print, {"expr"})
Stmt.If = __K2L_Class("calc.Stmt$If", Stmt)

function Stmt.If.new(cond, ____then, otherwise)
    return setmetatable({cond = cond, ["then"] = ____then, otherwise = otherwise}, Stmt.If)
end

__K2L_DataClass(Stmt.If, {"cond", "then", "otherwise"})
Stmt.While = __K2L_Class("calc.Stmt$While", Stmt)

function Stmt.While.new(cond, body)
    return setmetatable({cond = cond, body = body}, Stmt.While)
end

__K2L_DataClass(Stmt.While, {"cond", "body"})
Stmt.FunDecl = __K2L_Class("calc.Stmt$FunDecl", Stmt)

function Stmt.FunDecl.new(name, params, body)
    return setmetatable({name = name, params = params, body = body}, Stmt.FunDecl)
end

__K2L_DataClass(Stmt.FunDecl, {"name", "params", "body"})
Stmt.Return = __K2L_Class("calc.Stmt$Return", Stmt)

function Stmt.Return.new(value)
    return setmetatable({value = value}, Stmt.Return)
end

__K2L_DataClass(Stmt.Return, {"value"})
Stmt.ExprStmt = __K2L_Class("calc.Stmt$ExprStmt", Stmt)

function Stmt.ExprStmt.new(expr)
    return setmetatable({expr = expr}, Stmt.ExprStmt)
end

__K2L_DataClass(Stmt.ExprStmt, {"expr"})
local Parser = __K2L_Class("calc.Parser")
local statement, expression, unary, primary

local function advance(self)
    local ____value_3 = self.tokens:get(self.i)
    if ____value_3.type ~= TokenType.EOF then
        self.i = self.i + 1
    end
    return ____value_3
end

local function match(self, ____type, text)
    local t = self:getPeek()
    if t.type ~= ____type or text ~= nil and t.text ~= text then
        return false
    end
    advance(self)
    return true
end

local function expect(self, ____type, text)
    local t = self:getPeek()
    if t.type ~= ____type or text ~= nil and t.text ~= text then
        error(SyntaxError.new("expected " .. (text or ____type.name:lower()) .. " but found " .. __K2L_Str(t), t.line))
    end
    return advance(self)
end

local function block(self)
    expect(self, TokenType.LBRACE)
    local body = __K2L_ListOf()
    while not match(self, TokenType.RBRACE) do
        body:add(statement(self))
    end
    return body
end

function statement(self)
    if match(self, TokenType.KEYWORD, "let") then
        local name = expect(self, TokenType.IDENT).text
        expect(self, TokenType.OP, "=")
        local ____value_7 = Stmt.Let.new(name, expression(self))
        expect(self, TokenType.SEMI)
        return ____value_7
    elseif match(self, TokenType.KEYWORD, "print") then
        local ____value_6 = Stmt.Print.new(expression(self))
        expect(self, TokenType.SEMI)
        return ____value_6
    elseif match(self, TokenType.KEYWORD, "if") then
        local cond = expression(self)
        local ____then = block(self)
        local otherwise
        if match(self, TokenType.KEYWORD, "else") then
            otherwise = self:getPeek().text == "if" and __K2L_ListOf(statement(self)) or block(self)
        else
            otherwise = nil
        end
        return Stmt.If.new(cond, ____then, otherwise)
    elseif match(self, TokenType.KEYWORD, "while") then
        return Stmt.While.new(expression(self), block(self))
    elseif match(self, TokenType.KEYWORD, "fun") then
        local name = expect(self, TokenType.IDENT).text
        expect(self, TokenType.LPAREN)
        local params = __K2L_ListOf()
        if not match(self, TokenType.RPAREN) then
            repeat
                params:add(expect(self, TokenType.IDENT).text)
            until not match(self, TokenType.COMMA)
            expect(self, TokenType.RPAREN)
        end
        return Stmt.FunDecl.new(name, params, block(self))
    elseif match(self, TokenType.KEYWORD, "return") then
        local value
        if self:getPeek().type == TokenType.SEMI then
            value = nil
        else
            value = expression(self)
        end
        expect(self, TokenType.SEMI)
        return Stmt.Return.new(value)
    elseif self:getPeek().type == TokenType.IDENT and self.tokens:get(self.i + 1).text == "=" then
        local name = advance(self).text
        advance(self)
        local ____value_5 = Stmt.Assign.new(name, expression(self))
        expect(self, TokenType.SEMI)
        return ____value_5
    else
        local ____value_4 = Stmt.ExprStmt.new(expression(self))
        expect(self, TokenType.SEMI)
        return ____value_4
    end
end

function expression(self, level)
    if level == nil then
        level = 0
    end
    if level == self.levels.size then
        return unary(self)
    end
    local left = expression(self, level + 1)
    while self:getPeek().type == TokenType.OP and self.levels:get(level):contains(self:getPeek().text) do
        local op = advance(self)
        left = Expr.Binary.new(left, op.text, expression(self, level + 1), op.line)
    end
    return left
end

function unary(self)
    local t = self:getPeek()
    if t.type == TokenType.OP and (t.text == "-" or t.text == "!") then
        advance(self)
        return Expr.Unary.new(t.text, unary(self), t.line)
    end
    return primary(self)
end

function primary(self)
    local t = advance(self)
    local ____subject = t.type
    if ____subject == TokenType.NUMBER then
        local ____value_9 = __K2L_StringToDoubleOrNull(t.text)
        if ____value_9 == nil then
            error(SyntaxError.new("bad number " .. t.text, t.line))
        end
        return Expr.Num.new(____value_9, t.line)
    elseif ____subject == TokenType.STRING then
        return Expr.Str.new(t.text, t.line)
    elseif ____subject == TokenType.KEYWORD then
        local ____subject_1 = t.text
        if ____subject_1 == "true" or ____subject_1 == "false" then
            return Expr.Bool.new(__K2L_Text.toBoolean(t.text), t.line)
        else
            error(SyntaxError.new("unexpected keyword " .. t.text, t.line))
        end
    elseif ____subject == TokenType.IDENT then
        if match(self, TokenType.LPAREN) then
            local args = __K2L_ListOf()
            if not match(self, TokenType.RPAREN) then
                repeat
                    args:add(expression(self))
                until not match(self, TokenType.COMMA)
                expect(self, TokenType.RPAREN)
            end
            return Expr.Call.new(t.text, args, t.line)
        else
            return Expr.Var.new(t.text, t.line)
        end
    elseif ____subject == TokenType.LPAREN then
        local ____value_8 = expression(self)
        expect(self, TokenType.RPAREN)
        return ____value_8
    else
        error(SyntaxError.new("unexpected " .. __K2L_Str(t), t.line))
    end
end

function Parser:____init(tokens)
    self.tokens = tokens
    self.i = 0
    self.levels = __K2L_ListOf(__K2L_ListOf("||"), __K2L_ListOf("&&"), __K2L_ListOf("==", "!="), __K2L_ListOf("<", "<=", ">", ">="), __K2L_ListOf("+", "-"), __K2L_ListOf("*", "/", "%"))
end

function Parser:getPeek()
    return self.tokens:get(self.i)
end

function Parser:program()
    return __K2L_GenerateSequenceLazy(function()
        if self:getPeek().type == TokenType.EOF then
            return nil
        else
            return statement(self)
        end
    end):toList()
end

local Value = __K2L_Class("calc.Value")
Value.NumV = __K2L_Class("calc.Value$NumV", Value)

function Value.NumV.new(n)
    return setmetatable({n = n}, Value.NumV)
end

function Value.NumV:toString()
    return self.n == math.floor(self.n) and not __K2L_Num.isInfinite(self.n) and tostring(__K2L_Truncate(self.n)) or tostring(self.n)
end

__K2L_DataClass(Value.NumV, {"n"})
Value.StrV = __K2L_Class("calc.Value$StrV", Value)

function Value.StrV.new(s)
    return setmetatable({s = s}, Value.StrV)
end

function Value.StrV:toString()
    return self.s
end

__K2L_DataClass(Value.StrV, {"s"})
Value.BoolV = __K2L_Class("calc.Value$BoolV", Value)

function Value.BoolV.new(b)
    return setmetatable({b = b}, Value.BoolV)
end

function Value.BoolV:toString()
    return tostring(self.b)
end

__K2L_DataClass(Value.BoolV, {"b"})
Value.Nil = __K2L_Class("calc.Value$Nil", Value)

function Value.Nil:toString()
    return "nil"
end

Value.FunV = __K2L_Class("calc.Value$FunV", Value)

function Value.FunV.new(decl, closure)
    return setmetatable({decl = decl, closure = closure}, Value.FunV)
end

function Value.FunV:toString()
    return "<fun " .. self.decl.name .. "/" .. self.decl.params.size .. ">"
end

Value.Native = __K2L_Class("calc.Value$Native", Value)

function Value.Native.new(name, arity, fn)
    return setmetatable({name = name, arity = arity, fn = fn}, Value.Native)
end

function Value.Native:toString()
    return "<native " .. self.name .. ">"
end

Env = __K2L_Class("calc.Env")

function Env:____init(parent)
    self.parent = parent
    self.vars = __K2L_Map.new()
end

function Env:define(name, value)
    local ____object = self.vars
    ____object:set(name, value)
end

function Env:lookup(name, line)
    local ____value_10 = self.vars:get(name)
    if ____value_10 == nil then
        local ____receiver_2 = self.parent
        ____value_10 = ____receiver_2 and ____receiver_2:lookup(name, line)
    end
    local ____value_11 = ____value_10
    if ____value_11 == nil then
        error(RuntimeError.new("undefined variable '" .. name .. "'", line))
    end
    return ____value_11
end

function Env:assign(name, value, line)
    if self.vars:containsKey(name) then
        local ____object_1 = self.vars
        ____object_1:set(name, value)
    elseif self.parent ~= nil then
        self.parent:assign(name, value, line)
    else
        error(RuntimeError.new("assignment to undeclared '" .. name .. "'", line))
    end
end

function Env:getDepth()
    local ____receiver_3 = self.parent
    return 1 + (____receiver_3 and ____receiver_3:getDepth() or 0)
end

local ReturnSignal = __K2L_Class("calc.ReturnSignal", __K2L_RuntimeException)

function ReturnSignal:____init(value)
    __K2L_RuntimeException.____init(self)
    self.value = value
end

local Interpreter = __K2L_Class("calc.Interpreter")
local exec, truthy

local function execBlock(self, stmts, env)
    for ____i = 1, stmts.size do
        local it = stmts[____i]
        exec(self, it, env)
    end
end

function exec(self, stmt, env)
    self.steps = self.steps + 1
    local ____mt = getmetatable(stmt)
    if ____mt == Stmt.Let then
        env:define(stmt.name, self:eval(stmt.init, env))
    elseif ____mt == Stmt.Assign then
        env:assign(stmt.name, self:eval(stmt.value, env), stmt.value.line)
    elseif ____mt == Stmt.Print then
        self.out(__K2L_Str(self:eval(stmt.expr, env)))
    elseif ____mt == Stmt.If then
        if truthy(self, self:eval(stmt.cond, env)) then
            execBlock(self, stmt["then"], Env.new(env))
        else
            local ____receiver_5 = stmt.otherwise
            if ____receiver_5 ~= nil then
                execBlock(self, ____receiver_5, Env.new(env))
            end
        end
    elseif ____mt == Stmt.While then
        local guard = 0
        while truthy(self, self:eval(stmt.cond, env)) do
            guard = guard + 1
            if guard > 10000 then
                error(RuntimeError.new("loop limit exceeded", stmt.cond.line))
            end
            execBlock(self, stmt.body, Env.new(env))
        end
    elseif ____mt == Stmt.FunDecl then
        env:define(stmt.name, Value.FunV.new(stmt, env))
    elseif ____mt == Stmt.Return then
        local ____receiver_4 = stmt.value
        error(ReturnSignal.new(____receiver_4 and self:eval(____receiver_4, env) or Value.Nil))
    elseif ____mt == Stmt.ExprStmt then
        self:eval(stmt.expr, env)
    end
end

function truthy(self, v)
    local ____mt_1 = getmetatable(v)
    if ____mt_1 == Value.BoolV then
        return v.b
    elseif __K2L_Equals(v, Value.Nil) then
        return false
    elseif ____mt_1 == Value.NumV then
        return v.n ~= 0.0
    else
        return true
    end
end

local function num(self, v, line)
    local ____receiver_6 = getmetatable(v) == Value.NumV and v or nil
    local ____value_12 = ____receiver_6 and (getmetatable(v) == Value.NumV and v or nil).n
    if ____value_12 == nil then
        error(RuntimeError.new("expected a number, got " .. __K2L_Str(__K2L_SimpleName(v)) .. " " .. __K2L_Str(v), line))
    end
    return ____value_12
end

local function binary(self, e, env)
    if e.op == "&&" then
        local ____value_13 = self:eval(e.left, env)
        local ____result
        ____result = not truthy(self, ____value_13) and ____value_13 or self:eval(e.right, env)
        return ____result
    end
    if e.op == "||" then
        local ____value_14 = self:eval(e.left, env)
        local ____result_1
        ____result_1 = truthy(self, ____value_14) and ____value_14 or self:eval(e.right, env)
        return ____result_1
    end
    local l = self:eval(e.left, env)
    local r = self:eval(e.right, env)
    local ____subject_2 = e.op
    if ____subject_2 == "+" then
        return (getmetatable(l) == Value.StrV or getmetatable(r) == Value.StrV) and Value.StrV.new(__K2L_Str(l) .. __K2L_Str(r)) or Value.NumV.new(num(self, l, e.line) + num(self, r, e.line))
    elseif ____subject_2 == "-" then
        return Value.NumV.new(num(self, l, e.line) - num(self, r, e.line))
    elseif ____subject_2 == "*" then
        return Value.NumV.new(num(self, l, e.line) * num(self, r, e.line))
    elseif ____subject_2 == "/" then
        local d = num(self, r, e.line)
        if d == 0.0 then
            error(RuntimeError.new("division by zero", e.line))
        end
        return Value.NumV.new(num(self, l, e.line) / d)
    elseif ____subject_2 == "%" then
        return Value.NumV.new(num(self, l, e.line) % num(self, r, e.line))
    elseif ____subject_2 == "==" then
        return Value.BoolV.new(__K2L_Equals(l, r))
    elseif ____subject_2 == "!=" then
        return Value.BoolV.new(not __K2L_Equals(l, r))
    elseif ____subject_2 == "<" then
        return Value.BoolV.new(num(self, l, e.line) < num(self, r, e.line))
    elseif ____subject_2 == "<=" then
        return Value.BoolV.new(num(self, l, e.line) <= num(self, r, e.line))
    elseif ____subject_2 == ">" then
        return Value.BoolV.new(num(self, l, e.line) > num(self, r, e.line))
    elseif ____subject_2 == ">=" then
        return Value.BoolV.new(num(self, l, e.line) >= num(self, r, e.line))
    else
        error(RuntimeError.new("unknown operator " .. e.op, e.line))
    end
end

local function call(self, e, env)
    local callee = env:lookup(e.callee, e.line)
    local ____list = e.args
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = self:eval(it, env)
    end
    local args = __K2L_ListWrap(____out, ____count)
    local ____mt_2 = getmetatable(callee)
    if ____mt_2 == Value.Native then
        if args.size ~= callee.arity then
            error(RuntimeError.new(callee.name .. " expects " .. callee.arity .. " args", e.line))
        end
        return callee.fn(args)
    elseif ____mt_2 == Value.FunV then
        local params = callee.decl.params
        if args.size ~= params.size then
            error(RuntimeError.new(callee.decl.name .. " expects " .. params.size .. " args, got " .. args.size, e.line))
        end
        self.callDepth = self.callDepth + 1
        if self.callDepth > 120 then
            error(RuntimeError.new("stack overflow in " .. callee.decl.name, e.line))
        end
        local ____local = Env.new(callee.closure)
        local ____list_1 = params:zip(args)
        for ____i_2 = 1, ____list_1.size do
            local ____it_1 = ____list_1[____i_2]
            do
                local p, a = ____it_1.first, ____it_1.second
                ____local:define(p, a)
            end
        end
        local ____ok, ____result_2, ____returned = pcall(function()
            execBlock(self, callee.decl.body, ____local)
            return true, Value.Nil
        end)
        if not ____ok then
            ____ok, ____result_2, ____returned = pcall(function()
                local ____error = __K2L_ToThrowable(____result_2)
                if getmetatable(____error) == ReturnSignal then
                    local r = ____error
                    return true, r.value
                else
                    error(____error, 0)
                end
            end)
        end
        self.callDepth = self.callDepth - 1
        if not ____ok then
            error(____result_2, 0)
        end
        if ____result_2 then
            return ____returned
        end
    else
        error(RuntimeError.new("'" .. e.callee .. "' is not callable", e.line))
    end
end

local ____lambda_1 = function(args)
    return Value.StrV.new(__K2L_Str(args:get(0)))
end
function Interpreter:____init(out)
    self.out = out
    self.globals = Env.new()
    self.callDepth = 0
    self.steps = 0
    self.globals:define("len", Value.Native.new("len", 1, function(____destructured)
        local s = ____destructured[1]
        local ____receiver_7 = getmetatable(s) == Value.StrV and s or nil
        local ____receiver_8 = ____receiver_7 and (getmetatable(s) == Value.StrV and s or nil).s
        local ____receiver_9 = ____receiver_8 and #____receiver_8
        return Value.NumV.new(____receiver_9 and ____receiver_9 + 0.0 or -1.0)
    end))
    self.globals:define("str", Value.Native.new("str", 1, ____lambda_1))
    self.globals:define("max", Value.Native.new("max", 2, function(____destructured_1)
        local a, b = ____destructured_1[1], ____destructured_1[2]
        return num(self, a, 0) >= num(self, b, 0) and a or b
    end))
end

function Interpreter:run(program)
    execBlock(self, program, self.globals)
end

function Interpreter:eval(e, env)
    local ____mt_3 = getmetatable(e)
    if ____mt_3 == Expr.Num then
        return Value.NumV.new(e.value)
    elseif ____mt_3 == Expr.Str then
        return Value.StrV.new(e.value)
    elseif ____mt_3 == Expr.Bool then
        return Value.BoolV.new(e.value)
    elseif ____mt_3 == Expr.Var then
        return env:lookup(e.name, e.line)
    elseif ____mt_3 == Expr.Unary then
        local ____subject_3 = e.op
        if ____subject_3 == "-" then
            return Value.NumV.new(-num(self, self:eval(e.operand, env), e.line))
        else
            return Value.BoolV.new(not truthy(self, self:eval(e.operand, env)))
        end
    elseif ____mt_3 == Expr.Binary then
        return binary(self, e, env)
    elseif ____mt_3 == Expr.Call then
        return call(self, e, env)
    end
end

local function runSource(name, src)
    print("== " .. name)
    local output = __K2L_ListOf()
    local interp = Interpreter.new(function(it)
        output:add(it)
    end)
    local ____ok_1, ____result_3 = pcall(function()
        local program = Parser.new(Lexer.new(src):tokens()):program()
        interp:run(program)
    end)
    if not ____ok_1 then
        ____ok_1, ____result_3 = pcall(function()
            local ____error_1 = __K2L_ToThrowable(____result_3)
            if getmetatable(____error_1) == SyntaxError then
                local e = ____error_1
                output:add("syntax: " .. __K2L_Str(e))
            elseif __K2L_InstanceOf(____error_1, LangException) then
                local e = ____error_1
                local ____arg = "runtime: " .. __K2L_Str(e)
                local ____receiver_10 = e.cause
                output:add(____arg .. (____receiver_10 and " (caused by " .. __K2L_Str(____receiver_10.message) .. ")" or ""))
            else
                error(____error_1, 0)
            end
        end)
    end
    for ____i_3 = 1, output.size do
        local s = output[____i_3]
        local i = ____i_3 - 1
        print("  " .. i + 1 .. ": " .. s)
    end
    print("  steps=" .. interp.steps)
    if not ____ok_1 then
        error(____result_3, 0)
    end
end

local ____lambda_2 = function(it) return it.type end
local ____lambda_3 = function(it) return it.key end
local ____lambda_4 = function(it) return __K2L_Str(it.key) .. "=" .. it.value end
local function main()
    runSource("fib", __K2L_Text.trimIndent("\n        fun fib(n) { if n < 2 { return n; } return fib(n - 1) + fib(n - 2); }\n        let i = 0;\n        while i < 10 { print \"fib(\" + str(i) + \") = \" + fib(i); i = i + 1; }\n        "))
    runSource("closures", __K2L_Text.trimIndent("\n        fun counter() {\n          let n = 0;\n          fun inc() { n = n + 1; return n; }\n          return inc;\n        }\n        let c = counter();\n        c(); c();\n        print \"count: \" + c();\n        print max(3, 7) * 2 / 4;\n        print len(\"hello\") % 3;\n        print !(1 < 2) || 3 >= 3 && \"x\" != \"y\";\n        "))
    runSource("syntax", "let x = 1;\nlet y = (2 + ;\n")
    runSource("undefined", "print 1;\nprint nope + 1;")
    runSource("zero", "fun f(a) { return 10 / a; }\nprint f(2);\nprint f(0);")
    runSource("strings", "print \"tab\\there\" + \" \" + 2.5 * 2;\nprint \"oops")
    runSource("recursion", "fun r(n) { return r(n + 1); }\nr(0);")
    runSource("arity", "fun two(a, b) { return a; }\nprint two(1);")
    local tokens = Lexer.new("let total = a1 + 42 >= b;"):tokens()
    print(tokens:joinToString(" | "))
    print(tokens:groupingBy(____lambda_2):eachCount():getEntries():sortedBy(____lambda_3, true):joinToString(nil, nil, nil, nil, nil, ____lambda_4))
    local ast = Parser.new(Lexer.new("print -x * (y + 2);"):tokens()):program():single()
    print(__K2L_Str(ast))
    local nested = Env.new(Env.new(Env.new()))
    print("depth=" .. nested:getDepth())
    local wrapped = RuntimeError.new("wrapped", 9, __K2L_IllegalStateException.new("inner"))
    local ____receiver_11 = wrapped.cause
    local ____value_15 = wrapped.cause
    print(__K2L_Str(wrapped.message) .. " <- " .. __K2L_Str(____receiver_11 and ____receiver_11.message) .. " " .. tostring(__K2L_InstanceOf(____value_15, __K2L_IllegalStateException)))
end

__K2L_RunMain(main)
return {LangException = LangException, SyntaxError = SyntaxError, RuntimeError = RuntimeError, TokenType = TokenType, Token = Token, Lexer = Lexer, Expr = Expr, Stmt = Stmt, Parser = Parser, Value = Value, Env = Env, Interpreter = Interpreter, runSource = runSource}
