package calc

// A small statement language: tokenizer, recursive-descent parser, sealed AST and a tree-walking evaluator.

open class LangException(message: String, val line: Int, cause: Throwable? = null) : Exception(message, cause) {
    override fun toString(): String = "${this::class.simpleName}(line $line): $message"
}

class SyntaxError(message: String, line: Int) : LangException(message, line)

class RuntimeError(message: String, line: Int, cause: Throwable? = null) : LangException(message, line, cause)

enum class TokenType { NUMBER, STRING, IDENT, KEYWORD, OP, LPAREN, RPAREN, LBRACE, RBRACE, COMMA, SEMI, EOF }

data class Token(val type: TokenType, val text: String, val line: Int) {
    override fun toString() = if (type == TokenType.EOF) "<eof>" else "$type '$text'"
}

class Lexer(private val src: String) {
    private var pos = 0
    private var line = 1

    companion object {
        val KEYWORDS = setOf("let", "fun", "if", "else", "while", "return", "print", "true", "false")
        private val TWO_CHAR_OPS = listOf("==", "!=", "<=", ">=", "&&", "||")
        private val SINGLE = mapOf(
            '(' to TokenType.LPAREN, ')' to TokenType.RPAREN, '{' to TokenType.LBRACE,
            '}' to TokenType.RBRACE, ',' to TokenType.COMMA, ';' to TokenType.SEMI,
        )
    }

    fun tokens(): List<Token> = buildList {
        while (true) {
            val t = next()
            add(t)
            if (t.type == TokenType.EOF) break
        }
    }

    private fun peekChar(offset: Int = 0): Char? = src.getOrNull(pos + offset)

    private fun next(): Token {
        skipBlanks()
        val c = peekChar() ?: return Token(TokenType.EOF, "", line)
        val start = pos
        return when {
            c.isDigit() -> {
                while (peekChar()?.let { it.isDigit() || it == '.' } == true) pos++
                Token(TokenType.NUMBER, src.substring(start, pos), line)
            }
            c.isLetter() || c == '_' -> {
                while (peekChar()?.let { it.isLetterOrDigit() || it == '_' } == true) pos++
                val word = src.substring(start, pos)
                Token(if (word in KEYWORDS) TokenType.KEYWORD else TokenType.IDENT, word, line)
            }
            c == '"' -> readString()
            else -> {
                val two = src.substring(pos, minOf(pos + 2, src.length))
                when {
                    two in TWO_CHAR_OPS -> { pos += 2; Token(TokenType.OP, two, line) }
                    c in SINGLE -> { pos++; Token(SINGLE.getValue(c), c.toString(), line) }
                    c in "+-*/%<>=!" -> { pos++; Token(TokenType.OP, c.toString(), line) }
                    else -> throw SyntaxError("unexpected character '$c'", line)
                }
            }
        }
    }

    private fun readString(): Token {
        pos++
        val sb = StringBuilder()
        while (true) {
            val ch = peekChar() ?: throw SyntaxError("unterminated string", line)
            pos++
            if (ch == '"') break
            if (ch == '\\') {
                when (val esc = peekChar()) {
                    'n' -> sb.append('\n')
                    't' -> sb.append('\t')
                    else -> sb.append(esc ?: throw SyntaxError("bad escape", line))
                }
                pos++
            } else {
                sb.append(ch)
            }
        }
        return Token(TokenType.STRING, sb.toString(), line)
    }

    private fun skipBlanks() {
        while (true) {
            val c = peekChar() ?: return
            when {
                c == '\n' -> { line++; pos++ }
                c.isWhitespace() -> pos++
                c == '#' -> while (peekChar() != null && peekChar() != '\n') pos++
                else -> return
            }
        }
    }
}

sealed interface Expr {
    val line: Int
    data class Num(val value: Double, override val line: Int) : Expr
    data class Str(val value: String, override val line: Int) : Expr
    data class Bool(val value: Boolean, override val line: Int) : Expr
    data class Var(val name: String, override val line: Int) : Expr
    data class Unary(val op: String, val operand: Expr, override val line: Int) : Expr
    data class Binary(val left: Expr, val op: String, val right: Expr, override val line: Int) : Expr
    data class Call(val callee: String, val args: List<Expr>, override val line: Int) : Expr
}

sealed class Stmt {
    data class Let(val name: String, val init: Expr) : Stmt()
    data class Assign(val name: String, val value: Expr) : Stmt()
    data class Print(val expr: Expr) : Stmt()
    data class If(val cond: Expr, val then: List<Stmt>, val otherwise: List<Stmt>?) : Stmt()
    data class While(val cond: Expr, val body: List<Stmt>) : Stmt()
    data class FunDecl(val name: String, val params: List<String>, val body: List<Stmt>) : Stmt()
    data class Return(val value: Expr?) : Stmt()
    data class ExprStmt(val expr: Expr) : Stmt()
}

class Parser(private val tokens: List<Token>) {
    private var i = 0
    private val peek get() = tokens[i]

    private fun advance(): Token = tokens[i].also { if (it.type != TokenType.EOF) i++ }

    private fun match(type: TokenType, text: String? = null): Boolean {
        val t = peek
        if (t.type != type || (text != null && t.text != text)) return false
        advance()
        return true
    }

    private fun expect(type: TokenType, text: String? = null): Token {
        val t = peek
        if (t.type != type || (text != null && t.text != text)) {
            throw SyntaxError("expected ${text ?: type.name.lowercase()} but found $t", t.line)
        }
        return advance()
    }

    fun program(): List<Stmt> = generateSequence { if (peek.type == TokenType.EOF) null else statement() }.toList()

    private fun block(): List<Stmt> {
        expect(TokenType.LBRACE)
        val body = mutableListOf<Stmt>()
        while (!match(TokenType.RBRACE)) body += statement()
        return body
    }

    private fun statement(): Stmt = when {
        match(TokenType.KEYWORD, "let") -> {
            val name = expect(TokenType.IDENT).text
            expect(TokenType.OP, "=")
            Stmt.Let(name, expression()).also { expect(TokenType.SEMI) }
        }
        match(TokenType.KEYWORD, "print") -> Stmt.Print(expression()).also { expect(TokenType.SEMI) }
        match(TokenType.KEYWORD, "if") -> {
            val cond = expression()
            val then = block()
            val otherwise = if (match(TokenType.KEYWORD, "else")) {
                if (peek.text == "if") listOf(statement()) else block()
            } else {
                null
            }
            Stmt.If(cond, then, otherwise)
        }
        match(TokenType.KEYWORD, "while") -> Stmt.While(expression(), block())
        match(TokenType.KEYWORD, "fun") -> {
            val name = expect(TokenType.IDENT).text
            expect(TokenType.LPAREN)
            val params = mutableListOf<String>()
            if (!match(TokenType.RPAREN)) {
                do params += expect(TokenType.IDENT).text while (match(TokenType.COMMA))
                expect(TokenType.RPAREN)
            }
            Stmt.FunDecl(name, params, block())
        }
        match(TokenType.KEYWORD, "return") -> {
            val value = if (peek.type == TokenType.SEMI) null else expression()
            expect(TokenType.SEMI)
            Stmt.Return(value)
        }
        peek.type == TokenType.IDENT && tokens[i + 1].text == "=" -> {
            val name = advance().text
            advance()
            Stmt.Assign(name, expression()).also { expect(TokenType.SEMI) }
        }
        else -> Stmt.ExprStmt(expression()).also { expect(TokenType.SEMI) }
    }

    private val levels = listOf(
        listOf("||"), listOf("&&"), listOf("==", "!="), listOf("<", "<=", ">", ">="),
        listOf("+", "-"), listOf("*", "/", "%"),
    )

    private fun expression(level: Int = 0): Expr {
        if (level == levels.size) return unary()
        var left = expression(level + 1)
        while (peek.type == TokenType.OP && peek.text in levels[level]) {
            val op = advance()
            left = Expr.Binary(left, op.text, expression(level + 1), op.line)
        }
        return left
    }

    private fun unary(): Expr {
        val t = peek
        if (t.type == TokenType.OP && (t.text == "-" || t.text == "!")) {
            advance()
            return Expr.Unary(t.text, unary(), t.line)
        }
        return primary()
    }

    private fun primary(): Expr {
        val t = advance()
        return when (t.type) {
            TokenType.NUMBER -> Expr.Num(t.text.toDoubleOrNull() ?: throw SyntaxError("bad number ${t.text}", t.line), t.line)
            TokenType.STRING -> Expr.Str(t.text, t.line)
            TokenType.KEYWORD -> when (t.text) {
                "true", "false" -> Expr.Bool(t.text.toBoolean(), t.line)
                else -> throw SyntaxError("unexpected keyword ${t.text}", t.line)
            }
            TokenType.IDENT -> if (match(TokenType.LPAREN)) {
                val args = mutableListOf<Expr>()
                if (!match(TokenType.RPAREN)) {
                    do args.add(expression()) while (match(TokenType.COMMA))
                    expect(TokenType.RPAREN)
                }
                Expr.Call(t.text, args, t.line)
            } else {
                Expr.Var(t.text, t.line)
            }
            TokenType.LPAREN -> expression().also { expect(TokenType.RPAREN) }
            else -> throw SyntaxError("unexpected $t", t.line)
        }
    }
}

// Values of the language.
sealed class Value {
    data class NumV(val n: Double) : Value() {
        override fun toString() = if (n == Math.floor(n) && !n.isInfinite()) n.toLong().toString() else n.toString()
    }
    data class StrV(val s: String) : Value() {
        override fun toString() = s
    }
    data class BoolV(val b: Boolean) : Value() {
        override fun toString() = b.toString()
    }
    object Nil : Value() {
        override fun toString() = "nil"
    }
    class FunV(val decl: Stmt.FunDecl, val closure: Env) : Value() {
        override fun toString() = "<fun ${decl.name}/${decl.params.size}>"
    }
    class Native(val name: String, val arity: Int, val fn: (List<Value>) -> Value) : Value() {
        override fun toString() = "<native $name>"
    }
}

class Env(private val parent: Env? = null) {
    private val vars = HashMap<String, Value>()

    fun define(name: String, value: Value) {
        vars[name] = value
    }

    fun lookup(name: String, line: Int): Value =
        vars[name] ?: parent?.lookup(name, line) ?: throw RuntimeError("undefined variable '$name'", line)

    fun assign(name: String, value: Value, line: Int) {
        when {
            name in vars -> vars[name] = value
            parent != null -> parent.assign(name, value, line)
            else -> throw RuntimeError("assignment to undeclared '$name'", line)
        }
    }

    val depth: Int get() = 1 + (parent?.depth ?: 0)
}

private class ReturnSignal(val value: Value) : RuntimeException(null, null, false, false)

class Interpreter(private val out: (String) -> Unit) {
    val globals = Env()
    private var callDepth = 0
    var steps = 0
        private set

    init {
        globals.define("len", Value.Native("len", 1) { (s) -> Value.NumV((s as? Value.StrV)?.s?.length?.toDouble() ?: -1.0) })
        globals.define("str", Value.Native("str", 1) { args -> Value.StrV(args[0].toString()) })
        globals.define("max", Value.Native("max", 2) { (a, b) -> if (num(a, 0) >= num(b, 0)) a else b })
    }

    fun run(program: List<Stmt>) = execBlock(program, globals)

    private fun execBlock(stmts: List<Stmt>, env: Env) = stmts.forEach { exec(it, env) }

    private fun exec(stmt: Stmt, env: Env) {
        steps++
        when (stmt) {
            is Stmt.Let -> env.define(stmt.name, eval(stmt.init, env))
            is Stmt.Assign -> env.assign(stmt.name, eval(stmt.value, env), stmt.value.line)
            is Stmt.Print -> out(eval(stmt.expr, env).toString())
            is Stmt.If -> if (truthy(eval(stmt.cond, env))) {
                execBlock(stmt.then, Env(env))
            } else {
                stmt.otherwise?.let { execBlock(it, Env(env)) }
            }
            is Stmt.While -> {
                var guard = 0
                while (truthy(eval(stmt.cond, env))) {
                    if (++guard > 10_000) throw RuntimeError("loop limit exceeded", stmt.cond.line)
                    execBlock(stmt.body, Env(env))
                }
            }
            is Stmt.FunDecl -> env.define(stmt.name, Value.FunV(stmt, env))
            is Stmt.Return -> throw ReturnSignal(stmt.value?.let { eval(it, env) } ?: Value.Nil)
            is Stmt.ExprStmt -> eval(stmt.expr, env)
        }
    }

    private fun truthy(v: Value) = when (v) {
        is Value.BoolV -> v.b
        Value.Nil -> false
        is Value.NumV -> v.n != 0.0
        else -> true
    }

    private fun num(v: Value, line: Int): Double =
        (v as? Value.NumV)?.n ?: throw RuntimeError("expected a number, got ${v::class.simpleName} $v", line)

    fun eval(e: Expr, env: Env): Value = when (e) {
        is Expr.Num -> Value.NumV(e.value)
        is Expr.Str -> Value.StrV(e.value)
        is Expr.Bool -> Value.BoolV(e.value)
        is Expr.Var -> env.lookup(e.name, e.line)
        is Expr.Unary -> when (e.op) {
            "-" -> Value.NumV(-num(eval(e.operand, env), e.line))
            else -> Value.BoolV(!truthy(eval(e.operand, env)))
        }
        is Expr.Binary -> binary(e, env)
        is Expr.Call -> call(e, env)
    }

    private fun binary(e: Expr.Binary, env: Env): Value {
        if (e.op == "&&") return eval(e.left, env).let { if (!truthy(it)) it else eval(e.right, env) }
        if (e.op == "||") return eval(e.left, env).let { if (truthy(it)) it else eval(e.right, env) }
        val l = eval(e.left, env)
        val r = eval(e.right, env)
        return when (e.op) {
            "+" -> if (l is Value.StrV || r is Value.StrV) Value.StrV("$l$r") else Value.NumV(num(l, e.line) + num(r, e.line))
            "-" -> Value.NumV(num(l, e.line) - num(r, e.line))
            "*" -> Value.NumV(num(l, e.line) * num(r, e.line))
            "/" -> {
                val d = num(r, e.line)
                if (d == 0.0) throw RuntimeError("division by zero", e.line)
                Value.NumV(num(l, e.line) / d)
            }
            "%" -> Value.NumV(num(l, e.line) % num(r, e.line))
            "==" -> Value.BoolV(l == r)
            "!=" -> Value.BoolV(l != r)
            "<" -> Value.BoolV(num(l, e.line) < num(r, e.line))
            "<=" -> Value.BoolV(num(l, e.line) <= num(r, e.line))
            ">" -> Value.BoolV(num(l, e.line) > num(r, e.line))
            ">=" -> Value.BoolV(num(l, e.line) >= num(r, e.line))
            else -> throw RuntimeError("unknown operator ${e.op}", e.line)
        }
    }

    private fun call(e: Expr.Call, env: Env): Value {
        val callee = env.lookup(e.callee, e.line)
        val args = e.args.map { eval(it, env) }
        return when (callee) {
            is Value.Native -> {
                if (args.size != callee.arity) throw RuntimeError("${callee.name} expects ${callee.arity} args", e.line)
                callee.fn(args)
            }
            is Value.FunV -> {
                val params = callee.decl.params
                if (args.size != params.size) {
                    throw RuntimeError("${callee.decl.name} expects ${params.size} args, got ${args.size}", e.line)
                }
                if (++callDepth > 120) throw RuntimeError("stack overflow in ${callee.decl.name}", e.line)
                val local = Env(callee.closure)
                params.zip(args).forEach { (p, a) -> local.define(p, a) }
                try {
                    execBlock(callee.decl.body, local)
                    Value.Nil
                } catch (r: ReturnSignal) {
                    r.value
                } finally {
                    callDepth--
                }
            }
            else -> throw RuntimeError("'${e.callee}' is not callable", e.line)
        }
    }
}

fun runSource(name: String, src: String) {
    println("== $name")
    val output = mutableListOf<String>()
    val interp = Interpreter { output += it }
    try {
        val program = Parser(Lexer(src).tokens()).program()
        interp.run(program)
    } catch (e: SyntaxError) {
        output += "syntax: $e"
    } catch (e: LangException) {
        output += "runtime: $e" + (e.cause?.let { " (caused by ${it.message})" } ?: "")
    } finally {
        output.forEachIndexed { i, s -> println("  ${i + 1}: $s") }
        println("  steps=${interp.steps}")
    }
}

fun main() {
    runSource(
        "fib",
        """
        fun fib(n) { if n < 2 { return n; } return fib(n - 1) + fib(n - 2); }
        let i = 0;
        while i < 10 { print "fib(" + str(i) + ") = " + fib(i); i = i + 1; }
        """.trimIndent(),
    )
    runSource(
        "closures",
        """
        fun counter() {
          let n = 0;
          fun inc() { n = n + 1; return n; }
          return inc;
        }
        let c = counter();
        c(); c();
        print "count: " + c();
        print max(3, 7) * 2 / 4;
        print len("hello") % 3;
        print !(1 < 2) || 3 >= 3 && "x" != "y";
        """.trimIndent(),
    )
    runSource("syntax", "let x = 1;\nlet y = (2 + ;\n")
    runSource("undefined", "print 1;\nprint nope + 1;")
    runSource("zero", "fun f(a) { return 10 / a; }\nprint f(2);\nprint f(0);")
    runSource("strings", "print \"tab\\there\" + \" \" + 2.5 * 2;\nprint \"oops")
    runSource("recursion", "fun r(n) { return r(n + 1); }\nr(0);")
    runSource("arity", "fun two(a, b) { return a; }\nprint two(1);")

    val tokens = Lexer("let total = a1 + 42 >= b;").tokens()
    println(tokens.joinToString(" | "))
    println(tokens.groupingBy { it.type }.eachCount().entries.sortedBy { it.key }.joinToString { "${it.key}=${it.value}" })
    val ast = Parser(Lexer("print -x * (y + 2);").tokens()).program().single()
    println(ast)
    val nested = Env(Env(Env()))
    println("depth=${nested.depth}")
    val wrapped = RuntimeError("wrapped", 9, IllegalStateException("inner"))
    println("${wrapped.message} <- ${wrapped.cause?.message} ${wrapped.cause is IllegalStateException}")
}
