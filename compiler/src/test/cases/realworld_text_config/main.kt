// A TOML-ish configuration parser: sections and dotted sub-tables, typed values (strings with escapes, literal
// strings, integers with underscores, hex/octal/binary, floats, booleans, arrays, inline tables), comments,
// duplicate-key and syntax errors with line numbers, then typed lookups, environment overrides and a re-serializer.

class ConfigError(val line: Int, msg: String) : Exception("line $line: $msg")

sealed interface TValue
data class TStr(val v: String) : TValue
data class TInt(val v: Long) : TValue
data class TFloat(val v: Double) : TValue
data class TBool(val v: Boolean) : TValue
data class TArr(val v: List<TValue>) : TValue
data class TTable(val v: LinkedHashMap<String, TValue> = LinkedHashMap()) : TValue

class ValueReader(private val s: String, private val line: Int) {
    var i = 0

    fun fail(msg: String): Nothing = throw ConfigError(line, "$msg (column ${i + 1})")

    fun ws() {
        while (i < s.length && (s[i] == ' ' || s[i] == '\t')) i++
    }

    fun read(): TValue {
        ws()
        if (i >= s.length) fail("missing value")
        return when (val c = s[i]) {
            '"' -> TStr(basicString())
            '\'' -> {
                val end = s.indexOf('\'', i + 1).takeIf { it > 0 } ?: fail("unterminated literal string")
                TStr(s.substring(i + 1, end)).also { i = end + 1 }
            }
            '[' -> array()
            '{' -> inline()
            else -> if (c.isLetter()) keyword() else number()
        }
    }

    private fun basicString(): String {
        i++
        val sb = StringBuilder()
        while (true) {
            if (i >= s.length) fail("unterminated string")
            val c = s[i++]
            if (c == '"') return sb.toString()
            if (c != '\\') {
                sb.append(c)
                continue
            }
            when (val e = s.getOrNull(i++) ?: fail("dangling escape")) {
                'n' -> sb.append('\n')
                't' -> sb.append('\t')
                '"' -> sb.append('"')
                '\\' -> sb.append('\\')
                'u' -> {
                    val hex = s.substring(i, minOf(i + 4, s.length))
                    if (hex.length < 4 || !hex.all { it.isDigit() || it.lowercaseChar() in 'a'..'f' }) fail("bad unicode escape '\\u$hex'")
                    sb.append(hex.toInt(16).toChar())
                    i += 4
                }
                else -> fail("unknown escape '\\$e'")
            }
        }
    }

    private fun keyword(): TValue {
        val word = s.substring(i).takeWhile { it.isLetter() }
        i += word.length
        return when (word) {
            "true" -> TBool(true)
            "false" -> TBool(false)
            "inf" -> TFloat(Double.POSITIVE_INFINITY)
            "nan" -> TFloat(Double.NaN)
            else -> fail("unknown word '$word'")
        }
    }

    private fun number(): TValue {
        val token = Regex("[-+0-9a-zA-Z_.]+").matchAt(s, i)?.value ?: fail("unexpected '${s[i]}'")
        i += token.length
        val clean = token.replace("_", "")
        if (token.contains("__") || token.startsWith("_") || token.endsWith("_")) fail("misplaced underscore in '$token'")
        return when {
            clean.startsWith("0x") -> TInt(clean.drop(2).toLongOrNull(16) ?: fail("bad hex '$token'"))
            clean.startsWith("0o") -> TInt(clean.drop(2).toLongOrNull(8) ?: fail("bad octal '$token'"))
            clean.startsWith("0b") -> TInt(clean.drop(2).toLongOrNull(2) ?: fail("bad binary '$token'"))
            clean.any { it == '.' || it == 'e' || it == 'E' } -> TFloat(clean.toDoubleOrNull() ?: fail("bad float '$token'"))
            else -> TInt(clean.toLongOrNull() ?: fail("bad integer '$token'"))
        }
    }

    private fun array(): TValue {
        i++
        val items = mutableListOf<TValue>()
        while (true) {
            ws()
            if (i < s.length && s[i] == ']') { i++; return TArr(items) }
            items += read()
            ws()
            when (s.getOrNull(i)) {
                ',' -> i++
                ']' -> { i++; return TArr(items) }
                else -> fail("expected ',' or ']' in array")
            }
        }
    }

    private fun inline(): TValue {
        i++
        val t = TTable()
        while (true) {
            ws()
            if (s.getOrNull(i) == '}') { i++; return t }
            val key = s.substring(i).takeWhile { it.isLetterOrDigit() || it == '_' || it == '-' }
            if (key.isEmpty()) fail("expected key in inline table")
            i += key.length
            ws()
            if (s.getOrNull(i++) != '=') fail("expected '=' after '$key'")
            t.v[key] = read()
            ws()
            when (s.getOrNull(i)) {
                ',' -> i++
                '}' -> { i++; return t }
                else -> fail("expected ',' or '}'")
            }
        }
    }
}

fun stripComment(line: String): String {
    var inStr: Char? = null
    for ((idx, c) in line.withIndex()) {
        when {
            inStr != null && c == inStr && (inStr == '\'' || line.getOrNull(idx - 1) != '\\') -> inStr = null
            inStr == null && (c == '"' || c == '\'') -> inStr = c
            inStr == null && c == '#' -> return line.substring(0, idx)
        }
    }
    return line
}

fun parseConfig(text: String): TTable {
    val root = TTable()
    var current = root
    text.lines().forEachIndexed { n, raw ->
        val lineNo = n + 1
        val line = stripComment(raw).trim()
        if (line.isEmpty()) return@forEachIndexed
        val header = Regex("""^\[\s*([A-Za-z0-9_.-]+)\s*]$""").matchEntire(line)
        if (header != null) {
            current = root
            for (part in header.groupValues[1].split('.')) {
                current = when (val existing = current.v[part]) {
                    null -> TTable().also { current.v[part] = it }
                    is TTable -> existing
                    else -> throw ConfigError(lineNo, "'$part' is not a table")
                }
            }
            return@forEachIndexed
        }
        val eq = line.indexOf('=')
        if (eq <= 0) throw ConfigError(lineNo, "expected 'key = value' but got '${line.take(20)}'")
        val key = line.substring(0, eq).trim().removeSurrounding("\"")
        if (!key.matches(Regex("[A-Za-z0-9_-]+"))) throw ConfigError(lineNo, "invalid key '$key'")
        if (key in current.v) throw ConfigError(lineNo, "duplicate key '$key'")
        val reader = ValueReader(line.substring(eq + 1), lineNo)
        current.v[key] = reader.read()
        reader.ws()
        if (reader.i < line.length - eq - 1) reader.fail("trailing characters")
    }
    return root
}

fun TTable.lookup(path: String): TValue? =
    path.split('.').fold(this as TValue?) { acc, k -> (acc as? TTable)?.v?.get(k) }

fun render(v: TValue): String = when (v) {
    is TStr -> "\"" + v.v.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\t", "\\t") + "\""
    is TInt -> v.v.toString()
    is TFloat -> if (v.v.isNaN()) "nan" else if (v.v.isInfinite()) "inf" else v.v.toString()
    is TBool -> v.v.toString()
    is TArr -> v.v.joinToString(", ", "[", "]") { render(it) }
    is TTable -> v.v.entries.joinToString(", ", "{ ", " }") { "${it.key} = ${render(it.value)}" }
}

fun serialize(t: TTable, prefix: String = "", out: StringBuilder = StringBuilder()): String {
    val (tables, values) = t.v.entries.partition { it.value is TTable && (it.value as TTable).v.values.any { v -> v is TTable } || prefix.isEmpty() && it.value is TTable }
    for ((k, v) in values) out.append(k).append(" = ").append(render(v)).append('\n')
    for ((k, v) in tables) {
        val name = if (prefix.isEmpty()) k else "$prefix.$k"
        out.append('\n').append('[').append(name).append("]\n")
        serialize(v as TTable, name, out)
    }
    return out.toString()
}

val CONFIG = """
# Service configuration
title = "k2l \"demo\" service"   # trailing comment
version = 3
pi_ish = 3.141_59
big = 9_007_199_254_740_991
mask = 0xFF_FF
perms = 0o755
flags = 0b1010_1010
ratio = -2.5e-3
enabled = true
path = 'C:\Users\k2l\#notacomment'
greeting = "tab\there, newline\nthere, unicode \u00e9\u00df"
ports = [ 8080, 8081 , 8443 ]
matrix = [[1, 2], [3], []]
owner = { name = "Ada", id = 36, roles = ["admin", "dev"] }

[database]
host = "db.local"
port = 5432
timeout = inf

[database.pool]
min = 2
max = 16

[logging]
level = "INFO"
""".trimIndent()

fun main() {
    val cfg = parseConfig(CONFIG)
    for (path in listOf("title", "version", "pi_ish", "big", "mask", "perms", "flags", "ratio", "enabled", "path", "greeting", "ports",
        "matrix", "owner.roles", "owner.id", "database.port", "database.timeout", "database.pool.max", "logging.level", "nope", "owner.nope")) {
        println("%-18s %-7s %s".format(path, cfg.lookup(path)?.let { it::class.simpleName } ?: "-", cfg.lookup(path)?.let(::render) ?: "<missing>"))
    }
    val maxConn = (cfg.lookup("database.pool.max") as TInt).v * (cfg.lookup("ports") as TArr).v.size
    println("max connections: $maxConn, mask bits: ${(cfg.lookup("mask") as TInt).v.countOneBits()}, perms: ${(cfg.lookup("perms") as TInt).v.toString(8)}")
    println("--- serialized ---")
    print(serialize(cfg))
    println("--- round trip ---")
    val again = parseConfig(serialize(cfg))
    println(serialize(again) == serialize(cfg))

    val env = mapOf("APP_DATABASE_PORT" to "6543", "APP_LOGGING_LEVEL" to "debug", "APP_UNKNOWN" to "x")
    for ((k, v) in env) {
        val path = k.removePrefix("APP_").lowercase().replace('_', '.')
        val old = cfg.lookup(path)
        println("$k -> $path: ${old?.let(::render) ?: "(none)"} => ${v.toLongOrNull()?.toString() ?: "\"${v.uppercase()}\""}")
    }

    val broken = listOf(
        "a = 1\na = 2",
        "x = [1, 2",
        "s = \"abc",
        "n = 12__3",
        "h = 0xZZ",
        "[t]\nv = 1\n[t.v]\n",
        "just some words",
        "k = \"bad \\q escape\"",
        "u = \"\\u12\"",
        "f = 1.2.3",
        "w = yes",
        "t = { a = 1 b = 2 }",
        "ok = 1 2",
    )
    for (b in broken) {
        try {
            parseConfig(b)
            println("accepted: ${b.replace("\n", "\\n")}")
        } catch (e: ConfigError) {
            println("error ${e.message}")
        }
    }
}
