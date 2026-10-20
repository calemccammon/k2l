// A small scripting language: a line/column-tracking lexer, a recursive-descent parser for statements and
// expressions, and a tree-walking evaluator with closures, recursion and runtime errors that carry positions.

enum class T { NUM, STR, ID, KW, PUNCT, EOF }

data class Pos(val line: Int, val col: Int) {
    override fun toString() = "$line:$col"
}

data class Tok(val type: T, val text: String, val pos: Pos)

open class ScriptError(msg: String, val pos: Pos) : Exception("$msg at $pos")
class LexError(msg: String, pos: Pos) : ScriptError(msg, pos)
class SyntaxError(msg: String, pos: Pos) : ScriptError(msg, pos)
class RuntimeErr(msg: String, pos: Pos) : ScriptError(msg, pos)

val keywords = setOf("let", "fn", "if", "else", "while", "return", "true", "false", "and", "or", "not", "nil")

class Lexer(private val src: String) {
    private var i = 0
    private var line = 1
    private var col = 1

    private fun peek(off: Int = 0): Char = if (i + off < src.length) src[i + off] else '\u0000'

    private fun advance(): Char {
        val c = src[i++]
        if (c == '\n') { line++; col = 1 } else col++
        return c
    }

    fun lex(): List<Tok> {
        val out = mutableListOf<Tok>()
        while (i < src.length) {
            val c = peek()
            val start = Pos(line, col)
            when {
                c == '#' -> while (i < src.length && peek() != '\n') advance()
                c.isWhitespace() -> advance()
                c.isDigit() -> {
                    val sb = StringBuilder()
                    while (peek().isDigit() || (peek() == '.' && peek(1).isDigit())) sb.append(advance())
                    out += Tok(T.NUM, sb.toString(), start)
                }
                c == '"' -> out += Tok(T.STR, string(start), start)
                c.isLetter() || c == '_' -> {
                    val sb = StringBuilder()
                    while (peek().isLetterOrDigit() || peek() == '_') sb.append(advance())
                    val w = sb.toString()
                    out += Tok(if (w in keywords) T.KW else T.ID, w, start)
                }
                else -> {
                    val two = "$c${peek(1)}"
                    if (two in setOf("==", "!=", "<=", ">=", "->")) {
                        advance(); advance()
                        out += Tok(T.PUNCT, two, start)
                    } else if (c in "+-*/%<>=(){},;") {
                        out += Tok(T.PUNCT, advance().toString(), start)
                    } else {
                        throw LexError("unexpected '$c'", start)
                    }
                }
            }
        }
        out += Tok(T.EOF, "<eof>", Pos(line, col))
        return out
    }

    private fun string(start: Pos): String {
        advance()
        val sb = StringBuilder()
        while (true) {
            if (i >= src.length || peek() == '\n') throw LexError("unterminated string", start)
            val c = advance()
            when {
                c == '"' -> return sb.toString()
                c == '\\' -> when (val e = advance()) {
                    'n' -> sb.append('\n')
                    't' -> sb.append('\t')
                    '"', '\\' -> sb.append(e)
                    else -> throw LexError("bad escape '\\$e'", Pos(line, col - 2))
                }
                else -> sb.append(c)
            }
        }
    }
}

sealed class Node(val pos: Pos)
class NumLit(val v: Double, p: Pos) : Node(p)
class StrLit(val v: String, p: Pos) : Node(p)
class BoolLit(val v: Boolean, p: Pos) : Node(p)
class NilLit(p: Pos) : Node(p)
class Name(val id: String, p: Pos) : Node(p)
class Bin(val op: String, val l: Node, val r: Node, p: Pos) : Node(p)
class Un(val op: String, val e: Node, p: Pos) : Node(p)
class CallN(val callee: Node, val args: List<Node>, p: Pos) : Node(p)
class FnLit(val params: List<String>, val body: List<Node>, p: Pos) : Node(p)
class LetS(val id: String, val e: Node, p: Pos) : Node(p)
class AssignS(val id: String, val e: Node, p: Pos) : Node(p)
class IfS(val c: Node, val t: List<Node>, val f: List<Node>?, p: Pos) : Node(p)
class WhileS(val c: Node, val body: List<Node>, p: Pos) : Node(p)
class ReturnS(val e: Node?, p: Pos) : Node(p)

class Parser(private val toks: List<Tok>) {
    private var k = 0
    private val cur get() = toks[k]

    private fun at(text: String) = (cur.type == T.PUNCT || cur.type == T.KW) && cur.text == text
    private fun eat(text: String): Tok {
        if (!at(text)) throw SyntaxError("expected '$text' but found '${cur.text}'", cur.pos)
        return toks[k++]
    }

    fun program(): List<Node> {
        val out = ArrayList<Node>()
        while (cur.type != T.EOF) out += statement()
        return out
    }

    private fun block(): List<Node> {
        eat("{")
        val out = ArrayList<Node>()
        while (!at("}")) {
            if (cur.type == T.EOF) throw SyntaxError("unclosed block", cur.pos)
            out += statement()
        }
        eat("}")
        return out
    }

    private fun statement(): Node {
        val p = cur.pos
        return when {
            at("let") -> { k++; val id = ident(); eat("="); LetS(id, expr(), p).also { eat(";") } }
            at("if") -> { k++; ifTail(p) }
            at("while") -> { k++; WhileS(expr(), block(), p) }
            at("return") -> { k++; val e = if (at(";")) null else expr(); eat(";"); ReturnS(e, p) }
            cur.type == T.ID && toks[k + 1].text == "=" -> { val id = ident(); k++; AssignS(id, expr(), p).also { eat(";") } }
            else -> expr().also { eat(";") }
        }
    }

    private fun ifTail(p: Pos): Node {
        val c = expr()
        val t = block()
        val f = if (at("else")) { k++; if (at("if")) { val q = cur.pos; k++; listOf(ifTail(q)) } else block() } else null
        return IfS(c, t, f, p)
    }

    private fun ident(): String {
        if (cur.type != T.ID) throw SyntaxError("expected identifier but found '${cur.text}'", cur.pos)
        return toks[k++].text
    }

    private val levels = listOf(
        listOf("or"), listOf("and"), listOf("==", "!="), listOf("<", "<=", ">", ">="), listOf("+", "-"), listOf("*", "/", "%"),
    )

    fun expr(level: Int = 0): Node {
        if (level == levels.size) return unary()
        var left = expr(level + 1)
        while (levels[level].any { at(it) }) {
            val op = toks[k++]
            left = Bin(op.text, left, expr(level + 1), op.pos)
        }
        return left
    }

    private fun unary(): Node {
        val p = cur.pos
        if (at("-") || at("not")) { val op = toks[k++].text; return Un(op, unary(), p) }
        var e = primary()
        while (at("(")) {
            val cp = cur.pos
            k++
            val args = ArrayList<Node>()
            if (!at(")")) do { args += expr() } while (at(",").also { if (it) k++ })
            eat(")")
            e = CallN(e, args, cp)
        }
        return e
    }

    private fun primary(): Node {
        val t = cur
        k++
        return when (t.type) {
            T.NUM -> NumLit(t.text.toDouble(), t.pos)
            T.STR -> StrLit(t.text, t.pos)
            T.ID -> Name(t.text, t.pos)
            T.KW -> when (t.text) {
                "true", "false" -> BoolLit(t.text == "true", t.pos)
                "nil" -> NilLit(t.pos)
                "fn" -> fnTail(t.pos)
                else -> throw SyntaxError("unexpected keyword '${t.text}'", t.pos)
            }
            T.PUNCT -> if (t.text == "(") expr().also { eat(")") } else throw SyntaxError("unexpected '${t.text}'", t.pos)
            T.EOF -> throw SyntaxError("unexpected end of input", t.pos)
        }
    }

    private fun fnTail(p: Pos): Node {
        eat("(")
        val ps = ArrayList<String>()
        if (!at(")")) do { ps += ident() } while (at(",").also { if (it) k++ })
        eat(")")
        if (!at("->")) return FnLit(ps, block(), p)
        k++
        val e = expr()
        return FnLit(ps, listOf(ReturnS(e, e.pos)), p)
    }
}

class Env(val parent: Env?) {
    private val vars = HashMap<String, Any?>()
    fun define(n: String, v: Any?) { vars[n] = v }
    fun lookup(n: String, p: Pos): Any? = when {
        vars.containsKey(n) -> vars[n]
        parent != null -> parent.lookup(n, p)
        else -> throw RuntimeErr("undefined variable '$n'", p)
    }
    fun assign(n: String, v: Any?, p: Pos) {
        when {
            vars.containsKey(n) -> vars[n] = v
            parent != null -> parent.assign(n, v, p)
            else -> throw RuntimeErr("assignment to undeclared '$n'", p)
        }
    }
}

class Closure(val fn: FnLit, val env: Env) {
    override fun toString() = "<fn/${fn.params.size}>"
}

class Native(val name: String, val arity: Int, val f: (List<Any?>) -> Any?)

class ReturnSignal(val value: Any?) : RuntimeException(null, null, false, false)

fun show(v: Any?): String = when (v) {
    null -> "nil"
    is Double -> if (v == Math.floor(v) && !v.isInfinite()) v.toLong().toString() else v.toString()
    is Native -> "<native ${v.name}>"
    else -> v.toString()
}

class Interp(val out: StringBuilder) {
    val globals = Env(null).apply {
        define("print", Native("print", -1) { args -> out.append(args.joinToString(" ") { show(it) }).append('\n'); null })
        define("len", Native("len", 1) { args -> (args[0] as? String)?.length?.toDouble() })
        define("str", Native("str", 1) { args -> show(args[0]) })
    }
    var steps = 0

    fun run(prog: List<Node>) = exec(prog, globals)

    fun exec(body: List<Node>, env: Env) {
        for (s in body) stmt(s, env)
    }

    private fun stmt(s: Node, env: Env) {
        if (++steps > 10_000) throw RuntimeErr("step limit exceeded", s.pos)
        when (s) {
            is LetS -> env.define(s.id, eval(s.e, env))
            is AssignS -> env.assign(s.id, eval(s.e, env), s.pos)
            is IfS -> if (truthy(eval(s.c, env))) exec(s.t, Env(env)) else s.f?.let { exec(it, Env(env)) }
            is WhileS -> while (truthy(eval(s.c, env))) exec(s.body, Env(env))
            is ReturnS -> throw ReturnSignal(s.e?.let { eval(it, env) })
            else -> eval(s, env)
        }
    }

    private fun truthy(v: Any?) = v != null && v != false

    fun eval(e: Node, env: Env): Any? = when (e) {
        is NumLit -> e.v
        is StrLit -> e.v
        is BoolLit -> e.v
        is NilLit -> null
        is Name -> env.lookup(e.id, e.pos)
        is FnLit -> Closure(e, env)
        is Un -> if (e.op == "not") !truthy(eval(e.e, env)) else -num(eval(e.e, env), e.pos)
        is Bin -> binary(e, env)
        is CallN -> call(eval(e.callee, env), e.args.map { eval(it, env) }, e.pos)
        else -> throw RuntimeErr("not an expression", e.pos)
    }

    private fun num(v: Any?, p: Pos): Double = v as? Double ?: throw RuntimeErr("expected number, got ${show(v)}", p)

    private fun binary(e: Bin, env: Env): Any? {
        if (e.op == "and") return eval(e.l, env).let { if (truthy(it)) eval(e.r, env) else it }
        if (e.op == "or") return eval(e.l, env).let { if (truthy(it)) it else eval(e.r, env) }
        val l = eval(e.l, env)
        val r = eval(e.r, env)
        return when (e.op) {
            "==" -> l == r
            "!=" -> l != r
            "+" -> if (l is String || r is String) show(l) + show(r) else num(l, e.pos) + num(r, e.pos)
            "-" -> num(l, e.pos) - num(r, e.pos)
            "*" -> num(l, e.pos) * num(r, e.pos)
            "/" -> num(r, e.pos).let { d -> if (d == 0.0) throw RuntimeErr("division by zero", e.pos) else num(l, e.pos) / d }
            "%" -> num(l, e.pos).mod(num(r, e.pos))
            "<" -> num(l, e.pos) < num(r, e.pos)
            "<=" -> num(l, e.pos) <= num(r, e.pos)
            ">" -> num(l, e.pos) > num(r, e.pos)
            else -> num(l, e.pos) >= num(r, e.pos)
        }
    }

    private fun call(f: Any?, args: List<Any?>, p: Pos): Any? = when (f) {
        is Native -> {
            if (f.arity >= 0 && f.arity != args.size) throw RuntimeErr("${f.name} expects ${f.arity} args, got ${args.size}", p)
            f.f(args)
        }
        is Closure -> {
            if (f.fn.params.size != args.size) throw RuntimeErr("arity mismatch: expected ${f.fn.params.size}, got ${args.size}", p)
            val local = Env(f.env)
            f.fn.params.zip(args).forEach { (n, v) -> local.define(n, v) }
            try {
                exec(f.fn.body, local)
                null
            } catch (r: ReturnSignal) {
                r.value
            }
        }
        else -> throw RuntimeErr("cannot call ${show(f)}", p)
    }
}

fun runScript(name: String, src: String) {
    val out = StringBuilder()
    val interp = Interp(out)
    try {
        interp.run(Parser(Lexer(src).lex()).program())
        print(out)
        println("[$name] ok, ${interp.steps} steps")
    } catch (e: ScriptError) {
        print(out)
        val lineText = src.lines()[e.pos.line - 1]
        println("[$name] ${e::class.simpleName}: ${e.message}")
        println("  | $lineText")
        println("  | ${" ".repeat(e.pos.col - 1)}^")
    }
}

fun main() {
    runScript(
        "fib",
        """
        # recursive and iterative fibonacci
        let fib = fn(n) { if n < 2 { return n; } return fib(n - 1) + fib(n - 2); };
        let i = 0;
        while i <= 10 { print("fib", i, "=", fib(i)); i = i + 3; }
        """.trimIndent(),
    )
    runScript(
        "closures",
        """
        let counter = fn() { let c = 0; return fn() { c = c + 1; return c; }; };
        let a = counter(); let b = counter();
        a(); a();
        print("a:", a(), "b:", b());
        let compose = fn(f, g) -> fn(x) -> f(g(x));
        let inc = fn(x) -> x + 1;
        let dbl = fn(x) -> x * 2;
        print(compose(inc, dbl)(5), compose(dbl, inc)(5));
        print("len:", len("héllo\tworld"), str(7 / 2), -7 % 3, not nil and "yes");
        print("mix " + 1 + true + nil);
        """.trimIndent(),
    )
    runScript(
        "fizz",
        """
        let n = 1;
        let s = "";
        while n <= 15 {
          if n % 15 == 0 { s = s + "FB "; } else if n % 3 == 0 { s = s + "F "; } else if n % 5 == 0 { s = s + "B "; } else { s = s + n + " "; }
          n = n + 1;
        }
        print(s);
        """.trimIndent(),
    )
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
}
