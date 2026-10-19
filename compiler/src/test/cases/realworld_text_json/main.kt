// A hand-written JSON parser with positions in its errors, a pretty printer, a compact printer,
// JSON pointer lookup and a small schema-ish validator.

sealed class Json {
    object Null : Json()
    data class Bool(val value: Boolean) : Json()
    data class Num(val value: Double) : Json()
    data class Str(val value: String) : Json()
    data class Arr(val items: List<Json>) : Json()
    data class Obj(val fields: LinkedHashMap<String, Json>) : Json()
}

class JsonError(message: String, val offset: Int) : Exception(message)

class Parser(private val src: String) {
    private var pos = 0

    fun parse(): Json {
        val v = value()
        skipWs()
        if (pos < src.length) fail("unexpected trailing '${src[pos]}'")
        return v
    }

    private fun fail(msg: String): Nothing {
        val line = src.substring(0, pos.coerceAtMost(src.length)).count { it == '\n' } + 1
        val col = pos - (src.lastIndexOf('\n', pos - 1).let { if (it < 0) -1 else it })
        throw JsonError("$msg at line $line, column $col", pos)
    }

    private fun skipWs() {
        while (pos < src.length && src[pos].isWhitespace()) pos++
    }

    private fun peek(): Char = if (pos < src.length) src[pos] else '\u0000'

    private fun expect(c: Char) {
        skipWs()
        if (peek() != c) fail("expected '$c' but found ${if (pos < src.length) "'${src[pos]}'" else "end of input"}")
        pos++
    }

    private fun value(): Json {
        skipWs()
        return when (val c = peek()) {
            '{' -> obj()
            '[' -> arr()
            '"' -> Json.Str(string())
            't', 'f', 'n' -> literal()
            else -> if (c == '-' || c.isDigit()) number() else fail("unexpected character '${c}'")
        }
    }

    private fun literal(): Json {
        for ((word, v) in listOf("true" to Json.Bool(true), "false" to Json.Bool(false), "null" to Json.Null)) {
            if (src.startsWith(word, pos)) {
                pos += word.length
                return v
            }
        }
        fail("bad literal")
    }

    private fun number(): Json {
        val start = pos
        if (peek() == '-') pos++
        while (peek().isDigit()) pos++
        if (peek() == '.') {
            pos++
            if (!peek().isDigit()) fail("digit expected after '.'")
            while (peek().isDigit()) pos++
        }
        if (peek() == 'e' || peek() == 'E') {
            pos++
            if (peek() == '+' || peek() == '-') pos++
            while (peek().isDigit()) pos++
        }
        val text = src.substring(start, pos)
        return Json.Num(text.toDoubleOrNull() ?: fail("bad number '$text'"))
    }

    private fun string(): String {
        expect('"')
        val sb = StringBuilder()
        while (true) {
            if (pos >= src.length) fail("unterminated string")
            val c = src[pos++]
            when (c) {
                '"' -> return sb.toString()
                '\\' -> {
                    when (val e = src[pos++]) {
                        'n' -> sb.append('\n')
                        't' -> sb.append('\t')
                        'r' -> sb.append('\r')
                        'b' -> sb.append('\b')
                        '/' -> sb.append('/')
                        '\\' -> sb.append('\\')
                        '"' -> sb.append('"')
                        'u' -> {
                            val hex = src.substring(pos, pos + 4)
                            pos += 4
                            sb.append(hex.toInt(16).toChar())
                        }
                        else -> fail("bad escape '\\$e'")
                    }
                }
                else -> sb.append(c)
            }
        }
    }

    private fun arr(): Json {
        expect('[')
        val items = mutableListOf<Json>()
        skipWs()
        if (peek() == ']') {
            pos++
            return Json.Arr(items)
        }
        while (true) {
            items += value()
            skipWs()
            when (peek()) {
                ',' -> pos++
                ']' -> { pos++; return Json.Arr(items) }
                else -> fail("expected ',' or ']'")
            }
        }
    }

    private fun obj(): Json {
        expect('{')
        val fields = LinkedHashMap<String, Json>()
        skipWs()
        if (peek() == '}') {
            pos++
            return Json.Obj(fields)
        }
        while (true) {
            skipWs()
            val key = string()
            expect(':')
            fields[key] = value()
            skipWs()
            when (peek()) {
                ',' -> pos++
                '}' -> { pos++; return Json.Obj(fields) }
                else -> fail("expected ',' or '}'")
            }
        }
    }
}

fun quote(s: String): String = buildString {
    append('"')
    for (c in s) {
        when {
            c == '"' -> append("\\\"")
            c == '\\' -> append("\\\\")
            c == '\n' -> append("\\n")
            c == '\t' -> append("\\t")
            c.code < 0x20 -> append("\\u").append(c.code.toString(16).padStart(4, '0'))
            else -> append(c)
        }
    }
    append('"')
}

fun formatNumber(d: Double): String =
    if (d == Math.floor(d) && !d.isInfinite() && Math.abs(d) < 1e15) d.toLong().toString() else d.toString()

fun Json.compact(): String = when (this) {
    Json.Null -> "null"
    is Json.Bool -> value.toString()
    is Json.Num -> formatNumber(value)
    is Json.Str -> quote(value)
    is Json.Arr -> items.joinToString(",", "[", "]") { it.compact() }
    is Json.Obj -> fields.entries.joinToString(",", "{", "}") { (k, v) -> quote(k) + ":" + v.compact() }
}

fun Json.pretty(indent: Int = 0, step: String = "  "): String {
    val pad = step.repeat(indent)
    val inner = step.repeat(indent + 1)
    return when (this) {
        is Json.Arr -> if (items.isEmpty()) "[]" else
            items.joinToString(",\n", "[\n", "\n$pad]") { inner + it.pretty(indent + 1, step) }
        is Json.Obj -> if (fields.isEmpty()) "{}" else
            fields.entries.joinToString(",\n", "{\n", "\n$pad}") { (k, v) -> "$inner${quote(k)}: ${v.pretty(indent + 1, step)}" }
        else -> compact()
    }
}

fun Json.pointer(path: String): Json? {
    if (path.isEmpty()) return this
    var cur: Json = this
    for (raw in path.removePrefix("/").split("/")) {
        val token = raw.replace("~1", "/").replace("~0", "~")
        cur = when (val c = cur) {
            is Json.Obj -> c.fields[token] ?: return null
            is Json.Arr -> token.toIntOrNull()?.let { c.items.getOrNull(it) } ?: return null
            else -> return null
        }
    }
    return cur
}

fun stats(j: Json, depth: Int = 0, acc: MutableMap<String, Int> = sortedMapOf()): Map<String, Int> {
    val kind = j::class.simpleName ?: "?"
    acc[kind] = (acc[kind] ?: 0) + 1
    acc["maxDepth"] = maxOf(acc["maxDepth"] ?: 0, depth)
    when (j) {
        is Json.Arr -> j.items.forEach { stats(it, depth + 1, acc) }
        is Json.Obj -> j.fields.values.forEach { stats(it, depth + 1, acc) }
        else -> {}
    }
    return acc
}

val DOC = """
{
  "name": "k2l",
  "version": "0.2.0",
  "tags": ["kotlin", "lua", "transpiler"],
  "stars": 1234,
  "ratio": 0.875,
  "big": 1.5e20,
  "neg": -42.25e-3,
  "nested": {"a/b": {"m~n": [1, 2, {"deep": true}]}, "empty": {}, "none": null},
  "escaped": "line1\nline2\t\"quoted\" \\ éA",
  "matrix": [[1, 2], [3, 4], []]
}
""".trimIndent()

fun main() {
    val doc = Parser(DOC).parse()
    println(doc.pretty())
    println(doc.compact())
    println(doc.pretty(step = "\t").lines().take(4).joinToString("|"))

    for (p in listOf("/name", "/tags/1", "/nested/a~1b/m~0n/2/deep", "/matrix/1/0", "/missing", "/tags/9", "")) {
        val r = doc.pointer(p)
        println("pointer '%s' -> %s".format(p, r?.compact()?.take(30) ?: "<none>"))
    }
    println(stats(doc))

    val roundTrip = Parser(doc.compact()).parse()
    println("round trip equal: ${roundTrip == doc}")

    val bad = listOf(
        "{\"a\": 1,}",
        "[1, 2",
        "{\"a\" 1}",
        "\"unterminated",
        "[1.]",
        "{\n  \"x\": tru\n}",
        "[1] 2",
        "@",
    )
    for (b in bad) {
        try {
            Parser(b).parse()
            println("parsed?! $b")
        } catch (e: JsonError) {
            println("error: ${e.message} (offset ${e.offset})")
        }
    }

    // a tiny report built from parsed values
    val people = Parser("""[{"n":"Ada","age":36,"langs":["en","fr"]},{"n":"Linus","age":54.5,"langs":[]},{"n":"Grace","age":85,"langs":["en"]}]""").parse()
    val rows = (people as Json.Arr).items.map { it as Json.Obj }
    println(String.format("%-8s|%6s|%s", "name", "age", "langs"))
    for (r in rows) {
        val name = (r.fields["n"] as Json.Str).value
        val age = (r.fields["age"] as Json.Num).value
        val langs = (r.fields["langs"] as Json.Arr).items.joinToString("+") { (it as Json.Str).value }.ifEmpty { "-" }
        println(String.format("%-8s|%6.1f|%s", name, age, langs))
    }
    val avg = rows.map { (it.fields["age"] as Json.Num).value }.average()
    println("average age %.3f, %e, %g".format(avg, avg, avg))
}
