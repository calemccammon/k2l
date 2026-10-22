// Text utilities: word statistics, anagram groups, ciphers, run-length encoding,
// a tiny template engine, word wrapping and a log-line parser.

val TEXT = """
    It was the best of times, it was the worst of times, it was the age of wisdom,
    it was the age of foolishness, it was the epoch of belief, it was the epoch of
    incredulity, it was the season of Light, it was the season of Darkness, it was
    the spring of hope, it was the winter of despair.
""".trimIndent()

fun String.words(): List<String> = split(Regex("[^A-Za-z']+")).filter { it.isNotEmpty() }.map { it.lowercase() }

fun caesar(text: String, shift: Int): String = text.map { c ->
    when (c) {
        in 'a'..'z' -> 'a' + (c - 'a' + shift).mod(26)
        in 'A'..'Z' -> 'A' + (c - 'A' + shift).mod(26)
        else -> c
    }
}.joinToString("")

fun vigenere(text: String, key: String, decrypt: Boolean = false): String {
    var k = 0
    return buildString {
        for (c in text) {
            if (!c.isLetter()) {
                append(c); continue
            }
            val base = if (c.isUpperCase()) 'A' else 'a'
            val shift = key[k++ % key.length].lowercaseChar() - 'a'
            append(base + (c - base + if (decrypt) -shift else shift).mod(26))
        }
    }
}

fun runLength(s: String): String {
    if (s.isEmpty()) return ""
    val sb = StringBuilder()
    var run = 1
    for (i in 1..s.length) {
        if (i < s.length && s[i] == s[i - 1]) {
            run++
        } else {
            if (run > 1) sb.append(run)
            sb.append(s[i - 1])
            run = 1
        }
    }
    return sb.toString()
}

fun unRunLength(s: String): String = Regex("""(\d*)(\D)""").findAll(s).joinToString("") { m ->
    val (count, ch) = m.destructured
    ch.repeat(count.ifEmpty { "1" }.toInt())
}

fun isPalindrome(s: String): Boolean {
    val cleaned = s.filter { it.isLetterOrDigit() }.lowercase()
    return cleaned == cleaned.reversed()
}

fun longestPalindrome(s: String): String {
    var best = ""
    for (center in 0 until 2 * s.length - 1) {
        var lo = center / 2
        var hi = lo + center % 2
        while (lo >= 0 && hi < s.length && s[lo] == s[hi]) {
            lo--; hi++
        }
        val candidate = s.substring(lo + 1, hi)
        if (candidate.length > best.length) best = candidate
    }
    return best
}

fun wrap(text: String, width: Int): List<String> {
    val lines = mutableListOf<String>()
    val line = StringBuilder()
    for (word in text.split(Regex("\\s+"))) {
        if (line.isNotEmpty() && line.length + 1 + word.length > width) {
            lines += line.toString()
            line.clear()
        }
        if (line.isNotEmpty()) line.append(' ')
        line.append(word)
    }
    if (line.isNotEmpty()) lines += line.toString()
    return lines
}

fun justify(line: String, width: Int): String {
    val words = line.split(' ')
    if (words.size == 1) return line.padEnd(width)
    val gaps = words.size - 1
    val spaces = width - words.sumOf { it.length }
    return words.mapIndexed { i, w ->
        if (i == gaps) w else w + " ".repeat(spaces / gaps + if (i < spaces % gaps) 1 else 0)
    }.joinToString("")
}

fun render(template: String, values: Map<String, Any?>): String =
    Regex("""\{\{\s*(\w+)\|?(\w*)\s*}}""").replace(template) { m ->
        val (name, filter) = m.destructured
        val value = values[name]?.toString() ?: "<$name?>"
        when (filter) {
            "" -> value
            "upper" -> value.uppercase()
            "title" -> value.split(' ').joinToString(" ") { w -> w.replaceFirstChar { it.titlecase() } }
            "len" -> value.length.toString()
            else -> throw IllegalArgumentException("unknown filter '$filter'")
        }
    }

data class LogEntry(val time: String, val level: String, val component: String, val message: String)

val LOG = """
    2024-05-01T10:00:01 INFO  [db] connection pool started (size=10)
    2024-05-01T10:00:02 WARN  [http] slow request: GET /api/items took 1532ms
    2024-05-01T10:00:05 ERROR [db] query failed: timeout after 3000ms
    garbage line without structure
    2024-05-01T10:00:07 INFO  [http] GET /api/items 200 in 87ms
    2024-05-01T10:00:09 ERROR [auth] invalid token for user=alice
    2024-05-01T10:00:12 INFO  [http] POST /api/orders 201 in 143ms
"""

fun parseLog(text: String): Pair<List<LogEntry>, Int> {
    val re = Regex("""^(\S+)\s+([A-Z]+)\s+\[(\w+)]\s+(.*)$""")
    val levels = setOf("INFO", "WARN", "ERROR")
    var bad = 0
    val entries = text.trimIndent().lines().filter(String::isNotBlank).mapNotNull { line ->
        re.matchEntire(line)?.groupValues?.takeIf { it[2] in levels }?.let { (_, t, l, c, m) -> LogEntry(t, l, c, m) } ?: run { bad++; null }
    }
    return entries to bad
}

fun main() {
    val words = TEXT.words()
    println("words=${words.size} distinct=${words.toSet().size} chars=${TEXT.length} lines=${TEXT.lines().size}")
    val freq = words.groupingBy { it }.eachCount()
    val top = freq.entries.sortedWith(compareByDescending<Map.Entry<String, Int>> { it.value }.thenBy { it.key }).take(5)
    println("top: ${top.joinToString { "${it.key}=${it.value}" }}")
    println("longest words: ${words.distinct().sortedByDescending { it.length }.take(3)}")
    println("by length: ${words.distinct().groupBy { it.length }.toSortedMap().mapValues { it.value.size }}")
    println("letters: ${TEXT.lowercase().filter { it.isLetter() }.groupingBy { it }.eachCount().entries.sortedByDescending { it.value }.take(4).map { "${it.key}:${it.value}" }}")
    println("capitalized: ${Regex("\\b[A-Z]\\w*").findAll(TEXT).map { it.value }.toList()}")
    println("sentence case: ${TEXT.lines().first().split(", ").map { it.replaceFirstChar(Char::uppercase) }}")

    val list = listOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog")
    val anagrams = list.groupBy { it.toCharArray().sorted().joinToString("") }.values.filter { it.size > 1 }
    println("anagrams: $anagrams")

    val secret = caesar("Hello, World! xyz", 3)
    println("caesar: $secret -> ${caesar(secret, -3)}")
    val v = vigenere("Attack at dawn!", "Lemon")
    println("vigenere: $v -> ${vigenere(v, "Lemon", decrypt = true)}")
    println("rot13 twice: ${caesar(caesar("Why did the chicken cross the road?", 13), 13)}")

    for (s in listOf("WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW", "abc", "aabcccccaaa", "")) {
        val enc = runLength(s)
        check(unRunLength(enc) == s) { "round trip failed for $s" }
        println("rle: '${s.take(12)}${if (s.length > 12) "…" else ""}' -> '$enc'")
    }

    val phrases = listOf("A man, a plan, a canal: Panama", "race a car", "No 'x' in Nixon", "Was it a car or a cat I saw?")
    phrases.forEach { println("palindrome? ${isPalindrome(it).toString().padEnd(5)} $it") }
    println("longest palindromes: ${listOf("babad", "cbbd", "forgeeksskeegfor", "abacdfgdcaba").map(::longestPalindrome)}")

    val lines = wrap(TEXT.replace('\n', ' '), 36)
    lines.forEachIndexed { i, l -> println("|${if (i == lines.lastIndex) l.padEnd(36) else justify(l, 36)}|") }

    val tpl = "Dear {{ name|title }}, your order #{{id}} of {{ count }} {{item|upper}} ships {{when}}. ({{name|len}})"
    println(render(tpl, mapOf("name" to "ada lovelace", "id" to 1042, "count" to 3, "item" to "widgets", "when" to null)))
    println(runCatching { render("{{x|bogus}}", mapOf("x" to 1)) }.exceptionOrNull()?.message)

    val (entries, bad) = parseLog(LOG)
    println("log: ${entries.size} entries, $bad malformed")
    println("levels: ${entries.groupingBy { it.level }.eachCount()}")
    val durations = entries.mapNotNull { Regex("""(\d+)ms""").find(it.message)?.groupValues?.get(1)?.toInt() }
    println("durations: $durations avg=${"%.1f".format(durations.average())}")
    entries.filter { it.level == "ERROR" }.forEach { (time, _, comp, msg) -> println("  ${time.substringAfter('T')} $comp: ${msg.substringBefore(':')}") }
    val paths = entries.flatMap { Regex("""([A-Z]+) (\S+)""").findAll(it.message).filter { m -> m.groupValues[1] in setOf("GET", "POST") }.map { m -> m.groupValues[2] }.toList() }
    println("paths: ${paths.distinct()} kv: ${Regex("(\\w+)=(\\w+)").findAll(LOG).associate { it.groupValues[1] to it.groupValues[2] }}")
    println("snake: ${"parseHttpResponseCode".replace(Regex("([a-z])([A-Z])"), "$1_$2").lowercase()} camel: ${"max_retry_count".split('_').mapIndexed { i, p -> if (i == 0) p else p.replaceFirstChar { it.uppercase() } }.joinToString("")}")
    println("chars: ${"Hello".map { it.code }} ${"Kotlin".withIndex().filter { it.index % 2 == 0 }.map { it.value }} ${"a-b-c".split("-", limit = 2)}")
}
