// A tokenizer and Pratt parser for an expression language with variables, functions, comparison and
// ternaries; errors carry positions and are shown with a caret under the source.

enum class Kind { NUM, IDENT, OP, LPAREN, RPAREN, COMMA, QUESTION, COLON, EOF }

data class Token(val kind: Kind, val text: String, val pos: Int) {
    override fun toString() = if (kind == Kind.EOF) "EOF@$pos" else "$kind('$text')@$pos"
}

class ParseError(message: String, val pos: Int) : RuntimeException(message)

fun tokenize(src: String): List<Token> {
    val out = ArrayList<Token>()
    var i = 0
    val twoCharOps = setOf("<=", ">=", "==", "!=", "&&", "||", "**")
    while (i < src.length) {
        val c = src[i]
        when {
            c.isWhitespace() -> i++
            c.isDigit() || (c == '.' && i + 1 < src.length && src[i + 1].isDigit()) -> {
                val start = i
                while (i < src.length && (src[i].isDigit() || src[i] == '.' || src[i] == '_')) i++
                if (i < src.length && (src[i] == 'e' || src[i] == 'E')) {
                    i++
                    if (i < src.length && (src[i] == '+' || src[i] == '-')) i++
                    while (i < src.length && src[i].isDigit()) i++
                }
                out += Token(Kind.NUM, src.substring(start, i).replace("_", ""), start)
            }
            c.isLetter() || c == '_' -> {
                val start = i
                while (i < src.length && (src[i].isLetterOrDigit() || src[i] == '_')) i++
                out += Token(Kind.IDENT, src.substring(start, i), start)
            }
            c == '(' -> out += Token(Kind.LPAREN, "(", i++)
            c == ')' -> out += Token(Kind.RPAREN, ")", i++)
            c == ',' -> out += Token(Kind.COMMA, ",", i++)
            c == '?' -> out += Token(Kind.QUESTION, "?", i++)
            c == ':' -> out += Token(Kind.COLON, ":", i++)
            i + 1 < src.length && src.substring(i, i + 2) in twoCharOps -> {
                out += Token(Kind.OP, src.substring(i, i + 2), i)
                i += 2
            }
            c in "+-*/%^<>!" -> out += Token(Kind.OP, c.toString(), i++)
            else -> throw ParseError("unexpected character '$c' (U+${c.code.toString(16).uppercase().padStart(4, '0')})", i)
        }
    }
    out += Token(Kind.EOF, "", src.length)
    return out
}

sealed interface Expr
data class Num(val v: Double) : Expr
data class Var(val name: String) : Expr
data class Unary(val op: String, val e: Expr) : Expr
data class Binary(val op: String, val l: Expr, val r: Expr) : Expr
data class Call(val fn: String, val args: List<Expr>) : Expr
data class Cond(val c: Expr, val t: Expr, val f: Expr) : Expr

class Pratt(private val tokens: List<Token>) {
    private var p = 0
    private fun peek() = tokens[p]
    private fun next() = tokens[p++]

    private fun infixPower(op: String): Pair<Int, Int>? = when (op) {
        "||" -> 1 to 2
        "&&" -> 3 to 4
        "==", "!=" -> 5 to 6
        "<", ">", "<=", ">=" -> 7 to 8
        "+", "-" -> 9 to 10
        "*", "/", "%" -> 11 to 12
        "**", "^" -> 16 to 15 // right associative
        else -> null
    }

    fun parseAll(): Expr {
        val e = expr(0)
        if (peek().kind != Kind.EOF) throw ParseError("unexpected ${peek().text.ifEmpty { peek().kind.name }}", peek().pos)
        return e
    }

    fun expr(minBp: Int): Expr {
        val t = next()
        var lhs: Expr = when (t.kind) {
            Kind.NUM -> Num(t.text.toDoubleOrNull() ?: throw ParseError("malformed number '${t.text}'", t.pos))
            Kind.IDENT -> if (peek().kind == Kind.LPAREN) call(t) else Var(t.text)
            Kind.LPAREN -> expr(0).also { expect(Kind.RPAREN, "')'") }
            Kind.OP -> if (t.text == "-" || t.text == "!" || t.text == "+") Unary(t.text, expr(13)) else
                throw ParseError("operator '${t.text}' needs a left operand", t.pos)
            Kind.EOF -> throw ParseError("unexpected end of input", t.pos)
            else -> throw ParseError("unexpected '${t.text}'", t.pos)
        }
        while (true) {
            val op = peek()
            if (op.kind == Kind.QUESTION) {
                if (minBp > 0) break
                next()
                val a = expr(0)
                expect(Kind.COLON, "':'")
                val b = expr(0)
                lhs = Cond(lhs, a, b)
                continue
            }
            if (op.kind != Kind.OP) break
            val (l, r) = infixPower(op.text) ?: throw ParseError("unknown operator '${op.text}'", op.pos)
            if (l < minBp) break
            next()
            lhs = Binary(op.text, lhs, expr(r))
        }
        return lhs
    }

    private fun call(name: Token): Expr {
        expect(Kind.LPAREN, "'('")
        val args = mutableListOf<Expr>()
        if (peek().kind != Kind.RPAREN) {
            do {
                args += expr(0)
            } while (peek().kind == Kind.COMMA && next().kind == Kind.COMMA)
        }
        expect(Kind.RPAREN, "')' after arguments of ${name.text}")
        return Call(name.text, args)
    }

    private fun expect(kind: Kind, what: String) {
        val t = next()
        if (t.kind != kind) throw ParseError("expected $what but got ${if (t.kind == Kind.EOF) "end of input" else "'${t.text}'"}", t.pos)
    }
}

fun show(e: Expr): String = when (e) {
    is Num -> if (e.v % 1.0 == 0.0) e.v.toLong().toString() else e.v.toString()
    is Var -> e.name
    is Unary -> "(${e.op}${show(e.e)})"
    is Binary -> "(${show(e.l)} ${e.op} ${show(e.r)})"
    is Call -> e.fn + e.args.joinToString(", ", "(", ")") { show(it) }
    is Cond -> "(${show(e.c)} ? ${show(e.t)} : ${show(e.f)})"
}

val functions: Map<String, (List<Double>) -> Double> = mapOf(
    "max" to { a -> a.maxOrNull() ?: Double.NaN },
    "min" to { a -> a.minOrNull() ?: Double.NaN },
    "sqrt" to { a -> Math.sqrt(a.single()) },
    "abs" to { a -> Math.abs(a.single()) },
    "hypot" to { a -> Math.hypot(a[0], a[1]) },
    "avg" to { a -> a.average() },
)

fun eval(e: Expr, env: Map<String, Double>): Double = when (e) {
    is Num -> e.v
    is Var -> env[e.name] ?: throw IllegalArgumentException("unknown variable '${e.name}'")
    is Unary -> when (e.op) {
        "-" -> -eval(e.e, env)
        "!" -> if (eval(e.e, env) == 0.0) 1.0 else 0.0
        else -> eval(e.e, env)
    }
    is Binary -> {
        val a = eval(e.l, env)
        when (e.op) {
            "&&" -> if (a != 0.0 && eval(e.r, env) != 0.0) 1.0 else 0.0
            "||" -> if (a != 0.0 || eval(e.r, env) != 0.0) 1.0 else 0.0
            else -> {
                val b = eval(e.r, env)
                when (e.op) {
                    "+" -> a + b
                    "-" -> a - b
                    "*" -> a * b
                    "/" -> a / b
                    "%" -> a % b
                    "**", "^" -> Math.pow(a, b)
                    "<" -> if (a < b) 1.0 else 0.0
                    ">" -> if (a > b) 1.0 else 0.0
                    "<=" -> if (a <= b) 1.0 else 0.0
                    ">=" -> if (a >= b) 1.0 else 0.0
                    "==" -> if (a == b) 1.0 else 0.0
                    else -> if (a != b) 1.0 else 0.0
                }
            }
        }
    }
    is Call -> (functions[e.fn] ?: throw IllegalArgumentException("unknown function ${e.fn}/${e.args.size}"))(e.args.map { eval(it, env) })
    is Cond -> if (eval(e.c, env) != 0.0) eval(e.t, env) else eval(e.f, env)
}

fun caret(src: String, pos: Int): String = src + "\n" + " ".repeat(pos) + "^"

fun main() {
    val env = mapOf("x" to 3.0, "y" to -4.5, "pi" to Math.PI, "n" to 10.0)
    println(tokenize("max(1, 2.5e3) ** -x"))
    val programs = listOf(
        "1 + 2 * 3",
        "(1 + 2) * 3",
        "2 ** 3 ** 2",
        "-x ** 2",
        "10 - 4 - 3",
        "1_000_000 / 8",
        "x > 2 && y < 0 ? hypot(x, y) : 0",
        "n % 3 == 1 || !(x == 3)",
        "max(x, y, n, 7) - min(1, 2)",
        "avg(1, 2, 3, 4) * sqrt(16)",
        "pi * x ^ 2",
        "1 / 0",
        "0 / 0 == 0 / 0",
        ".5 + 1.25e-1",
        "x ? y ? 1 : 2 : 3",
    )
    for (src in programs) {
        val ast = Pratt(tokenize(src)).parseAll()
        val v = eval(ast, env)
        println("%-36s => %-40s = %s".format(src, show(ast), if (v == Math.rint(v) && !v.isInfinite()) "%.0f".format(v) else "%.6f".format(v)))
    }

    val broken = listOf("1 +", "(1 + 2", "max(1, 2", "3 $ 4", "* 5", "1 2", "a ? b", "1.2.3", "sqrt(1, 2)", "foo(1)", "z + 1", "x é 2")
    for (src in broken) {
        try {
            val v = eval(Pratt(tokenize(src)).parseAll(), env)
            println("$src = $v")
        } catch (e: ParseError) {
            println("parse error: ${e.message} at ${e.pos}")
            println(caret(src, e.pos).prependIndent("  | "))
        } catch (e: IllegalArgumentException) {
            println("eval error: ${e.message}")
        } catch (e: NoSuchElementException) {
            println("eval error (${e::class.simpleName}): ${e.message}")
        }
    }
}
