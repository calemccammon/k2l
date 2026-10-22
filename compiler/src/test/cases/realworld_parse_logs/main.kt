// A regex-driven log analyzer: several line formats matched with capture groups, key=value extraction, redaction with
// replace lambdas, multi-line stack traces glued back together, and a per-endpoint latency report. The regexes stay
// within what Lua patterns express: alternatives and optional parts are checked in Kotlin instead.

data class Entry(val time: String, val level: String, val source: String, val message: String, val fields: Map<String, String>)

// groups: ip, user, time, method, path, status, bytes, and the rest: nothing or " <ms>ms"
val accessLine = Regex(
    """^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) - (\S+) \[([^\]]+)] "([A-Z]+) (\S+) HTTP/[\d.]+" (\d{3}) ([\d-]+)(.*)$""",
)
val accessMs = Regex(""" (\d+)ms""")

// groups: time, level, source, message
val appLine = Regex("""^(\d{2}:\d{2}:\d{2}\.?\d*)\s+\[([a-z]+)]\s+([\w.$]+):\s*(.*)$""", RegexOption.IGNORE_CASE)
val levels = setOf("trace", "debug", "info", "warn", "error")
val kvKey = Regex("""(\w+)=""")
val nonBlank = Regex("""\S+""")
val traceLine = Regex("""^\s+at\s+([\w.$<>]+)\((\w+\.\w+):(\d+)\)""")
val emailish = Regex("""([\w.+-]+)@([\w-]+\.[\w.-]*\w)\b""")
val assignment = Regex("""(\w+)=\S+""")
val secrets = setOf("token", "password", "secret")
val digits = Regex("""\d+""")

class LogReport {
    val entries = mutableListOf<Entry>()
    val unparsed = mutableListOf<Pair<Int, String>>()
    val traces = mutableMapOf<Int, MutableList<String>>()
    val latency = sortedMapOf<String, MutableList<Int>>()
    val statuses = mutableMapOf<Int, Int>()
}

fun redact(s: String): String = assignment.replace(s) { m ->
    val key = m.groupValues[1].lowercase()
    if (key in secrets) "$key=***" else m.value
}.replace(emailish) { m -> m.groupValues[1].first() + "…@" + m.groupValues[2] }

/** The quoted value at [start], with its quotes (a backslash escapes the next character), or null. */
fun quotedAt(s: String, start: Int): String? {
    var i = start + 1
    while (i < s.length && s[i] != '"') i += if (s[i] == '\\') 2 else 1
    return if (i < s.length) s.substring(start, i + 1) else null
}

/** key=value and key="quoted \"value\"" pairs. */
fun parseFields(msg: String): Map<String, String> {
    val fields = mutableMapOf<String, String>()
    var from = 0
    while (from < msg.length) {
        val key = kvKey.find(msg, from) ?: break
        val at = key.range.last + 1
        val raw = (if (msg.startsWith("\"", at)) quotedAt(msg, at) else null) ?: nonBlank.matchAt(msg, at)?.value
        if (raw != null) fields[key.groupValues[1]] = if (raw.startsWith('"')) raw.substring(1, raw.length - 1).replace("\\\"", "\"") else raw
        from = at + (raw?.length ?: 0)
    }
    return fields
}

fun route(path: String): String = path.split('/').joinToString("/") { if (it.matches(digits)) "{id}" else it }

fun analyze(text: String): LogReport {
    val r = LogReport()
    var lastApp = -1
    for ((n, line) in text.lines().withIndex()) {
        if (line.isBlank()) continue
        val access = accessLine.matchEntire(line)?.takeIf { it.groupValues[8].isEmpty() || accessMs.matches(it.groupValues[8]) }
        val app = appLine.matchEntire(line)?.takeIf { it.groupValues[2].lowercase() in levels }
        val trace = traceLine.find(line)
        when {
            access != null -> {
                val (ip, _, time, method, path) = access.destructured
                val g = access.groupValues
                val route = route(path.substringBefore('?'))
                val status = g[6].toInt()
                r.statuses.merge(status / 100 * 100, 1, Int::plus)
                accessMs.matchEntire(g[8])?.let { r.latency.getOrPut("$method $route") { mutableListOf() } += it.groupValues[1].toInt() }
                val fields = mapOf("ip" to ip, "status" to status.toString(), "bytes" to g[7].replace("-", "0"))
                r.entries += Entry(time.substringAfter(':').substringBefore(' '), if (status >= 500) "ERROR" else "INFO", "http", route, fields)
                lastApp = -1
            }
            app != null -> {
                val (time, level, source, message) = app.destructured
                val msg = redact(message)
                r.entries += Entry(time, level.uppercase(), source, msg, parseFields(msg))
                lastApp = r.entries.lastIndex
            }
            trace != null && lastApp >= 0 -> {
                val (method, file, lineNo) = trace.destructured
                r.traces.getOrPut(lastApp) { mutableListOf() } += "${method.substringAfterLast('.')}@$file:$lineNo"
            }
            line.startsWith("Caused by: ") && lastApp >= 0 -> r.traces.getOrPut(lastApp) { mutableListOf() } += "cause: " + line.removePrefix("Caused by: ")
            else -> r.unparsed += (n + 1) to line
        }
    }
    return r
}

fun percentile(xs: List<Int>, p: Int): Int {
    val sorted = xs.sorted()
    val rank = Math.ceil(p / 100.0 * sorted.size).toInt().coerceIn(1, sorted.size)
    return sorted[rank - 1]
}

val sample = """
127.0.0.1 - - [10/Oct/2024:13:55:36 +0000] "GET /api/users/42?verbose=1 HTTP/1.1" 200 2326 12ms
10.0.0.7 - alice [10/Oct/2024:13:55:37 +0000] "POST /api/users HTTP/1.1" 201 512 48ms
10.0.0.7 - alice [10/Oct/2024:13:55:38 +0000] "GET /api/users/7/orders/19 HTTP/2.0" 200 9001 33ms
13:55:39.120 [INFO] app.Server: started port=8080 workers=4 mode="blue green"
13:55:40 [warn] app.Auth: login failed user=bob@example.com token=abc123XYZ attempts=3
192.168.1.20 - - [10/Oct/2024:13:55:41 +0000] "GET /health HTTP/1.1" 204 - 1ms
13:55:42.5 [Error] app.Db${'$'}Pool: query failed sql="select * from \"users\"" elapsed=1500
    at app.Db${'$'}Pool.run(Db.kt:88)
    at app.Service.load(Service.kt:12)
Caused by: java.net.SocketTimeoutException: Read timed out
    at java.net.Socket.read(Socket.java:204)
10.0.0.9 - - [10/Oct/2024:13:55:43 +0000] "DELETE /api/users/42 HTTP/1.1" 500 87 230ms
garbage line with no format
13:55:44 [DEBUG] app.Cache: evicted keys=17 Password=hunter2 contact=Ops.Team+pager@corp.example.org
10.0.0.9 - - [10/Oct/2024:13:55:45 +0000] "GET /api/users/1 HTTP/1.1" 304 0 3ms
13:55:46 [fatal] app.Main: unknown level
    at app.Main.main(Main.kt:1)
""".trimIndent()

fun main() {
    val r = analyze(sample)
    for ((i, e) in r.entries.withIndex()) {
        println("%-12s %-5s %-10s %s".format(e.time, e.level, e.source, e.message))
        if (e.fields.isNotEmpty()) println("    fields " + e.fields.entries.joinToString(", ") { "${it.key}=<${it.value}>" })
        r.traces[i]?.forEach { println("    | $it") }
    }
    println("unparsed: " + r.unparsed.joinToString { "#${it.first} '${it.second.take(20)}'" })
    println("status classes: " + r.statuses.toSortedMap())
    for ((route, ms) in r.latency) {
        println("  %-28s n=%d p50=%d p90=%d max=%d avg=%.1f".format(route, ms.size, percentile(ms, 50), percentile(ms, 90), ms.max(), ms.average()))
    }
    val levels = r.entries.groupingBy { it.level }.eachCount().toList().sortedByDescending { it.second }
    println(levels)

    // splitting and reassembling with regexes
    val csvish = "a, b;c ;; d,e"
    println(csvish.split(Regex("""\s*[,;]\s*""")))
    println(csvish.split(Regex("""\s*[,;]\s*"""), limit = 3))
    println("CamelCaseHTTPServerName".replace(Regex("([a-z])([A-Z])"), "$1 $2").replace(Regex("([A-Z])([A-Z][a-z])"), "$1 $2").split(" "))
    println("one: 1\n  two: 2\nthree 3\nfour:4".lines().mapNotNull { Regex("^\\s*(\\w+):").find(it)?.groupValues?.get(1) })
    println(Regex("(\\d+)-(\\d+)").replace("ranges 1-5, 10-12 and 7-7") { m ->
        val (a, b) = m.destructured.toList().map(String::toInt)
        if (a == b) "$a" else (a..b).joinToString("+")
    })
    println("2024-10-10".replace(Regex("(\\d+)-(\\d+)-(\\d+)"), "$3/$2/$1") + " " + Regex(Regex.escape("a.b*c")).matches("a.b*c"))
    val m = Regex("(\\w+)=?(\\w*)").find("  flag=")!!
    println("${m.range} ${m.groups[1]?.value} '${m.groups[2]?.value}'")
    println(Regex("x*").findAll("axxb").map { "${it.range.first}:${it.value}" }.joinToString(" "))
    println(Regex("[aeiou]", RegexOption.IGNORE_CASE).findAll("Regular EXPRESSIONS").count())
    // a text known only at run time is matched literally with Regex.fromLiteral
    for (needle in listOf("(unclosed", "[a-", "a|b", "ok+")) {
        println("literal $needle: ${Regex.fromLiteral(needle).containsMatchIn("x (unclosed a|b [a-")}")
    }
}
