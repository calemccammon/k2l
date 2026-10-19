package parsing

// A parser-combinator library and two grammars built with it: arithmetic with variables, and a JSON subset.

data class Input(val text: String, val pos: Int = 0) {
    val atEnd get() = pos >= text.length
    fun peek(): Char? = text.getOrNull(pos)
    fun advance(n: Int = 1) = Input(text, pos + n)
    override fun toString() = if (atEnd) "<end>" else "'${text.substring(pos).take(8)}'@$pos"
}

sealed class ParseResult<out T> {
    data class Success<out T>(val value: T, val rest: Input) : ParseResult<T>()
    data class Failure(val expected: String, val at: Input) : ParseResult<Nothing>()

    inline fun <R> fold(onSuccess: (T, Input) -> R, onFailure: (String, Input) -> R): R = when (this) {
        is Success -> onSuccess(value, rest)
        is Failure -> onFailure(expected, at)
    }
}

fun interface Parser<out T> {
    fun parse(input: Input): ParseResult<T>

    companion object {
        fun <T> pure(value: T): Parser<T> = Parser { ParseResult.Success(value, it) }
        fun fail(expected: String): Parser<Nothing> = Parser { ParseResult.Failure(expected, it) }
    }
}

fun <T, R> Parser<T>.map(f: (T) -> R): Parser<R> = Parser { input ->
    when (val r = parse(input)) {
        is ParseResult.Success -> ParseResult.Success(f(r.value), r.rest)
        is ParseResult.Failure -> r
    }
}

fun <T, R> Parser<T>.flatMap(f: (T) -> Parser<R>): Parser<R> = Parser { input ->
    when (val r = parse(input)) {
        is ParseResult.Success -> f(r.value).parse(r.rest)
        is ParseResult.Failure -> r
    }
}

/** Ordered choice; the failure that got furthest wins, which gives better messages. */
infix fun <T> Parser<T>.or(other: Parser<T>): Parser<T> = Parser { input ->
    when (val a = parse(input)) {
        is ParseResult.Success -> a
        is ParseResult.Failure -> when (val b = other.parse(input)) {
            is ParseResult.Success -> b
            is ParseResult.Failure -> if (a.at.pos >= b.at.pos) a else b
        }
    }
}

infix fun <A, B> Parser<A>.then(next: Parser<B>): Parser<Pair<A, B>> = flatMap { a -> next.map { b -> a to b } }
infix fun <A, B> Parser<A>.skipThen(next: Parser<B>): Parser<B> = flatMap { next }
infix fun <A, B> Parser<A>.thenSkip(next: Parser<B>): Parser<A> = flatMap { a -> next.map { a } }

fun <T> Parser<T>.many(): Parser<List<T>> = Parser { input ->
    val items = mutableListOf<T>()
    var current = input
    while (true) {
        val r = parse(current)
        if (r !is ParseResult.Success || r.rest.pos == current.pos) break
        items += r.value
        current = r.rest
    }
    ParseResult.Success(items, current)
}

fun <T> Parser<T>.many1(): Parser<List<T>> = (this then many()).map { (h, t) -> listOf(h) + t }
fun <T> Parser<T>.optional(): Parser<T?> = map<T, T?> { it } or Parser.pure(null)
fun <T, S> Parser<T>.sepBy(sep: Parser<S>): Parser<List<T>> =
    (this then (sep skipThen this).many()).map { (h, t) -> listOf(h) + t } or Parser.pure(emptyList())

fun <T> Parser<T>.named(name: String): Parser<T> = Parser { input ->
    when (val r = parse(input)) {
        is ParseResult.Success -> r
        is ParseResult.Failure -> ParseResult.Failure(if (r.at.pos == input.pos) name else r.expected, r.at)
    }
}

/** Deferred, for recursive grammars. */
fun <T> lazyParser(block: () -> Parser<T>): Parser<T> {
    val p by lazy(block)
    return Parser { p.parse(it) }
}

fun satisfy(what: String, test: (Char) -> Boolean): Parser<Char> = Parser { input ->
    val c = input.peek()
    if (c != null && test(c)) ParseResult.Success(c, input.advance()) else ParseResult.Failure(what, input)
}

fun char(c: Char) = satisfy("'$c'") { it == c }
val ws: Parser<Unit> = satisfy("space") { it.isWhitespace() }.many().map { }
fun <T> token(p: Parser<T>): Parser<T> = p thenSkip ws
fun symbol(s: String): Parser<String> = token(
    Parser { input ->
        if (input.text.startsWith(s, input.pos)) ParseResult.Success(s, input.advance(s.length)) else ParseResult.Failure("\"$s\"", input)
    },
)

val digit = satisfy("digit") { it.isDigit() }
val number: Parser<Double> = token(
    (digit.many1() then (char('.') skipThen digit.many1()).optional()).map { (whole, frac) ->
        (whole.joinToString("") + (frac?.let { "." + it.joinToString("") } ?: "")).toDouble()
    },
).named("number")
val identifier: Parser<String> = token(
    (satisfy("letter") { it.isLetter() } then satisfy("letter or digit") { it.isLetterOrDigit() || it == '_' }.many())
        .map { (h, t) -> h + t.joinToString("") },
).named("identifier")

// ---- arithmetic ----

sealed interface Expr {
    data class Num(val v: Double) : Expr
    data class Var(val name: String) : Expr
    data class Bin(val op: Char, val l: Expr, val r: Expr) : Expr
    data class Neg(val e: Expr) : Expr
    data class Call(val fn: String, val args: List<Expr>) : Expr
}

fun chainLeft(operand: Parser<Expr>, ops: String): Parser<Expr> =
    (operand then (token(satisfy("operator") { it in ops }) then operand).many()).map { (first, rest) ->
        rest.fold(first) { acc, (op, r) -> Expr.Bin(op, acc, r) }
    }

val expr: Parser<Expr> = lazyParser { chainLeft(term, "+-") }
val term: Parser<Expr> = lazyParser { chainLeft(factor, "*/%") }
val factor: Parser<Expr> = lazyParser {
    val call = (identifier then (symbol("(") skipThen expr.sepBy(symbol(",")) thenSkip symbol(")")).optional()).map { (name, args) ->
        if (args == null) Expr.Var(name) else Expr.Call(name, args)
    }
    number.map<Double, Expr> { Expr.Num(it) } or call or (symbol("-") skipThen factor).map { Expr.Neg(it) } or
        (symbol("(") skipThen expr thenSkip symbol(")"))
}

class EvalException(message: String) : Exception(message)

fun eval(e: Expr, env: Map<String, Double>): Double = when (e) {
    is Expr.Num -> e.v
    is Expr.Var -> env[e.name] ?: throw EvalException("unknown variable ${e.name}")
    is Expr.Neg -> -eval(e.e, env)
    is Expr.Bin -> {
        val (l, r) = eval(e.l, env) to eval(e.r, env)
        when (e.op) {
            '+' -> l + r
            '-' -> l - r
            '*' -> l * r
            '/' -> if (r == 0.0) throw EvalException("division by zero") else l / r
            else -> l % r
        }
    }
    is Expr.Call -> {
        val args = e.args.map { eval(it, env) }
        when (e.fn) {
            "max" -> args.maxOrNull() ?: throw EvalException("max of nothing")
            "min" -> args.min()
            "sum" -> args.sum()
            else -> throw EvalException("unknown function ${e.fn}/${args.size}")
        }
    }
}

fun show(e: Expr): String = when (e) {
    is Expr.Num -> if (e.v % 1.0 == 0.0) e.v.toLong().toString() else e.v.toString()
    is Expr.Var -> e.name
    is Expr.Neg -> "-${show(e.e)}"
    is Expr.Bin -> "(${show(e.l)} ${e.op} ${show(e.r)})"
    is Expr.Call -> "${e.fn}(${e.args.joinToString(", ", transform = ::show)})"
}

fun <T> Parser<T>.parseAll(text: String): ParseResult<T> = (ws skipThen this).flatMap { v ->
    Parser { input -> if (input.atEnd) ParseResult.Success(v, input) else ParseResult.Failure("end of input", input) }
}.parse(Input(text))

// ---- JSON subset ----

sealed class Json {
    data class Str(val s: String) : Json()
    data class Num(val n: Double) : Json()
    data class Arr(val items: List<Json>) : Json()
    data class Obj(val fields: Map<String, Json>) : Json()
    object Null : Json()

    fun render(): String = when (this) {
        is Str -> "\"$s\""
        is Num -> if (n % 1.0 == 0.0) n.toLong().toString() else n.toString()
        is Arr -> items.joinToString(",", "[", "]") { it.render() }
        is Obj -> fields.entries.joinToString(",", "{", "}") { (k, v) -> "\"$k\":${v.render()}" }
        Null -> "null"
    }
}

val jsonString: Parser<String> = token(char('"') skipThen satisfy("character") { it != '"' }.many() thenSkip char('"'))
    .map { it.joinToString("") }.named("string")
val json: Parser<Json> = lazyParser {
    val arr = symbol("[") skipThen json.sepBy(symbol(",")) thenSkip symbol("]")
    val field = jsonString thenSkip symbol(":") then json
    val obj = symbol("{") skipThen field.sepBy(symbol(",")) thenSkip symbol("}")
    jsonString.map<String, Json> { Json.Str(it) } or number.map { Json.Num(it) } or arr.map { Json.Arr(it) } or
        obj.map { Json.Obj(it.toMap()) } or symbol("null").map { Json.Null }
}

fun main() {
    val env = mapOf("x" to 3.0, "y" to 4.0, "rate" to 0.5)
    val inputs = listOf(
        "1 + 2 * 3", "(1 + 2) * 3", "x * x + y * y", "-x + 10 / 4", "max(x, y, 2) * rate", "sum(1, 2, 3, 4) % 3",
        "min()", "unknown + 1", "foo(1)", "7 / (y - 4)", "2 *", "(1 + 2", "3 $ 4", "  12.5  ",
    )
    for (text in inputs) {
        val line = expr.parseAll(text).fold(
            onSuccess = { e, _ ->
                try {
                    "${show(e)} = ${eval(e, env)}"
                } catch (ex: EvalException) {
                    "${show(e)} fails: ${ex.message}"
                } catch (ex: NoSuchElementException) {
                    "${show(e)} fails: ${ex::class.simpleName}"
                }
            },
            onFailure = { expected, at -> "syntax error: expected $expected at $at" },
        )
        println("$text  =>  $line")
    }
    val docs = listOf(
        """{"name": "k2l", "tags": ["lua", "kotlin"], "stars": 42, "meta": {"license": null}}""",
        """[1, 2.5, [], {}]""",
        """{"a": [1, 2,]}""",
        """{"unterminated": "abc""",
    )
    for (d in docs) {
        println(json.parseAll(d).fold({ v, _ -> v.render() }, { exp, at -> "error: expected $exp at $at" }))
    }
    val r = json.parseAll("""{"k": [1, 2, 3]}""")
    if (r is ParseResult.Success) {
        val items = ((r.value as Json.Obj).fields["k"] as Json.Arr).items
        println("k has ${items.size} items, sum ${items.sumOf { (it as Json.Num).n }}")
    }
    println(Parser.pure(5).map { it * 2 }.parse(Input("rest")))
    println(Parser.fail("nothing").parse(Input("")))
    println((char('a') or char('b')).many().parse(Input("abbac")))
}
