// Adapted from realworld_text_logs and realworld_csv: generate log lines and CSV rows as text, then parse them back
// with split, substringBefore/After, toInt/toDouble, trim, Regex matching with groups, and replace.

const val SIZE = 12_000 // log lines

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

val LEVELS = listOf("INFO", "WARN", "ERROR", "DEBUG")
val PATHS = listOf("/api/users", "/api/orders", "/static/app.js", "/login", "/api/items/42", "/health")
val LINE = Regex("""^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d) \[(\w+)] (\S+) (GET|POST) (\S+) (\d{3}) (\d+)ms(?: user=(\w+))?$""")

data class Entry(val hour: Int, val level: String, val service: String, val method: String, val path: String, val status: Int, val ms: Int, val user: String?)

fun parse(line: String): Entry? {
    val m = LINE.matchEntire(line) ?: return null
    val g = m.groupValues
    return Entry(g[4].toInt(), g[7], g[8], g[9], g[10], g[11].toInt(), g[12].toInt(), m.groups[13]?.value)
}

fun parseCsvLine(line: String): List<String> {
    val fields = mutableListOf<String>()
    val sb = StringBuilder()
    var quoted = false
    var i = 0
    while (i < line.length) {
        val c = line[i]
        if (quoted) {
            if (c == '"' && i + 1 < line.length && line[i + 1] == '"') {
                sb.append('"')
                i++
            } else if (c == '"') {
                quoted = false
            } else {
                sb.append(c)
            }
        } else if (c == '"') {
            quoted = true
        } else if (c == ',') {
            fields += sb.toString()
            sb.setLength(0)
        } else {
            sb.append(c)
        }
        i++
    }
    fields += sb.toString()
    return fields
}

fun main() {
    val rng = Lcg(31)
    val log = (0 until SIZE).joinToString("\n") {
        val user = if (rng.next(3) == 0) " user=u${rng.next(50)}" else ""
        "2024-03-${(1 + rng.next(28)).toString().padStart(2, '0')} ${rng.next(24).toString().padStart(2, '0')}:" +
            "${rng.next(60).toString().padStart(2, '0')}:${rng.next(60).toString().padStart(2, '0')} [${LEVELS[rng.next(4)]}] " +
            "svc-${rng.next(5)} ${if (rng.next(4) == 0) "POST" else "GET"} ${PATHS[rng.next(PATHS.size)]} " +
            "${listOf(200, 200, 200, 201, 304, 404, 500)[rng.next(7)]} ${rng.next(900)}ms$user"
    }
    val entries = log.lines().mapNotNull(::parse)
    val byStatus = entries.groupingBy { it.status }.eachCount().toSortedMap()
    val slowest = entries.filter { it.level == "ERROR" }.sortedByDescending { it.ms }.take(3).map { "${it.path}:${it.ms}" }
    val users = entries.mapNotNull { it.user }.toSet().size
    val perHour = entries.groupBy { it.hour }.mapValues { (_, list) -> list.sumOf { it.ms } / list.size }
    println("parsed ${entries.size}, statuses $byStatus, users $users")
    println("slowest errors $slowest, busiest hour ${perHour.maxBy { it.value }.key}")

    // Plain string functions on the same text.
    var checksum = 0L
    for (line in log.split('\n')) {
        val level = line.substringAfter('[').substringBefore(']')
        val tail = line.substringAfterLast(' ')
        val ms = if (tail.endsWith("ms")) tail.removeSuffix("ms").toInt() else tail.substringBefore("ms").substringAfterLast(' ').toIntOrNull() ?: 0
        val words = line.split(' ')
        checksum += level.length + ms + words.size + (if (line.contains("/api/")) 1 else 0) + line.indexOf(':')
    }
    println("plain checksum $checksum")

    val csv = (0 until SIZE / 2).joinToString("\n") { i ->
        val name = if (i % 5 == 0) "\"Smith, J${i % 13}\"" else "user$i"
        val note = if (i % 7 == 0) "\"said \"\"hi\"\"\"" else "n/a"
        "$i,$name,${rng.next(100000) / 100.0},$note, ${rng.next(9)} "
    }
    var total = 0.0
    var quotes = 0
    for (row in csv.lines()) {
        val f = parseCsvLine(row)
        total += f[2].toDouble() + f[4].trim().toInt()
        quotes += f[3].count { it == '"' } + if (',' in f[1]) 1 else 0
    }
    val normalized = csv.replace(",n/a,", ",-,").replace(Regex("\\s+"), " ").length
    println("csv total ${"%.2f".format(total)}, quotes $quotes, normalized $normalized")
}
