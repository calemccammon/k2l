// A regex-heavy log analyzer: parses access and application logs with named groups, redacts secrets with
// lambdas, aggregates by status/endpoint/hour, detects anomalies and renders a report.

val ACCESS = Regex(
    """^(?<ip>\d{1,3}(?:\.\d{1,3}){3}) - (?<user>\S+) \[(?<day>\d{2})/(?<mon>\w{3})/(?<year>\d{4}):(?<h>\d{2}):(?<m>\d{2}):(?<s>\d{2}) (?<tz>[+-]\d{4})] "(?<method>[A-Z]+) (?<path>[^ ?"]+)(?:\?(?<query>[^ "]*))? HTTP/(?<ver>[\d.]+)" (?<status>\d{3}) (?<bytes>\d+|-)(?: (?<ms>\d+)ms)?$""",
)
val APP = Regex("""^(?<ts>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z?)\s+(?<level>TRACE|DEBUG|INFO|WARN|ERROR)\s+\[(?<thread>[^\]]+)]\s+(?<logger>[\w.$]+)\s+-\s+(?<msg>.*)$""")

val LOG = """
192.168.1.10 - alice [12/Mar/2024:09:15:02 +0000] "GET /api/users?id=42&token=abc123 HTTP/1.1" 200 512 12ms
10.0.0.7 - - [12/Mar/2024:09:15:09 +0000] "POST /api/login HTTP/1.1" 401 87 140ms
10.0.0.7 - - [12/Mar/2024:09:16:11 +0000] "POST /api/login HTTP/1.1" 401 87 133ms
10.0.0.7 - - [12/Mar/2024:09:16:40 +0000] "POST /api/login HTTP/1.1" 200 1024 98ms
2024-03-12T09:16:41.123Z INFO  [http-nio-8080-exec-3] com.example.auth.LoginService - user bob logged in from 10.0.0.7 password=hunter2
172.16.0.3 - carol [12/Mar/2024:10:01:00 +0000] "GET /static/app.js HTTP/2.0" 304 - 3ms
172.16.0.3 - carol [12/Mar/2024:10:01:01 +0000] "GET /static/app.css HTTP/2.0" 304 -
garbage line that matches nothing
2024-03-12T10:02:00Z WARN  [scheduler-1] com.example.jobs.Cleanup${"$"}Worker - slow query took 2350ms: SELECT * FROM t WHERE email='dave@example.com'
192.168.1.10 - alice [12/Mar/2024:10:30:59 +0000] "DELETE /api/users/42 HTTP/1.1" 500 0 2012ms
2024-03-12T10:31:00Z ERROR [http-nio-8080-exec-1] com.example.api.UserController - failed to delete user 42: java.sql.SQLException: lock timeout (card 4111-1111-1111-1111)
192.168.1.11 - alice [12/Mar/2024:11:05:00 +0000] "GET /api/users?id=7&api_key=XYZ987&page=2 HTTP/1.1" 200 2048 25ms
2024-03-12T11:05:01.5Z DEBUG [main] com.example.Cache - hit ratio 0.875 for key users:7
""".trimIndent()

data class Access(val ip: String, val user: String?, val hour: Int, val method: String, val path: String, val query: Map<String, String>,
    val status: Int, val bytes: Long, val ms: Int?)

fun parseQuery(q: String?): Map<String, String> =
    q?.split('&')?.filter { it.isNotEmpty() }?.associate { kv -> kv.substringBefore('=') to kv.substringAfter('=', "") } ?: emptyMap()

val SECRET_PARAM = Regex("(?i)(token|api_key|password)=([^&\\s]+)")
val EMAIL = Regex("""\b([\w.+-]+)@([\w-]+\.[\w.]+)\b""")
val CARD = Regex("""\b(?:\d{4}-){3}(\d{4})\b""")

fun redact(s: String): String {
    var out = SECRET_PARAM.replace(s) { m -> "${m.groupValues[1]}=" + "*".repeat(m.groupValues[2].length.coerceAtMost(6)) }
    out = EMAIL.replace(out) { m -> m.groupValues[1].first() + "***@" + m.groupValues[2] }
    out = CARD.replace(out, "****-****-****-$1")
    return out
}

fun main() {
    val accesses = mutableListOf<Access>()
    val apps = mutableListOf<MatchResult>()
    val rejected = mutableListOf<Int>()
    LOG.lineSequence().forEachIndexed { n, line ->
        val a = ACCESS.matchEntire(line)
        val p = if (a == null) APP.find(line) else null
        when {
            a != null -> {
                val g = a.groups
                accesses += Access(
                    ip = g["ip"]!!.value,
                    user = g["user"]!!.value.takeUnless { it == "-" },
                    hour = g["h"]!!.value.toInt(),
                    method = g["method"]!!.value,
                    path = g["path"]!!.value,
                    query = parseQuery(g["query"]?.value),
                    status = g["status"]!!.value.toInt(),
                    bytes = g["bytes"]!!.value.toLongOrNull() ?: 0L,
                    ms = g["ms"]?.value?.toInt(),
                )
            }
            p != null -> apps += p
            else -> rejected += n + 1
        }
    }
    println("parsed ${accesses.size} access lines, ${apps.size} app lines, rejected lines $rejected")

    val first = ACCESS.find(LOG.lines()[0])!!
    println("named groups of line 1: " + listOf("ip", "user", "mon", "tz", "method", "path", "query", "ver", "ms").joinToString { "$it=${first.groups[it]?.value}" })
    println("group 0 range ${first.range}, path range ${first.groups["path"]?.range}")

    println("-- by status --")
    accesses.groupingBy { it.status / 100 }.eachCount().toSortedMap().forEach { (k, v) -> println("${k}xx: $v") }
    println("-- by endpoint (ids collapsed) --")
    val endpoint = Regex("/\\d+(?=/|$)")
    accesses.groupBy { "${it.method} " + endpoint.replace(it.path, "/{id}") }
        .mapValues { (_, list) -> list.mapNotNull { it.ms } }
        .toSortedMap()
        .forEach { (k, times) ->
            val avg = if (times.isEmpty()) "n/a" else "%.1fms".format(times.average())
            println("%-28s n=%d avg=%s max=%s".format(k, times.size, avg, times.maxOrNull() ?: "-"))
        }
    println("-- per hour --")
    accesses.groupBy { it.hour }.toSortedMap().forEach { (h, l) ->
        println("%02d:00 %s %d bytes".format(h, "#".repeat(l.size), l.sumOf { it.bytes }))
    }
    println("-- query params --")
    accesses.flatMap { it.query.keys }.groupingBy { it }.eachCount().entries.sortedWith(compareBy({ -it.value }, { it.key }))
        .forEach { println("${it.key}: ${it.value}") }

    println("-- brute force suspects --")
    accesses.filter { it.path.endsWith("/login") }.groupBy { it.ip }.forEach { (ip, l) ->
        val fails = l.count { it.status == 401 }
        if (fails >= 2) println("$ip failed $fails times, then ${if (l.last().status == 200) "succeeded" else "gave up"}")
    }

    println("-- application log --")
    for (m in apps) {
        val logger = m.groups["logger"]!!.value
        val short = logger.split('.').let { parts -> parts.dropLast(1).joinToString(".") { it.take(1) } + "." + parts.last() }
        val (ts, level) = m.destructured
        val time = Regex("T(\\d{2}:\\d{2}:\\d{2})").find(ts)!!.groupValues[1]
        println("$time ${level.padEnd(5)} ${short.substringAfter('$', short)} ${redact(m.groups["msg"]!!.value)}")
    }
    val durations = Regex("(\\d+)ms").findAll(LOG).map { it.groupValues[1].toInt() }.toList()
    println("all durations: $durations, slow (>1s): ${durations.filter { it > 1000 }}")

    println("-- redaction --")
    for (line in LOG.lines().filter { SECRET_PARAM.containsMatchIn(it) || EMAIL.containsMatchIn(it) || CARD.containsMatchIn(it) }) {
        println(redact(line).take(110))
    }

    println("-- misc regex --")
    val words = Regex("[\\s,;]+").split("alpha, beta;gamma  delta,,epsilon")
    println(words)
    println("a1b22c333".split(Regex("\\d+"), limit = 3))
    println(Regex("(?<=@)\\w+").findAll("x@foo y@bar z@").map { it.value }.toList())
    println(Regex("\\b\\w+(?!\\w|-)").findAll("well-known self-made easy").map { it.value }.joinToString("|"))
    println(Regex("(\\w)\\1").findAll("bookkeeper aardvark").map { it.value + "@" + it.range.first }.toList())
    println("2024-03-12".replace(Regex("(\\d+)-(\\d+)-(\\d+)"), "$3/$2/$1") + " " + "a.b.c".replace(Regex.escape("."), "\\$"))
    println(Regex("^\\w+", RegexOption.MULTILINE).findAll("one two\nthree four\n five").map { it.value }.toList())
    println(Regex("error", RegexOption.IGNORE_CASE).findAll(LOG).count())
    println(Regex("(?<word>[a-z]+)(?<num>\\d*)").replace("abc12 de xyz9") { "${it.groups["num"]!!.value}${it.groups["word"]!!.value.uppercase()}" })
    var m: MatchResult? = Regex("\\d+").find("a1bb22ccc333")
    val seen = mutableListOf<String>()
    while (m != null) {
        seen += "${m.value}@${m.range}"
        m = m.next()
    }
    println(seen)
    println(Regex("x*").replace("abc", "-") + " " + "a,b,,c,".split(",") + " " + "a,b,,c,".split(Regex(",")).size)
    println(Regex("[aeiou]").replaceFirst("programming language", "_") + " " + "Hello World".replace(Regex("(?i)[^aeiou\\s]"), "."))
}
