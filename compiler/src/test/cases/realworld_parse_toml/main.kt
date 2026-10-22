// A TOML-subset parser (tables, arrays of tables, dotted keys, inline tables and arrays, basic and literal
// strings with \u and \U escapes, hex/octal/binary integers with underscores, floats, booleans) that converts
// the document to pretty-printed JSON, escaping control characters and non-ASCII text.

sealed interface TValue
data class TStr(val s: String) : TValue
data class TInt(val v: Long) : TValue
data class TFloat(val v: Double) : TValue
data class TBool(val v: Boolean) : TValue
data class TArr(val items: MutableList<TValue> = mutableListOf()) : TValue
data class TTable(val map: LinkedHashMap<String, TValue> = LinkedHashMap(), var inline: Boolean = false) : TValue

class TomlError(val line: Int, msg: String) : IllegalArgumentException("line $line: $msg")

class TomlParser(text: String) {
    private val src = text
    private var i = 0
    private var line = 1
    private val root = TTable()
    private var current = root

    private fun fail(msg: String): Nothing = throw TomlError(line, msg)
    private fun peek(): Char? = src.getOrNull(i)
    private fun skipSpaces() { while (peek() == ' ' || peek() == '\t') i++ }

    private fun skipToEol() {
        skipSpaces()
        if (peek() == '#') while (peek() != null && peek() != '\n') i++
        when (peek()) {
            null -> {}
            '\n' -> { i++; line++ }
            '\r' -> if (src.getOrNull(i + 1) == '\n') { i += 2; line++ } else fail("stray carriage return")
            else -> fail("expected end of line, found '${peek()}'")
        }
    }

    fun parse(): TTable {
        while (i < src.length) {
            skipSpaces()
            when (peek()) {
                '#', '\n', '\r' -> skipToEol()
                '[' -> header()
                null -> {}
                else -> { keyValue(current); skipToEol() }
            }
        }
        return root
    }

    private fun header() {
        val array = src.startsWith("[[", i)
        i += if (array) 2 else 1
        val path = key()
        if (array) {
            if (!src.startsWith("]]", i)) fail("expected ']]'")
            i += 2
            val parent = descend(root, path.dropLast(1))
            val arr = parent.map.getOrPut(path.last()) { TArr() } as? TArr ?: fail("'${path.last()}' is not an array of tables")
            current = TTable().also { arr.items += it }
        } else {
            if (peek() != ']') fail("expected ']'")
            i++
            current = descend(root, path)
        }
        skipToEol()
    }

    private fun descend(start: TTable, path: List<String>): TTable = path.fold(start) { t, k ->
        when (val v = t.map.getOrPut(k) { TTable() }) {
            is TTable -> if (v.inline) fail("cannot extend inline table '$k'") else v
            is TArr -> v.items.lastOrNull() as? TTable ?: fail("'$k' is not a table")
            else -> fail("key '$k' already holds a ${v::class.simpleName}")
        }
    }

    private fun key(): List<String> {
        val parts = mutableListOf<String>()
        do {
            skipSpaces()
            parts += when (peek()) {
                '"' -> basicString()
                '\'' -> literalString()
                else -> {
                    val start = i
                    while (peek()?.let { it.isLetterOrDigit() || it == '_' || it == '-' } == true) i++
                    if (start == i) fail("expected a key")
                    src.substring(start, i)
                }
            }
            skipSpaces()
        } while (peek() == '.' && i++ >= 0)
        return parts
    }

    private fun keyValue(into: TTable) {
        val path = key()
        if (peek() != '=') fail("expected '=' after key '${path.joinToString(".")}'")
        i++
        skipSpaces()
        val target = descend(into, path.dropLast(1))
        if (path.last() in target.map) fail("duplicate key '${path.joinToString(".")}'")
        target.map[path.last()] = value()
    }

    private fun value(): TValue = when (val c = peek()) {
        '"' -> TStr(basicString())
        '\'' -> TStr(literalString())
        '[' -> array()
        '{' -> inlineTable()
        't', 'f' -> word()
        null -> fail("expected a value")
        else -> if (c.isDigit() || c in "+-i") number() else fail("unexpected '$c'")
    }

    private fun word(): TValue {
        for ((w, v) in listOf("true" to true, "false" to false)) if (src.startsWith(w, i)) { i += w.length; return TBool(v) }
        fail("bad literal")
    }

    private fun number(): TValue {
        val start = i
        while (peek()?.let { it.isLetterOrDigit() || it in "+-._" } == true) i++
        val raw = src.substring(start, i)
        if (raw.startsWith("_") || raw.endsWith("_") || "__" in raw) fail("misplaced underscore in '$raw'")
        val t = raw.replace("_", "")
        val radix = when {
            t.startsWith("0x") -> 16
            t.startsWith("0o") -> 8
            t.startsWith("0b") -> 2
            else -> 10
        }
        if (radix != 10) return TInt(t.substring(2).toLongOrNull(radix) ?: fail("bad integer '$raw'"))
        when (t) {
            "inf", "+inf" -> return TFloat(Double.POSITIVE_INFINITY)
            "-inf" -> return TFloat(Double.NEGATIVE_INFINITY)
        }
        if (t.any { it in ".eE" }) return TFloat(t.toDoubleOrNull() ?: fail("bad float '$raw'"))
        return TInt(t.toLongOrNull() ?: fail("bad integer '$raw'"))
    }

    private fun array(): TArr {
        i++
        val arr = TArr()
        while (true) {
            skipWsAndComments()
            if (peek() == ']') { i++; return arr }
            arr.items += value()
            skipWsAndComments()
            when (peek()) {
                ',' -> i++
                ']' -> { i++; return arr }
                else -> fail("expected ',' or ']' in array")
            }
        }
    }

    private fun skipWsAndComments() {
        while (true) {
            when (peek()) {
                ' ', '\t', '\r' -> i++
                '\n' -> { i++; line++ }
                '#' -> while (peek() != null && peek() != '\n') i++
                else -> return
            }
        }
    }

    private fun inlineTable(): TTable {
        i++
        val t = TTable()
        skipSpaces()
        if (peek() == '}') { i++; return t.also { it.inline = true } }
        while (true) {
            keyValue(t)
            skipSpaces()
            when (peek()) {
                ',' -> i++
                '}' -> { i++; return t.also { it.inline = true } }
                else -> fail("expected ',' or '}' in inline table")
            }
        }
    }

    private fun literalString(): String {
        val end = src.indexOf('\'', i + 1)
        if (end < 0 || '\n' in src.substring(i, end)) fail("unterminated literal string")
        return src.substring(i + 1, end).also { i = end + 1 }
    }

    private fun basicString(): String {
        i++
        val sb = StringBuilder()
        while (true) {
            val c = peek() ?: fail("unterminated string")
            i++
            when (c) {
                '"' -> return sb.toString()
                '\n' -> fail("newline in string")
                '\\' -> escape(sb)
                else -> sb.append(c)
            }
        }
    }

    private fun escape(sb: StringBuilder) {
        val e = peek() ?: fail("unterminated escape")
        i++
        when (e) {
            'b' -> sb.append('\b')
            't' -> sb.append('\t')
            'n' -> sb.append('\n')
            'f' -> sb.append('\u000C')
            'r' -> sb.append('\r')
            '"', '\\' -> sb.append(e)
            'u', 'U' -> {
                val n = if (e == 'u') 4 else 8
                val hex = src.substring(i, minOf(i + n, src.length))
                val cp = hex.takeIf { it.length == n }?.toIntOrNull(16) ?: fail("bad unicode escape '\\$e$hex'")
                if (cp in 0xD800..0xDFFF || cp > 0x10FFFF) fail("invalid code point U+${hex.uppercase()}")
                appendUtf8(sb, cp)
                i += n
            }
            else -> fail("unknown escape '\\$e'")
        }
    }
}

// Strings are bytes in Lua: a code point is appended as its UTF-8 bytes, one Char each.
fun appendUtf8(sb: StringBuilder, cp: Int) {
    when {
        cp < 0x80 -> sb.append(cp.toChar())
        cp < 0x800 -> sb.append((0xC0 or (cp shr 6)).toChar()).append((0x80 or (cp and 0x3F)).toChar())
        cp < 0x10000 -> sb.append((0xE0 or (cp shr 12)).toChar()).append((0x80 or ((cp shr 6) and 0x3F)).toChar())
            .append((0x80 or (cp and 0x3F)).toChar())
        else -> sb.append((0xF0 or (cp shr 18)).toChar()).append((0x80 or ((cp shr 12) and 0x3F)).toChar())
            .append((0x80 or ((cp shr 6) and 0x3F)).toChar()).append((0x80 or (cp and 0x3F)).toChar())
    }
}

fun jsonString(s: String): String = buildString {
    append('"')
    for (ch in s) {
        when {
            ch == '"' -> append("\\\"")
            ch == '\\' -> append("\\\\")
            ch == '\n' -> append("\\n")
            ch == '\t' -> append("\\t")
            ch < ' ' || ch.code > 0x7E -> append("\\u").append(ch.code.toString(16).padStart(4, '0'))
            else -> append(ch)
        }
    }
    append('"')
}

fun toJson(v: TValue, indent: String = "", out: StringBuilder = StringBuilder()): StringBuilder {
    val inner = "$indent  "
    when (v) {
        is TStr -> out.append(jsonString(v.s))
        is TInt -> out.append(v.v)
        is TFloat -> out.append(if (v.v.isInfinite()) jsonString(v.v.toString()) else v.v.toString())
        is TBool -> out.append(v.v)
        is TArr -> if (v.items.isEmpty()) out.append("[]") else {
            out.append("[\n")
            v.items.forEachIndexed { k, item ->
                out.append(inner)
                toJson(item, inner, out)
                out.append(if (k < v.items.lastIndex) ",\n" else "\n")
            }
            out.append(indent).append(']')
        }
        is TTable -> if (v.map.isEmpty()) out.append("{}") else {
            out.append("{\n")
            val last = v.map.keys.last()
            for ((k, item) in v.map) {
                out.append(inner).append(jsonString(k)).append(": ")
                toJson(item, inner, out)
                out.append(if (k == last) "\n" else ",\n")
            }
            out.append(indent).append('}')
        }
    }
    return out
}

fun stats(v: TValue): Map<String, Int> {
    val counts = sortedMapOf<String, Int>()
    fun walk(x: TValue) {
        counts.merge(x::class.simpleName!!, 1, Int::plus)
        when (x) {
            is TArr -> x.items.forEach(::walk)
            is TTable -> x.map.values.forEach(::walk)
            else -> {}
        }
    }
    walk(v)
    return counts
}

val doc = """
# Service configuration
title = "TOML \u2192 JSON"
owner.name = "Zoë \"zed\" Ångström"
owner.emoji = "\U0001F680 launch"
path = 'C:\Users\cfg'

[server]
host = "0.0.0.0"
ports = [ 8000, 8_001, 0x1F90 ]   # three listeners
timeout = 2.5e1
ratio = -0.125
debug = false
masks = [0o755, 0b1010_1010]

[server.limits]
max-body = 1_048_576
rates = { burst = 20, sustained = 5.0 }

[[plugin]]
name = "auth"
tags = ["core", 'sec', ]

[[plugin]]
name = "metrics"
options = { interval = 15, sinks = [ "stdout", "statsd" ] }
nested = [ [1, 2], [], ["a\tb"] ]

[empty]
"quoted key" = "tab\there"
bounds = [ inf, -inf ]
""".trimStart()

fun main() {
    val table = TomlParser(doc).parse()
    println(toJson(table))
    println(stats(table))
    val server = table.map["server"] as TTable
    val ports = (server.map["ports"] as TArr).items.map { (it as TInt).v }
    println("ports sum=${ports.sum()} max=${ports.max()} hex=${ports.joinToString { "0x" + it.toString(16) }}")
    val plugins = (table.map["plugin"] as TArr).items.filterIsInstance<TTable>()
    println("plugins: " + plugins.joinToString { (it.map["name"] as TStr).s })
    val owner = (table.map["owner"] as TTable).map["name"] as TStr
    println("owner length=${owner.s.length} upper=${owner.s.uppercase()}")
    println(table.map["title"] == TStr("TOML → JSON"))

    val bad = listOf(
        "a = 1\na = 2",
        "x = [1, 2",
        "s = \"abc",
        "n = 1__000",
        "e = \"\\uD800\"",
        "e = \"\\q\"",
        "[t]\nk = 1\n[t.k]\n",
        "t = { a = 1 }\n[t]\nb = 2",
        "v = 0xZZ",
        "k = 1 junk",
        "[[arr]]\n[arr.x]\ny=1\n[arr]",
        "f = 1.2.3",
        "= 3",
    )
    for (src in bad) {
        try {
            TomlParser(src).parse()
            println("ok?? ${src.replace("\n", "\\n")}")
        } catch (e: TomlError) {
            println("error ${e.message}")
        }
    }
}
