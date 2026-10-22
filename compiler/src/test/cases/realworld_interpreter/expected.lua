local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_Hash = ____lualib.__K2L_Hash
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
    if cause == nil then
        cause = nil
    end
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
    if cause == nil then
        cause = nil
    end
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

function Token:____init(____type, text, line)
    self.type = ____type
    self.text = text
    self.line = line
end

function Token.new(____type, text, line)
    return setmetatable({type = ____type, text = text, line = line}, Token)
end

function Token:toString()
    return self.type == TokenType.EOF and "<eof>" or __K2L_Str(self.type) .. " '" .. self.text .. "'"
end

function Token:hashCode()
    return (31 * (31 * __K2L_Hash(self.type) + __K2L_Hash(self.text)) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Token:equals(other)
    return getmetatable(other) == Token and self.type == other.type and self.text == other.text and self.line == other.line
end

local Lexer = __K2L_Class("calc.Lexer")

function Lexer:____init(src)
    self.src = src
    self.pos = 0
    self.line = 1
end

function Lexer:tokens()
    local ____builder = __K2L_ListOf()
    while true do
        local t = self:next()
        ____builder:add(t)
        if t.type == TokenType.EOF then
            break
        end
    end
    return ____builder
end

function Lexer:peekChar(offset)
    if offset == nil then
        offset = 0
    end
    return __K2L_Text.getOrNull(self.src, self.pos + offset)
end

function Lexer:next()
    self:skipBlanks()
    local ____value = self:peekChar()
    if ____value == nil then
        return Token.new(TokenType.EOF, "", self.line)
    end
    local c = ____value
    local start = self.pos
    if __K2L_IsDigit[c] == true then
        while true do
            local ____receiver_1 = self:peekChar()
            if (____receiver_1 and (__K2L_IsDigit[____receiver_1] == true or ____receiver_1 == ".")) ~= true then
                break
            end
            self.pos = self.pos + 1
        end
        return Token.new(TokenType.NUMBER, __K2L_Text.substring(self.src, start, self.pos), self.line)
    elseif __K2L_IsLetter[c] == true or c == "_" then
        while true do
            local ____receiver = self:peekChar()
            if (____receiver and (__K2L_IsLetterOrDigit[____receiver] == true or ____receiver == "_")) ~= true then
                break
            end
            self.pos = self.pos + 1
        end
        local word = __K2L_Text.substring(self.src, start, self.pos)
        return Token.new(Lexer.KEYWORDS:contains(word) and TokenType.KEYWORD or TokenType.IDENT, word, self.line)
    elseif c == "\"" then
        return self:readString()
    else
        local two = __K2L_Text.substring(self.src, self.pos, math.min(self.pos + 2, #self.src))
        if Lexer.TWO_CHAR_OPS:contains(two) then
            self.pos = self.pos + 2
            return Token.new(TokenType.OP, two, self.line)
        elseif Lexer.SINGLE:containsKey(c) then
            self.pos = self.pos + 1
            return Token.new(Lexer.SINGLE:getValue(c), c, self.line)
        elseif __K2L_StringContains("+-*/%<>=!", c) then
            self.pos = self.pos + 1
            return Token.new(TokenType.OP, c, self.line)
        else
            error(SyntaxError.new("unexpected character '" .. c .. "'", self.line))
        end
    end
end

function Lexer:readString()
    self.pos = self.pos + 1
    local sb = __K2L_StringBuilder.new()
    while true do
        local ____value_1 = self:peekChar()
        if ____value_1 == nil then
            error(SyntaxError.new("unterminated string", self.line))
        end
        local ch = ____value_1
        self.pos = self.pos + 1
        if ch == "\"" then
            break
        end
        if ch == "\\" then
            local esc = self:peekChar()
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

function Lexer:skipBlanks()
    while true do
        local ____value_2 = self:peekChar()
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
            while self:peekChar() ~= nil and self:peekChar() ~= "\n" do
                self.pos = self.pos + 1
            end
        else
            return
        end
    end
end

function Lexer:____initCompanion()
    self.KEYWORDS = __K2L_SetOf("let", "fun", "if", "else", "while", "return", "print", "true", "false")
    self.TWO_CHAR_OPS = __K2L_ListOf("==", "!=", "<=", ">=", "&&", "||")
    self.SINGLE = __K2L_MapOf(__K2L_Pair.new("(", TokenType.LPAREN), __K2L_Pair.new(")", TokenType.RPAREN), __K2L_Pair.new("{", TokenType.LBRACE), __K2L_Pair.new("}", TokenType.RBRACE), __K2L_Pair.new(",", TokenType.COMMA), __K2L_Pair.new(";", TokenType.SEMI))
end

__K2L_LazyObject(Lexer, "____initCompanion")
local Expr = __K2L_Class("calc.Expr")
Expr.Num = __K2L_Class("calc.Expr$Num", nil, Expr)

function Expr.Num:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Num.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Num)
end

function Expr.Num:toString()
    return "Num(value=" .. self.value .. ", line=" .. self.line .. ")"
end

function Expr.Num:hashCode()
    return (31 * __K2L_Hash(self.value) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Num:equals(other)
    return getmetatable(other) == Expr.Num and self.value == other.value and self.line == other.line
end

Expr.Str = __K2L_Class("calc.Expr$Str", nil, Expr)

function Expr.Str:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Str.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Str)
end

function Expr.Str:toString()
    return "Str(value=" .. self.value .. ", line=" .. self.line .. ")"
end

function Expr.Str:hashCode()
    return (31 * __K2L_Hash(self.value) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Str:equals(other)
    return getmetatable(other) == Expr.Str and self.value == other.value and self.line == other.line
end

Expr.Bool = __K2L_Class("calc.Expr$Bool", nil, Expr)

function Expr.Bool:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Bool.new(value, line)
    return setmetatable({value = value, line = line}, Expr.Bool)
end

function Expr.Bool:toString()
    return "Bool(value=" .. tostring(self.value) .. ", line=" .. self.line .. ")"
end

function Expr.Bool:hashCode()
    return (31 * (self.value and 1231 or 1237) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Bool:equals(other)
    return getmetatable(other) == Expr.Bool and self.value == other.value and self.line == other.line
end

Expr.Var = __K2L_Class("calc.Expr$Var", nil, Expr)

function Expr.Var:____init(name, line)
    self.name = name
    self.line = line
end

function Expr.Var.new(name, line)
    return setmetatable({name = name, line = line}, Expr.Var)
end

function Expr.Var:toString()
    return "Var(name=" .. self.name .. ", line=" .. self.line .. ")"
end

function Expr.Var:hashCode()
    return (31 * __K2L_Hash(self.name) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Var:equals(other)
    return getmetatable(other) == Expr.Var and self.name == other.name and self.line == other.line
end

Expr.Unary = __K2L_Class("calc.Expr$Unary", nil, Expr)

function Expr.Unary:____init(op, operand, line)
    self.op = op
    self.operand = operand
    self.line = line
end

function Expr.Unary.new(op, operand, line)
    return setmetatable({op = op, operand = operand, line = line}, Expr.Unary)
end

function Expr.Unary:toString()
    return "Unary(op=" .. self.op .. ", operand=" .. __K2L_Str(self.operand) .. ", line=" .. self.line .. ")"
end

function Expr.Unary:hashCode()
    return (31 * (31 * __K2L_Hash(self.op) + __K2L_Hash(self.operand)) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Unary:equals(other)
    return getmetatable(other) == Expr.Unary and self.op == other.op and __K2L_Equals(self.operand, other.operand) and self.line == other.line
end

Expr.Binary = __K2L_Class("calc.Expr$Binary", nil, Expr)

function Expr.Binary:____init(left, op, right, line)
    self.left = left
    self.op = op
    self.right = right
    self.line = line
end

function Expr.Binary.new(left, op, right, line)
    return setmetatable({left = left, op = op, right = right, line = line}, Expr.Binary)
end

function Expr.Binary:toString()
    return "Binary(left=" .. __K2L_Str(self.left) .. ", op=" .. self.op .. ", right=" .. __K2L_Str(self.right) .. ", line=" .. self.line .. ")"
end

function Expr.Binary:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.left) + __K2L_Hash(self.op)) + __K2L_Hash(self.right)) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Binary:equals(other)
    return getmetatable(other) == Expr.Binary and __K2L_Equals(self.left, other.left) and self.op == other.op and __K2L_Equals(self.right, other.right) and self.line == other.line
end

Expr.Call = __K2L_Class("calc.Expr$Call", nil, Expr)

function Expr.Call:____init(callee, args, line)
    self.callee = callee
    self.args = args
    self.line = line
end

function Expr.Call.new(callee, args, line)
    return setmetatable({callee = callee, args = args, line = line}, Expr.Call)
end

function Expr.Call:toString()
    return "Call(callee=" .. self.callee .. ", args=" .. __K2L_Str(self.args) .. ", line=" .. self.line .. ")"
end

function Expr.Call:hashCode()
    return (31 * (31 * __K2L_Hash(self.callee) + __K2L_Hash(self.args)) + self.line + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Expr.Call:equals(other)
    return getmetatable(other) == Expr.Call and self.callee == other.callee and __K2L_Equals(self.args, other.args) and self.line == other.line
end

local Stmt = __K2L_Class("calc.Stmt")
Stmt.Let = __K2L_Class("calc.Stmt$Let", Stmt)

function Stmt.Let:____init(name, init)
    self.name = name
    self.init = init
end

function Stmt.Let.new(name, init)
    return setmetatable({name = name, init = init}, Stmt.Let)
end

function Stmt.Let:toString()
    return "Let(name=" .. self.name .. ", init=" .. __K2L_Str(self.init) .. ")"
end

function Stmt.Let:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.init) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stmt.Let:equals(other)
    return getmetatable(other) == Stmt.Let and self.name == other.name and __K2L_Equals(self.init, other.init)
end

Stmt.Assign = __K2L_Class("calc.Stmt$Assign", Stmt)

function Stmt.Assign:____init(name, value)
    self.name = name
    self.value = value
end

function Stmt.Assign.new(name, value)
    return setmetatable({name = name, value = value}, Stmt.Assign)
end

function Stmt.Assign:toString()
    return "Assign(name=" .. self.name .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Stmt.Assign:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.value) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stmt.Assign:equals(other)
    return getmetatable(other) == Stmt.Assign and self.name == other.name and __K2L_Equals(self.value, other.value)
end

Stmt.Print = __K2L_Class("calc.Stmt$Print", Stmt)

function Stmt.Print:____init(expr)
    self.expr = expr
end

function Stmt.Print.new(expr)
    return setmetatable({expr = expr}, Stmt.Print)
end

function Stmt.Print:toString()
    return "Print(expr=" .. __K2L_Str(self.expr) .. ")"
end

function Stmt.Print:hashCode()
    return __K2L_Hash(self.expr)
end

function Stmt.Print:equals(other)
    return getmetatable(other) == Stmt.Print and __K2L_Equals(self.expr, other.expr)
end

Stmt.If = __K2L_Class("calc.Stmt$If", Stmt)

function Stmt.If:____init(cond, ____then, otherwise)
    self.cond = cond
    self["then"] = ____then
    self.otherwise = otherwise
end

function Stmt.If.new(cond, ____then, otherwise)
    return setmetatable({cond = cond, ["then"] = ____then, otherwise = otherwise}, Stmt.If)
end

function Stmt.If:toString()
    return "If(cond=" .. __K2L_Str(self.cond) .. ", then=" .. __K2L_Str(self["then"]) .. ", otherwise=" .. __K2L_Str(self.otherwise) .. ")"
end

function Stmt.If:hashCode()
    return (31 * (31 * __K2L_Hash(self.cond) + __K2L_Hash(self["then"])) + __K2L_Hash(self.otherwise) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stmt.If:equals(other)
    return getmetatable(other) == Stmt.If and __K2L_Equals(self.cond, other.cond) and __K2L_Equals(self["then"], other["then"]) and __K2L_Equals(self.otherwise, other.otherwise)
end

Stmt.While = __K2L_Class("calc.Stmt$While", Stmt)

function Stmt.While:____init(cond, body)
    self.cond = cond
    self.body = body
end

function Stmt.While.new(cond, body)
    return setmetatable({cond = cond, body = body}, Stmt.While)
end

function Stmt.While:toString()
    return "While(cond=" .. __K2L_Str(self.cond) .. ", body=" .. __K2L_Str(self.body) .. ")"
end

function Stmt.While:hashCode()
    return (31 * __K2L_Hash(self.cond) + __K2L_Hash(self.body) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stmt.While:equals(other)
    return getmetatable(other) == Stmt.While and __K2L_Equals(self.cond, other.cond) and __K2L_Equals(self.body, other.body)
end

Stmt.FunDecl = __K2L_Class("calc.Stmt$FunDecl", Stmt)

function Stmt.FunDecl:____init(name, params, body)
    self.name = name
    self.params = params
    self.body = body
end

function Stmt.FunDecl.new(name, params, body)
    return setmetatable({name = name, params = params, body = body}, Stmt.FunDecl)
end

function Stmt.FunDecl:toString()
    return "FunDecl(name=" .. self.name .. ", params=" .. __K2L_Str(self.params) .. ", body=" .. __K2L_Str(self.body) .. ")"
end

function Stmt.FunDecl:hashCode()
    return (31 * (31 * __K2L_Hash(self.name) + __K2L_Hash(self.params)) + __K2L_Hash(self.body) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stmt.FunDecl:equals(other)
    return getmetatable(other) == Stmt.FunDecl and self.name == other.name and __K2L_Equals(self.params, other.params) and __K2L_Equals(self.body, other.body)
end

Stmt.Return = __K2L_Class("calc.Stmt$Return", Stmt)

function Stmt.Return:____init(value)
    self.value = value
end

function Stmt.Return.new(value)
    return setmetatable({value = value}, Stmt.Return)
end

function Stmt.Return:toString()
    return "Return(value=" .. __K2L_Str(self.value) .. ")"
end

function Stmt.Return:hashCode()
    return __K2L_Hash(self.value)
end

function Stmt.Return:equals(other)
    return getmetatable(other) == Stmt.Return and __K2L_Equals(self.value, other.value)
end

Stmt.ExprStmt = __K2L_Class("calc.Stmt$ExprStmt", Stmt)

function Stmt.ExprStmt:____init(expr)
    self.expr = expr
end

function Stmt.ExprStmt.new(expr)
    return setmetatable({expr = expr}, Stmt.ExprStmt)
end

function Stmt.ExprStmt:toString()
    return "ExprStmt(expr=" .. __K2L_Str(self.expr) .. ")"
end

function Stmt.ExprStmt:hashCode()
    return __K2L_Hash(self.expr)
end

function Stmt.ExprStmt:equals(other)
    return getmetatable(other) == Stmt.ExprStmt and __K2L_Equals(self.expr, other.expr)
end

local Parser = __K2L_Class("calc.Parser")

function Parser:____init(tokens)
    self.tokens = tokens
    self.i = 0
    self.levels = __K2L_ListOf(__K2L_ListOf("||"), __K2L_ListOf("&&"), __K2L_ListOf("==", "!="), __K2L_ListOf("<", "<=", ">", ">="), __K2L_ListOf("+", "-"), __K2L_ListOf("*", "/", "%"))
end

function Parser:getPeek()
    return self.tokens:get(self.i)
end

function Parser:advance()
    local ____value_3 = self.tokens:get(self.i)
    if ____value_3.type ~= TokenType.EOF then
        self.i = self.i + 1
    end
    return ____value_3
end

function Parser:match(____type, text)
    if text == nil then
        text = nil
    end
    local t = self:getPeek()
    if t.type ~= ____type or text ~= nil and t.text ~= text then
        return false
    end
    self:advance()
    return true
end

function Parser:expect(____type, text)
    if text == nil then
        text = nil
    end
    local t = self:getPeek()
    if t.type ~= ____type or text ~= nil and t.text ~= text then
        error(SyntaxError.new("expected " .. (text or ____type.name:lower()) .. " but found " .. __K2L_Str(t), t.line))
    end
    return self:advance()
end

function Parser:program()
    return __K2L_GenerateSequenceLazy(function()
        if self:getPeek().type == TokenType.EOF then
            return nil
        else
            return self:statement()
        end
    end):toList()
end

function Parser:block()
    self:expect(TokenType.LBRACE)
    local body = __K2L_ListOf()
    while not self:match(TokenType.RBRACE) do
        body:add(self:statement())
    end
    return body
end

function Parser:statement()
    if self:match(TokenType.KEYWORD, "let") then
        local name = self:expect(TokenType.IDENT).text
        self:expect(TokenType.OP, "=")
        local ____value_7 = Stmt.Let.new(name, self:expression())
        self:expect(TokenType.SEMI)
        return ____value_7
    elseif self:match(TokenType.KEYWORD, "print") then
        local ____value_6 = Stmt.Print.new(self:expression())
        self:expect(TokenType.SEMI)
        return ____value_6
    elseif self:match(TokenType.KEYWORD, "if") then
        local cond = self:expression()
        local ____then = self:block()
        local otherwise
        if self:match(TokenType.KEYWORD, "else") then
            otherwise = self:getPeek().text == "if" and __K2L_ListOf(self:statement()) or self:block()
        else
            otherwise = nil
        end
        return Stmt.If.new(cond, ____then, otherwise)
    elseif self:match(TokenType.KEYWORD, "while") then
        return Stmt.While.new(self:expression(), self:block())
    elseif self:match(TokenType.KEYWORD, "fun") then
        local name = self:expect(TokenType.IDENT).text
        self:expect(TokenType.LPAREN)
        local params = __K2L_ListOf()
        if not self:match(TokenType.RPAREN) then
            repeat
                params:add(self:expect(TokenType.IDENT).text)
            until not self:match(TokenType.COMMA)
            self:expect(TokenType.RPAREN)
        end
        return Stmt.FunDecl.new(name, params, self:block())
    elseif self:match(TokenType.KEYWORD, "return") then
        local value
        if self:getPeek().type == TokenType.SEMI then
            value = nil
        else
            value = self:expression()
        end
        self:expect(TokenType.SEMI)
        return Stmt.Return.new(value)
    elseif self:getPeek().type == TokenType.IDENT and self.tokens:get(self.i + 1).text == "=" then
        local name = self:advance().text
        self:advance()
        local ____value_5 = Stmt.Assign.new(name, self:expression())
        self:expect(TokenType.SEMI)
        return ____value_5
    else
        local ____value_4 = Stmt.ExprStmt.new(self:expression())
        self:expect(TokenType.SEMI)
        return ____value_4
    end
end

function Parser:expression(level)
    if level == nil then
        level = 0
    end
    if level == self.levels.size then
        return self:unary()
    end
    local left = self:expression(level + 1)
    while self:getPeek().type == TokenType.OP and self.levels:get(level):contains(self:getPeek().text) do
        local op = self:advance()
        left = Expr.Binary.new(left, op.text, self:expression(level + 1), op.line)
    end
    return left
end

function Parser:unary()
    local t = self:getPeek()
    if t.type == TokenType.OP and (t.text == "-" or t.text == "!") then
        self:advance()
        return Expr.Unary.new(t.text, self:unary(), t.line)
    end
    return self:primary()
end

function Parser:primary()
    local t = self:advance()
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
        if self:match(TokenType.LPAREN) then
            local args = __K2L_ListOf()
            if not self:match(TokenType.RPAREN) then
                repeat
                    args:add(self:expression())
                until not self:match(TokenType.COMMA)
                self:expect(TokenType.RPAREN)
            end
            return Expr.Call.new(t.text, args, t.line)
        else
            return Expr.Var.new(t.text, t.line)
        end
    elseif ____subject == TokenType.LPAREN then
        local ____value_8 = self:expression()
        self:expect(TokenType.RPAREN)
        return ____value_8
    else
        error(SyntaxError.new("unexpected " .. __K2L_Str(t), t.line))
    end
end

local Value = __K2L_Class("calc.Value")
Value.NumV = __K2L_Class("calc.Value$NumV", Value)

function Value.NumV:____init(n)
    self.n = n
end

function Value.NumV.new(n)
    return setmetatable({n = n}, Value.NumV)
end

function Value.NumV:toString()
    return self.n == math.floor(self.n) and not __K2L_Num.isInfinite(self.n) and tostring(__K2L_Truncate(self.n)) or tostring(self.n)
end

function Value.NumV:hashCode()
    return __K2L_Hash(self.n)
end

function Value.NumV:equals(other)
    return getmetatable(other) == Value.NumV and self.n == other.n
end

Value.StrV = __K2L_Class("calc.Value$StrV", Value)

function Value.StrV:____init(s)
    self.s = s
end

function Value.StrV.new(s)
    return setmetatable({s = s}, Value.StrV)
end

function Value.StrV:toString()
    return self.s
end

function Value.StrV:hashCode()
    return __K2L_Hash(self.s)
end

function Value.StrV:equals(other)
    return getmetatable(other) == Value.StrV and self.s == other.s
end

Value.BoolV = __K2L_Class("calc.Value$BoolV", Value)

function Value.BoolV:____init(b)
    self.b = b
end

function Value.BoolV.new(b)
    return setmetatable({b = b}, Value.BoolV)
end

function Value.BoolV:toString()
    return tostring(self.b)
end

function Value.BoolV:hashCode()
    return self.b and 1231 or 1237
end

function Value.BoolV:equals(other)
    return getmetatable(other) == Value.BoolV and self.b == other.b
end

Value.Nil = __K2L_Class("calc.Value$Nil", Value)

function Value.Nil:toString()
    return "nil"
end

Value.FunV = __K2L_Class("calc.Value$FunV", Value)

function Value.FunV:____init(decl, closure)
    self.decl = decl
    self.closure = closure
end

function Value.FunV.new(decl, closure)
    return setmetatable({decl = decl, closure = closure}, Value.FunV)
end

function Value.FunV:toString()
    return "<fun " .. self.decl.name .. "/" .. self.decl.params.size .. ">"
end

Value.Native = __K2L_Class("calc.Value$Native", Value)

function Value.Native:____init(name, arity, fn)
    self.name = name
    self.arity = arity
    self.fn = fn
end

function Value.Native.new(name, arity, fn)
    return setmetatable({name = name, arity = arity, fn = fn}, Value.Native)
end

function Value.Native:toString()
    return "<native " .. self.name .. ">"
end

Env = __K2L_Class("calc.Env")

function Env:____init(parent)
    if parent == nil then
        parent = nil
    end
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
        local ____receiver_4 = getmetatable(s) == Value.StrV and s or nil
        local ____receiver_5 = ____receiver_4 and (getmetatable(s) == Value.StrV and s or nil).s
        local ____receiver_6 = ____receiver_5 and #____receiver_5
        return Value.NumV.new(____receiver_6 and ____receiver_6 + 0.0 or -1.0)
    end))
    self.globals:define("str", Value.Native.new("str", 1, ____lambda_1))
    self.globals:define("max", Value.Native.new("max", 2, function(____destructured_1)
        local a, b = ____destructured_1[1], ____destructured_1[2]
        return self:num(a, 0) >= self:num(b, 0) and a or b
    end))
end

function Interpreter:run(program)
    self:execBlock(program, self.globals)
end

function Interpreter:execBlock(stmts, env)
    for ____i = 1, stmts.size do
        local it = stmts[____i]
        self:exec(it, env)
    end
end

function Interpreter:exec(stmt, env)
    self.steps = self.steps + 1
    local ____mt = getmetatable(stmt)
    if ____mt == Stmt.Let then
        env:define(stmt.name, self:eval(stmt.init, env))
    elseif ____mt == Stmt.Assign then
        env:assign(stmt.name, self:eval(stmt.value, env), stmt.value.line)
    elseif ____mt == Stmt.Print then
        self.out(__K2L_Str(self:eval(stmt.expr, env)))
    elseif ____mt == Stmt.If then
        if self:truthy(self:eval(stmt.cond, env)) then
            self:execBlock(stmt["then"], Env.new(env))
        else
            local ____receiver_8 = stmt.otherwise
            if ____receiver_8 ~= nil then
                self:execBlock(____receiver_8, Env.new(env))
            end
        end
    elseif ____mt == Stmt.While then
        local guard = 0
        while self:truthy(self:eval(stmt.cond, env)) do
            guard = guard + 1
            if guard > 10000 then
                error(RuntimeError.new("loop limit exceeded", stmt.cond.line))
            end
            self:execBlock(stmt.body, Env.new(env))
        end
    elseif ____mt == Stmt.FunDecl then
        env:define(stmt.name, Value.FunV.new(stmt, env))
    elseif ____mt == Stmt.Return then
        local ____receiver_7 = stmt.value
        error(ReturnSignal.new(____receiver_7 and self:eval(____receiver_7, env) or Value.Nil))
    elseif ____mt == Stmt.ExprStmt then
        self:eval(stmt.expr, env)
    end
end

function Interpreter:truthy(v)
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

function Interpreter:num(v, line)
    local ____receiver_9 = getmetatable(v) == Value.NumV and v or nil
    local ____value_12 = ____receiver_9 and (getmetatable(v) == Value.NumV and v or nil).n
    if ____value_12 == nil then
        error(RuntimeError.new("expected a number, got " .. __K2L_Str(__K2L_SimpleName(v)) .. " " .. __K2L_Str(v), line))
    end
    return ____value_12
end

function Interpreter:eval(e, env)
    local ____mt_2 = getmetatable(e)
    if ____mt_2 == Expr.Num then
        return Value.NumV.new(e.value)
    elseif ____mt_2 == Expr.Str then
        return Value.StrV.new(e.value)
    elseif ____mt_2 == Expr.Bool then
        return Value.BoolV.new(e.value)
    elseif ____mt_2 == Expr.Var then
        return env:lookup(e.name, e.line)
    elseif ____mt_2 == Expr.Unary then
        local ____subject_2 = e.op
        if ____subject_2 == "-" then
            return Value.NumV.new(-self:num(self:eval(e.operand, env), e.line))
        else
            return Value.BoolV.new(not self:truthy(self:eval(e.operand, env)))
        end
    elseif ____mt_2 == Expr.Binary then
        return self:binary(e, env)
    elseif ____mt_2 == Expr.Call then
        return self:call(e, env)
    end
end

function Interpreter:binary(e, env)
    if e.op == "&&" then
        local ____value_13 = self:eval(e.left, env)
        local ____result
        ____result = not self:truthy(____value_13) and ____value_13 or self:eval(e.right, env)
        return ____result
    end
    if e.op == "||" then
        local ____value_14 = self:eval(e.left, env)
        local ____result_1
        ____result_1 = self:truthy(____value_14) and ____value_14 or self:eval(e.right, env)
        return ____result_1
    end
    local l = self:eval(e.left, env)
    local r = self:eval(e.right, env)
    local ____subject_3 = e.op
    if ____subject_3 == "+" then
        return (getmetatable(l) == Value.StrV or getmetatable(r) == Value.StrV) and Value.StrV.new(__K2L_Str(l) .. __K2L_Str(r)) or Value.NumV.new(self:num(l, e.line) + self:num(r, e.line))
    elseif ____subject_3 == "-" then
        return Value.NumV.new(self:num(l, e.line) - self:num(r, e.line))
    elseif ____subject_3 == "*" then
        return Value.NumV.new(self:num(l, e.line) * self:num(r, e.line))
    elseif ____subject_3 == "/" then
        local d = self:num(r, e.line)
        if d == 0.0 then
            error(RuntimeError.new("division by zero", e.line))
        end
        return Value.NumV.new(self:num(l, e.line) / d)
    elseif ____subject_3 == "%" then
        return Value.NumV.new(self:num(l, e.line) % self:num(r, e.line))
    elseif ____subject_3 == "==" then
        return Value.BoolV.new(__K2L_Equals(l, r))
    elseif ____subject_3 == "!=" then
        return Value.BoolV.new(not __K2L_Equals(l, r))
    elseif ____subject_3 == "<" then
        return Value.BoolV.new(self:num(l, e.line) < self:num(r, e.line))
    elseif ____subject_3 == "<=" then
        return Value.BoolV.new(self:num(l, e.line) <= self:num(r, e.line))
    elseif ____subject_3 == ">" then
        return Value.BoolV.new(self:num(l, e.line) > self:num(r, e.line))
    elseif ____subject_3 == ">=" then
        return Value.BoolV.new(self:num(l, e.line) >= self:num(r, e.line))
    else
        error(RuntimeError.new("unknown operator " .. e.op, e.line))
    end
end

function Interpreter:call(e, env)
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
    local ____mt_3 = getmetatable(callee)
    if ____mt_3 == Value.Native then
        if args.size ~= callee.arity then
            error(RuntimeError.new(callee.name .. " expects " .. callee.arity .. " args", e.line))
        end
        return callee.fn(args)
    elseif ____mt_3 == Value.FunV then
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
            self:execBlock(callee.decl.body, ____local)
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
