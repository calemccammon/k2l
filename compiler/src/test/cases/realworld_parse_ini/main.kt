// An INI loader with sections, continuation lines, `${key}` / `${section.key}` / `${env:NAME:-default}` interpolation,
// cycle detection, typed getters with lazy delegates, and profile overlays merged with `+=` on maps.

class ConfigError(msg: String, val line: Int = 0) : RuntimeException(if (line > 0) "line $line: $msg" else msg)

class RawConfig {
    val sections = linkedMapOf<String, LinkedHashMap<String, Pair<String, Int>>>()
    val order = mutableListOf<String>()
}

fun parseIni(text: String): RawConfig {
    val cfg = RawConfig()
    var section = "general"
    var lastKey: String? = null
    val header = Regex("""^\[\s*([\w.-]+)\s*]$""")
    for ((idx, rawLine) in text.lines().withIndex()) {
        val n = idx + 1
        val line = rawLine.trimEnd()
        val trimmed = line.trimStart()
        when {
            trimmed.isEmpty() || trimmed[0] == ';' || trimmed[0] == '#' -> lastKey = null
            line[0].isWhitespace() && lastKey != null -> {
                val map = cfg.sections.getValue(section)
                val (old, at) = map.getValue(lastKey)
                map[lastKey] = (old + " " + trimmed) to at
            }
            trimmed.startsWith("[") -> {
                section = header.matchEntire(trimmed)?.groupValues?.get(1)?.lowercase() ?: throw ConfigError("bad section header '$trimmed'", n)
                if (section !in cfg.sections) cfg.order += section
                cfg.sections.getOrPut(section) { linkedMapOf() }
                lastKey = null
            }
            else -> {
                val eq = trimmed.indexOfAny(charArrayOf('=', ':'))
                if (eq <= 0) throw ConfigError("expected key = value, got '$trimmed'", n)
                val key = trimmed.substring(0, eq).trim().lowercase()
                if (!key.all { it.isLetterOrDigit() || it == '_' || it == '-' }) throw ConfigError("invalid key '$key'", n)
                var value = trimmed.substring(eq + 1).trim()
                if (value.length >= 2 && value.first() == '"' && value.last() == '"') value = unquote(value.substring(1, value.length - 1), n)
                else value = value.substringBefore(" ;").substringBefore(" #").trimEnd()
                if (section !in cfg.sections) { cfg.order += section; cfg.sections[section] = linkedMapOf() }
                cfg.sections.getValue(section)[key] = value to n
                lastKey = key
            }
        }
    }
    return cfg
}

fun unquote(s: String, line: Int): String = buildString {
    var i = 0
    while (i < s.length) {
        val c = s[i++]
        if (c != '\\') { append(c); continue }
        if (i >= s.length) throw ConfigError("dangling backslash", line)
        when (val e = s[i++]) {
            'n' -> append('\n')
            't' -> append('\t')
            '$' -> append("\$\u0000")
            '\\', '"' -> append(e)
            else -> throw ConfigError("unknown escape \\$e", line)
        }
    }
}

class Resolver(private val raw: RawConfig, private val env: Map<String, String>) {
    private val cache = HashMap<String, String>()
    private val stack = ArrayDeque<String>()
    private val ref = Regex("""\$\{([^}]*)}""")

    fun get(section: String, key: String): String {
        val full = "$section.$key"
        cache[full]?.let { return it }
        if (full in stack) throw ConfigError("interpolation cycle: ${(stack.dropWhile { it != full } + full).joinToString(" -> ")}")
        val (value, line) = raw.sections[section]?.get(key) ?: throw ConfigError("missing key '$full'")
        stack.addLast(full)
        try {
            val out = ref.replace(value) { m -> lookup(section, m.groupValues[1].trim(), line) }
            cache[full] = out
            return out
        } finally {
            stack.removeLast()
        }
    }

    private fun lookup(section: String, expr: String, line: Int): String = when {
        expr.isEmpty() -> throw ConfigError("empty reference", line)
        expr.startsWith("env:") -> {
            val spec = expr.removePrefix("env:")
            val name = spec.substringBefore(":-")
            env[name] ?: if (":-" in spec) spec.substringAfter(":-") else throw ConfigError("environment variable $name is not set", line)
        }
        '.' in expr -> get(expr.substringBeforeLast('.').lowercase(), expr.substringAfterLast('.').lowercase())
        else -> get(section, expr.lowercase())
    }

    fun resolved(section: String): Map<String, String> =
        raw.sections[section]?.keys?.associateWith { get(section, it).replace("\$\u0000", "$") } ?: emptyMap()
}

class ServerSettings(private val values: Map<String, String>) {
    val host: String by lazy { values["host"] ?: "localhost" }
    val port: Int by lazy { values["port"]?.toIntOrNull()?.takeIf { it in 1..65535 } ?: throw ConfigError("port must be 1..65535, was '${values["port"]}'") }
    val debug: Boolean by lazy {
        when (values["debug"]?.lowercase()) {
            null, "false", "no", "off", "0" -> false
            "true", "yes", "on", "1" -> true
            else -> throw ConfigError("not a boolean: ${values["debug"]}")
        }
    }
    val timeouts: List<Double> by lazy { values["timeouts"].orEmpty().split(',').filter { it.isNotBlank() }.map { it.trim().toDouble() } }
    override fun toString() = "Server($host:$port debug=$debug timeouts=$timeouts)"
}

val base = """
; global settings
app = shop
version = 2.3.1
home = /srv/${'$'}{app}

[database]
host = db.internal
port = 5432
url = postgres://${'$'}{user}@${'$'}{host}:${'$'}{port}/${'$'}{general.app}
user = ${'$'}{env:DB_USER:-app}
password = "s3cr\${'$'}t \"quoted\""

[server]
host = 0.0.0.0
port = 8080
debug = off
timeouts = 1.5, 3,
   10.25
banner: Welcome to ${'$'}{general.app} v${'$'}{general.version} ; trailing comment
logdir = ${'$'}{general.home}/logs

[paths]
a = ${'$'}{b}
b = ${'$'}{c}
c = ${'$'}{a}
""".trimIndent()

val overlay = """
[server]
port = 9090
debug = YES
""".trimIndent()

fun main() {
    val raw = parseIni(base)
    val over = parseIni(overlay)
    for ((name, values) in over.sections) raw.sections.getOrPut(name) { linkedMapOf() } += values
    println("sections: ${raw.order}")
    val r = Resolver(raw, mapOf("HOME" to "/root"))
    for (s in listOf("general", "database", "server")) {
        println("[$s]")
        r.resolved(s).forEach { (k, v) -> println("  $k = ${v.replace("\n", "\\n")}") }
    }
    val server = ServerSettings(r.resolved("server"))
    println(server)
    println("timeout total = ${server.timeouts.sum()}")
    println(runCatching { r.get("paths", "a") }.exceptionOrNull()?.message)
    println(runCatching { r.get("database", "nope") }.exceptionOrNull()?.message)
    println(runCatching { Resolver(parseIni("x = \${env:NOPE}"), emptyMap()).get("general", "x") }.exceptionOrNull()?.message)
    println(runCatching { ServerSettings(mapOf("port" to "70000")).port }.exceptionOrNull()?.message)
    println(runCatching { ServerSettings(mapOf("debug" to "maybe")).debug }.exceptionOrNull()?.message)
    val broken = listOf("[bad header", "novalue", "k ey = 1", "s = \"bad \\q\"", "[ok]\n\n = 3", "r = \${}")
    for (text in broken) {
        val msg = try {
            val cfg = parseIni(text)
            val res = Resolver(cfg, emptyMap())
            cfg.sections.flatMap { (s, m) -> m.keys.map { res.get(s, it) } }.toString()
        } catch (e: ConfigError) {
            "ConfigError(${e.message})"
        }
        println("${text.replace("\n", "|")} => $msg")
    }
}
