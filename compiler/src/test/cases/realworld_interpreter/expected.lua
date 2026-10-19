local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Env
local LangException = __K2L_Class("calc.LangException", __K2L_Exception)
__K2L_ClassInfo(LangException, "calc.LangException", "calc.LangException", "class")

function LangException:____init(message, line, cause)
    if cause == nil then
        cause = nil
    end
    __K2L_Exception.____init(self, message, cause)
    self.line = line
end

function LangException:toString()
    return __K2L_Str(__K2L_KClassOfValue(self).simpleName) .. "(line " .. self.line .. "): " .. __K2L_Str(self.message)
end

local SyntaxError = __K2L_Class("calc.SyntaxError", LangException)
__K2L_ClassInfo(SyntaxError, "calc.SyntaxError", "calc.SyntaxError", "class")

function SyntaxError:____init(message, line)
    LangException.____init(self, message, line)
end

local RuntimeError = __K2L_Class("calc.RuntimeError", LangException)
__K2L_ClassInfo(RuntimeError, "calc.RuntimeError", "calc.RuntimeError", "class")

function RuntimeError:____init(message, line, cause)
    if cause == nil then
        cause = nil
    end
    LangException.____init(self, message, line, cause)
end

local TokenType = __K2L_Class("calc.TokenType")
__K2L_ClassInfo(TokenType, "calc.TokenType", "calc.TokenType", "class")

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
__K2L_ClassInfo(Token, "calc.Token", "calc.Token", "class")

function Token:____init(____type, text, line)
    self.type = ____type
    self.text = text
    self.line = line
end

function Token:toString()
    return self.type == TokenType.EOF and "<eof>" or __K2L_Str(self.type) .. " '" .. self.text .. "'"
end

function Token:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.type) + __K2L_Hash(self.text)) + __K2L_Hash(self.line))
end

function Token:equals(other)
    return getmetatable(other) == Token and self.type == other.type and self.text == other.text and self.line == other.line
end

local Lexer = __K2L_Class("calc.Lexer")
__K2L_ClassInfo(Lexer, "calc.Lexer", "calc.Lexer", "class")
__K2L_CompanionInfo(Lexer, "calc.Lexer.Companion", "calc.Lexer$Companion", "Companion")

function Lexer:____init(src)
    self.src = src
    self.pos = 0
    self.line = 1
end

function Lexer:tokens()
    local ____builder = __K2L_ListBuilderOf()
    while true do
        local t = self:next()
        ____builder:add(t)
        if t.type == TokenType.EOF then
            break
        end
    end
    return ____builder:____build()
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
    if c:match("^%d$") ~= nil then
        while true do
            local ____receiver_1 = self:peekChar()
            if (____receiver_1 and (____receiver_1:match("^%d$") ~= nil or ____receiver_1 == ".")) ~= true then
                break
            end
            self.pos = self.pos + 1
        end
        return Token.new(TokenType.NUMBER, __K2L_Text.substring(self.src, start, self.pos), self.line)
    elseif c:match("^%a$") ~= nil or c == "_" then
        while true do
            local ____receiver = self:peekChar()
            if (____receiver and (____receiver:match("^%w$") ~= nil or ____receiver == "_")) ~= true then
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
        elseif c:match("^%s$") ~= nil then
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
    self.KEYWORDS = __K2L_ReadOnlySetOf("let", "fun", "if", "else", "while", "return", "print", "true", "false")
    self.TWO_CHAR_OPS = __K2L_ReadOnlyListOf("==", "!=", "<=", ">=", "&&", "||")
    self.SINGLE = __K2L_ReadOnlyMapOf(__K2L_Pair.new("(", TokenType.LPAREN), __K2L_Pair.new(")", TokenType.RPAREN), __K2L_Pair.new("{", TokenType.LBRACE), __K2L_Pair.new("}", TokenType.RBRACE), __K2L_Pair.new(",", TokenType.COMMA), __K2L_Pair.new(";", TokenType.SEMI))
end

__K2L_LazyObject(Lexer, "____initCompanion")
local Expr = __K2L_Class("calc.Expr")
__K2L_ClassInfo(Expr, "calc.Expr", "calc.Expr", "interface")
Expr.Num = __K2L_Class("calc.Expr$Num", nil, Expr)
__K2L_ClassInfo(Expr.Num, "calc.Expr.Num", "calc.Expr$Num", "class")

function Expr.Num:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Num:toString()
    return "Num(value=" .. __K2L_Str(self.value) .. ", line=" .. self.line .. ")"
end

function Expr.Num:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.value) + __K2L_Hash(self.line))
end

function Expr.Num:equals(other)
    return getmetatable(other) == Expr.Num and self.value == other.value and self.line == other.line
end

Expr.Str = __K2L_Class("calc.Expr$Str", nil, Expr)
__K2L_ClassInfo(Expr.Str, "calc.Expr.Str", "calc.Expr$Str", "class")

function Expr.Str:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Str:toString()
    return "Str(value=" .. self.value .. ", line=" .. self.line .. ")"
end

function Expr.Str:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.value) + __K2L_Hash(self.line))
end

function Expr.Str:equals(other)
    return getmetatable(other) == Expr.Str and self.value == other.value and self.line == other.line
end

Expr.Bool = __K2L_Class("calc.Expr$Bool", nil, Expr)
__K2L_ClassInfo(Expr.Bool, "calc.Expr.Bool", "calc.Expr$Bool", "class")

function Expr.Bool:____init(value, line)
    self.value = value
    self.line = line
end

function Expr.Bool:toString()
    return "Bool(value=" .. tostring(self.value) .. ", line=" .. self.line .. ")"
end

function Expr.Bool:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.value) + __K2L_Hash(self.line))
end

function Expr.Bool:equals(other)
    return getmetatable(other) == Expr.Bool and self.value == other.value and self.line == other.line
end

Expr.Var = __K2L_Class("calc.Expr$Var", nil, Expr)
__K2L_ClassInfo(Expr.Var, "calc.Expr.Var", "calc.Expr$Var", "class")

function Expr.Var:____init(name, line)
    self.name = name
    self.line = line
end

function Expr.Var:toString()
    return "Var(name=" .. self.name .. ", line=" .. self.line .. ")"
end

function Expr.Var:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.line))
end

function Expr.Var:equals(other)
    return getmetatable(other) == Expr.Var and self.name == other.name and self.line == other.line
end

Expr.Unary = __K2L_Class("calc.Expr$Unary", nil, Expr)
__K2L_ClassInfo(Expr.Unary, "calc.Expr.Unary", "calc.Expr$Unary", "class")

function Expr.Unary:____init(op, operand, line)
    self.op = op
    self.operand = operand
    self.line = line
end

function Expr.Unary:toString()
    return "Unary(op=" .. self.op .. ", operand=" .. __K2L_Str(self.operand) .. ", line=" .. self.line .. ")"
end

function Expr.Unary:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.op) + __K2L_Hash(self.operand)) + __K2L_Hash(self.line))
end

function Expr.Unary:equals(other)
    return getmetatable(other) == Expr.Unary and self.op == other.op and __K2L_Equals(self.operand, other.operand) and self.line == other.line
end

Expr.Binary = __K2L_Class("calc.Expr$Binary", nil, Expr)
__K2L_ClassInfo(Expr.Binary, "calc.Expr.Binary", "calc.Expr$Binary", "class")

function Expr.Binary:____init(left, op, right, line)
    self.left = left
    self.op = op
    self.right = right
    self.line = line
end

function Expr.Binary:toString()
    return "Binary(left=" .. __K2L_Str(self.left) .. ", op=" .. self.op .. ", right=" .. __K2L_Str(self.right) .. ", line=" .. self.line .. ")"
end

function Expr.Binary:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.left) + __K2L_Hash(self.op)) + __K2L_Hash(self.right)) + __K2L_Hash(self.line))
end

function Expr.Binary:equals(other)
    return getmetatable(other) == Expr.Binary and __K2L_Equals(self.left, other.left) and self.op == other.op and __K2L_Equals(self.right, other.right) and self.line == other.line
end

Expr.Call = __K2L_Class("calc.Expr$Call", nil, Expr)
__K2L_ClassInfo(Expr.Call, "calc.Expr.Call", "calc.Expr$Call", "class")

function Expr.Call:____init(callee, args, line)
    self.callee = callee
    self.args = args
    self.line = line
end

function Expr.Call:toString()
    return "Call(callee=" .. self.callee .. ", args=" .. __K2L_Str(self.args) .. ", line=" .. self.line .. ")"
end

function Expr.Call:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.callee) + __K2L_Hash(self.args)) + __K2L_Hash(self.line))
end

function Expr.Call:equals(other)
    return getmetatable(other) == Expr.Call and self.callee == other.callee and __K2L_Equals(self.args, other.args) and self.line == other.line
end

local Stmt = __K2L_Class("calc.Stmt")
__K2L_ClassInfo(Stmt, "calc.Stmt", "calc.Stmt", "class")
Stmt.Let = __K2L_Class("calc.Stmt$Let", Stmt)
__K2L_ClassInfo(Stmt.Let, "calc.Stmt.Let", "calc.Stmt$Let", "class")

function Stmt.Let:____init(name, init)
    self.name = name
    self.init = init
end

function Stmt.Let:toString()
    return "Let(name=" .. self.name .. ", init=" .. __K2L_Str(self.init) .. ")"
end

function Stmt.Let:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.init))
end

function Stmt.Let:equals(other)
    return getmetatable(other) == Stmt.Let and self.name == other.name and __K2L_Equals(self.init, other.init)
end

Stmt.Assign = __K2L_Class("calc.Stmt$Assign", Stmt)
__K2L_ClassInfo(Stmt.Assign, "calc.Stmt.Assign", "calc.Stmt$Assign", "class")

function Stmt.Assign:____init(name, value)
    self.name = name
    self.value = value
end

function Stmt.Assign:toString()
    return "Assign(name=" .. self.name .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function Stmt.Assign:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.value))
end

function Stmt.Assign:equals(other)
    return getmetatable(other) == Stmt.Assign and self.name == other.name and __K2L_Equals(self.value, other.value)
end

Stmt.Print = __K2L_Class("calc.Stmt$Print", Stmt)
__K2L_ClassInfo(Stmt.Print, "calc.Stmt.Print", "calc.Stmt$Print", "class")

function Stmt.Print:____init(expr)
    self.expr = expr
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
__K2L_ClassInfo(Stmt.If, "calc.Stmt.If", "calc.Stmt$If", "class")

function Stmt.If:____init(cond, ____then, otherwise)
    self.cond = cond
    self["then"] = ____then
    self.otherwise = otherwise
end

function Stmt.If:toString()
    return "If(cond=" .. __K2L_Str(self.cond) .. ", then=" .. __K2L_Str(self["then"]) .. ", otherwise=" .. __K2L_Str(self.otherwise) .. ")"
end

function Stmt.If:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.cond) + __K2L_Hash(self["then"])) + __K2L_Hash(self.otherwise))
end

function Stmt.If:equals(other)
    return getmetatable(other) == Stmt.If and __K2L_Equals(self.cond, other.cond) and __K2L_Equals(self["then"], other["then"]) and __K2L_Equals(self.otherwise, other.otherwise)
end

Stmt.While = __K2L_Class("calc.Stmt$While", Stmt)
__K2L_ClassInfo(Stmt.While, "calc.Stmt.While", "calc.Stmt$While", "class")

function Stmt.While:____init(cond, body)
    self.cond = cond
    self.body = body
end

function Stmt.While:toString()
    return "While(cond=" .. __K2L_Str(self.cond) .. ", body=" .. __K2L_Str(self.body) .. ")"
end

function Stmt.While:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.cond) + __K2L_Hash(self.body))
end

function Stmt.While:equals(other)
    return getmetatable(other) == Stmt.While and __K2L_Equals(self.cond, other.cond) and __K2L_Equals(self.body, other.body)
end

Stmt.FunDecl = __K2L_Class("calc.Stmt$FunDecl", Stmt)
__K2L_ClassInfo(Stmt.FunDecl, "calc.Stmt.FunDecl", "calc.Stmt$FunDecl", "class")

function Stmt.FunDecl:____init(name, params, body)
    self.name = name
    self.params = params
    self.body = body
end

function Stmt.FunDecl:toString()
    return "FunDecl(name=" .. self.name .. ", params=" .. __K2L_Str(self.params) .. ", body=" .. __K2L_Str(self.body) .. ")"
end

function Stmt.FunDecl:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.params)) + __K2L_Hash(self.body))
end

function Stmt.FunDecl:equals(other)
    return getmetatable(other) == Stmt.FunDecl and self.name == other.name and __K2L_Equals(self.params, other.params) and __K2L_Equals(self.body, other.body)
end

Stmt.Return = __K2L_Class("calc.Stmt$Return", Stmt)
__K2L_ClassInfo(Stmt.Return, "calc.Stmt.Return", "calc.Stmt$Return", "class")

function Stmt.Return:____init(value)
    self.value = value
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
__K2L_ClassInfo(Stmt.ExprStmt, "calc.Stmt.ExprStmt", "calc.Stmt$ExprStmt", "class")

function Stmt.ExprStmt:____init(expr)
    self.expr = expr
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
__K2L_ClassInfo(Parser, "calc.Parser", "calc.Parser", "class")

function Parser:____init(tokens)
    self.tokens = tokens
    self.i = 0
    self.levels = __K2L_ReadOnlyListOf(__K2L_SingletonListOf("||"), __K2L_SingletonListOf("&&"), __K2L_ReadOnlyListOf("==", "!="), __K2L_ReadOnlyListOf("<", "<=", ">", ">="), __K2L_ReadOnlyListOf("+", "-"), __K2L_ReadOnlyListOf("*", "/", "%"))
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
            otherwise = self:getPeek().text == "if" and __K2L_SingletonListOf(self:statement()) or self:block()
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
__K2L_ClassInfo(Value, "calc.Value", "calc.Value", "class")
Value.NumV = __K2L_Class("calc.Value$NumV", Value)
__K2L_ClassInfo(Value.NumV, "calc.Value.NumV", "calc.Value$NumV", "class")

function Value.NumV:____init(n)
    self.n = n
end

function Value.NumV:toString()
    return self.n == math.floor(self.n) + 0.0 and not __K2L_Num.isInfinite(self.n) and tostring(__K2L_DoubleToLong(self.n)) or __K2L_Str(self.n)
end

function Value.NumV:hashCode()
    return __K2L_Hash(self.n)
end

function Value.NumV:equals(other)
    return getmetatable(other) == Value.NumV and self.n == other.n
end

Value.StrV = __K2L_Class("calc.Value$StrV", Value)
__K2L_ClassInfo(Value.StrV, "calc.Value.StrV", "calc.Value$StrV", "class")

function Value.StrV:____init(s)
    self.s = s
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
__K2L_ClassInfo(Value.BoolV, "calc.Value.BoolV", "calc.Value$BoolV", "class")

function Value.BoolV:____init(b)
    self.b = b
end

function Value.BoolV:toString()
    return tostring(self.b)
end

function Value.BoolV:hashCode()
    return __K2L_Hash(self.b)
end

function Value.BoolV:equals(other)
    return getmetatable(other) == Value.BoolV and self.b == other.b
end

Value.Nil = __K2L_Class("calc.Value$Nil", Value)
__K2L_ClassInfo(Value.Nil, "calc.Value.Nil", "calc.Value$Nil", "class")

function Value.Nil:toString()
    return "nil"
end

Value.FunV = __K2L_Class("calc.Value$FunV", Value)
__K2L_ClassInfo(Value.FunV, "calc.Value.FunV", "calc.Value$FunV", "class")

function Value.FunV:____init(decl, closure)
    self.decl = decl
    self.closure = closure
end

function Value.FunV:toString()
    return "<fun " .. self.decl.name .. "/" .. self.decl.params.size .. ">"
end

Value.Native = __K2L_Class("calc.Value$Native", Value)
__K2L_ClassInfo(Value.Native, "calc.Value.Native", "calc.Value$Native", "class")

function Value.Native:____init(name, arity, fn)
    self.name = name
    self.arity = arity
    self.fn = fn
end

function Value.Native:toString()
    return "<native " .. self.name .. ">"
end

Env = __K2L_Class("calc.Env")
__K2L_ClassInfo(Env, "calc.Env", "calc.Env", "class")

function Env:____init(parent)
    if parent == nil then
        parent = nil
    end
    self.parent = parent
    self.vars = __K2L_HashMap.new()
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
__K2L_ClassInfo(ReturnSignal, "calc.ReturnSignal", "calc.ReturnSignal", "class")

function ReturnSignal:____init(value)
    __K2L_RuntimeException.____init(self)
    self.value = value
end

local Interpreter = __K2L_Class("calc.Interpreter")
__K2L_ClassInfo(Interpreter, "calc.Interpreter", "calc.Interpreter", "class")

function Interpreter:____init(out)
    self.out = out
    self.globals = Env.new()
    self.callDepth = 0
    self.steps = 0
    self.globals:define("len", Value.Native.new("len", 1, function(____destructured)
        local s = ____destructured[1]
        local ____receiver_4 = __K2L_InstanceOf(s, Value.StrV) and s or nil
        local ____receiver_5 = ____receiver_4 and (__K2L_InstanceOf(s, Value.StrV) and s or nil).s
        local ____receiver_6 = ____receiver_5 and #____receiver_5
        return Value.NumV.new(____receiver_6 and ____receiver_6 + 0.0 or -1.0)
    end))
    self.globals:define("str", Value.Native.new("str", 1, function(args)
        return Value.StrV.new(__K2L_Str(args:get(0)))
    end))
    self.globals:define("max", Value.Native.new("max", 2, function(____destructured_1)
        local a, b = ____destructured_1[1], ____destructured_1[2]
        return self:num(a, 0) >= self:num(b, 0) and a or b
    end))
end

function Interpreter:run(program)
    self:execBlock(program, self.globals)
end

function Interpreter:execBlock(stmts, env)
    local ____mod = stmts.____modCount
    for ____i = 1, stmts.size do
        local it = stmts[____i]
        self:exec(it, env)
        if stmts.____modCount ~= ____mod and stmts:____comodified(____i) then
            break
        end
    end
end

function Interpreter:exec(stmt, env)
    self.steps = self.steps + 1
    if __K2L_InstanceOf(stmt, Stmt.Let) then
        env:define(stmt.name, self:eval(stmt.init, env))
    elseif __K2L_InstanceOf(stmt, Stmt.Assign) then
        env:assign(stmt.name, self:eval(stmt.value, env), stmt.value.line)
    elseif __K2L_InstanceOf(stmt, Stmt.Print) then
        self.out(__K2L_Str(self:eval(stmt.expr, env)))
    elseif __K2L_InstanceOf(stmt, Stmt.If) then
        if self:truthy(self:eval(stmt.cond, env)) then
            self:execBlock(stmt["then"], Env.new(env))
        else
            local ____receiver_8 = stmt.otherwise
            if ____receiver_8 ~= nil then
                self:execBlock(____receiver_8, Env.new(env))
            end
        end
    elseif __K2L_InstanceOf(stmt, Stmt.While) then
        local guard = 0
        while self:truthy(self:eval(stmt.cond, env)) do
            guard = guard + 1
            if guard > 10000 then
                error(RuntimeError.new("loop limit exceeded", stmt.cond.line))
            end
            self:execBlock(stmt.body, Env.new(env))
        end
    elseif __K2L_InstanceOf(stmt, Stmt.FunDecl) then
        env:define(stmt.name, Value.FunV.new(stmt, env))
    elseif __K2L_InstanceOf(stmt, Stmt.Return) then
        local ____receiver_7 = stmt.value
        error(ReturnSignal.new(____receiver_7 and self:eval(____receiver_7, env) or Value.Nil))
    elseif __K2L_InstanceOf(stmt, Stmt.ExprStmt) then
        self:eval(stmt.expr, env)
    end
end

function Interpreter:truthy(v)
    if __K2L_InstanceOf(v, Value.BoolV) then
        return v.b
    elseif __K2L_Equals(v, Value.Nil) then
        return false
    elseif __K2L_InstanceOf(v, Value.NumV) then
        return v.n ~= 0.0
    else
        return true
    end
end

function Interpreter:num(v, line)
    local ____receiver_9 = __K2L_InstanceOf(v, Value.NumV) and v or nil
    local ____value_12 = ____receiver_9 and (__K2L_InstanceOf(v, Value.NumV) and v or nil).n
    if ____value_12 == nil then
        error(RuntimeError.new("expected a number, got " .. __K2L_Str(__K2L_KClassOfValue(v).simpleName) .. " " .. __K2L_Str(v), line))
    end
    return ____value_12
end

function Interpreter:eval(e, env)
    if __K2L_InstanceOf(e, Expr.Num) then
        return Value.NumV.new(e.value)
    elseif __K2L_InstanceOf(e, Expr.Str) then
        return Value.StrV.new(e.value)
    elseif __K2L_InstanceOf(e, Expr.Bool) then
        return Value.BoolV.new(e.value)
    elseif __K2L_InstanceOf(e, Expr.Var) then
        return env:lookup(e.name, e.line)
    elseif __K2L_InstanceOf(e, Expr.Unary) then
        local ____subject_2 = e.op
        if ____subject_2 == "-" then
            return Value.NumV.new(-self:num(self:eval(e.operand, env), e.line))
        else
            return Value.BoolV.new(not self:truthy(self:eval(e.operand, env)))
        end
    elseif __K2L_InstanceOf(e, Expr.Binary) then
        return self:binary(e, env)
    elseif __K2L_InstanceOf(e, Expr.Call) then
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
        return (__K2L_InstanceOf(l, Value.StrV) or __K2L_InstanceOf(r, Value.StrV)) and Value.StrV.new(__K2L_Str(l) .. __K2L_Str(r)) or Value.NumV.new(self:num(l, e.line) + self:num(r, e.line))
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
        return Value.NumV.new(math.fmod(self:num(l, e.line), self:num(r, e.line)))
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
    local args = e.args:map(function(it) return self:eval(it, env) end)
    if __K2L_InstanceOf(callee, Value.Native) then
        if args.size ~= callee.arity then
            error(RuntimeError.new(callee.name .. " expects " .. callee.arity .. " args", e.line))
        end
        return callee.fn(args)
    elseif __K2L_InstanceOf(callee, Value.FunV) then
        local params = callee.decl.params
        if args.size ~= params.size then
            error(RuntimeError.new(callee.decl.name .. " expects " .. params.size .. " args, got " .. args.size, e.line))
        end
        self.callDepth = self.callDepth + 1
        if self.callDepth > 120 then
            error(RuntimeError.new("stack overflow in " .. callee.decl.name, e.line))
        end
        local ____local = Env.new(callee.closure)
        local ____list = params:zip(args)
        local ____mod_1 = ____list.____modCount
        for ____i_1 = 1, ____list.size do
            local ____it_1 = ____list[____i_1]
            do
                local p, a = ____it_1.first, ____it_1.second
                ____local:define(p, a)
            end
            if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
                break
            end
        end
        local ____ok, ____result_2, ____returned = pcall(function()
            self:execBlock(callee.decl.body, ____local)
            return true, Value.Nil
        end)
        if not ____ok then
            ____ok, ____result_2, ____returned = pcall(function()
                local ____error = __K2L_ToThrowable(____result_2)
                if __K2L_InstanceOf(____error, ReturnSignal) then
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
            if __K2L_InstanceOf(____error_1, SyntaxError) then
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
    for ____i_2 = 1, output.size do
        local s = output[____i_2]
        local i = ____i_2 - 1
        print("  " .. i + 1 .. ": " .. s)
    end
    print("  steps=" .. interp.steps)
    if not ____ok_1 then
        error(____result_3, 0)
    end
end

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
    print(tokens:groupingBy(function(it) return it.type end):eachCount():getEntries():sortedBy(function(it) return it.key end, true):joinToString(nil, nil, nil, nil, nil, function(it) return __K2L_Str(it.key) .. "=" .. it.value end))
    local ast = Parser.new(Lexer.new("print -x * (y + 2);"):tokens()):program():single()
    print(__K2L_Str(ast))
    local nested = Env.new(Env.new(Env.new()))
    print("depth=" .. nested:getDepth())
    local wrapped = RuntimeError.new("wrapped", 9, __K2L_IllegalStateException.new("inner"))
    local ____receiver_11 = wrapped.cause
    local ____value_15 = wrapped.cause
    print(__K2L_Str(wrapped.message) .. " <- " .. __K2L_Str(____receiver_11 and ____receiver_11.message) .. " " .. tostring(__K2L_InstanceOf(____value_15, __K2L_IllegalStateException)))
end

main()
return {LangException = LangException, SyntaxError = SyntaxError, RuntimeError = RuntimeError, TokenType = TokenType, Token = Token, Lexer = Lexer, Expr = Expr, Stmt = Stmt, Parser = Parser, Value = Value, Env = Env, Interpreter = Interpreter, runSource = runSource}
