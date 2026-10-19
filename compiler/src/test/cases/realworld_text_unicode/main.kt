import kotlin.math.sign

// Unicode-aware text processing (compiled with --strings utf16): grapheme-ish truncation that keeps surrogate
// pairs, case mapping beyond ASCII, slugs with diacritics folded by a table, code point statistics, a
// StringBuilder editor working on code units, display widths for CJK, and a word frequency count for accented text.

val FOLD = mapOf(
    'à' to "a", 'á' to "a", 'â' to "a", 'ä' to "ae", 'å' to "a", 'ç' to "c", 'è' to "e", 'é' to "e", 'ê' to "e", 'ë' to "e",
    'í' to "i", 'î' to "i", 'ï' to "i", 'ñ' to "n", 'ó' to "o", 'ô' to "o", 'ö' to "oe", 'ø' to "o", 'ú' to "u", 'ü' to "ue",
    'ß' to "ss", 'œ' to "oe", 'æ' to "ae", 'ł' to "l", 'ś' to "s", 'ż' to "z", 'ź' to "z", 'č' to "c", 'ř' to "r", 'š' to "s",
)

fun slugify(s: String): String = buildString {
    for (c in s.lowercase()) {
        when {
            c in FOLD -> append(FOLD.getValue(c))
            c in 'a'..'z' || c in '0'..'9' -> append(c)
            c.isLetterOrDigit() -> append("-u").append(c.code.toString(16)).append('-')
            else -> if (isNotEmpty() && last() != '-') append('-')
        }
    }
}.trim('-').replace(Regex("-{2,}"), "-")

/** Truncates to at most [max] code points, never splitting a surrogate pair, adding an ellipsis when cut. */
fun truncate(s: String, max: Int): String {
    if (s.codePointCount(0, s.length) <= max) return s
    val end = s.offsetByCodePoints(0, max - 1)
    return s.substring(0, end) + "…"
}

fun displayWidth(s: String): Int {
    var width = 0
    var i = 0
    while (i < s.length) {
        val cp = s.codePointAt(i)
        width += when {
            cp in 0x1100..0x115F || cp in 0x2E80..0xA4CF || cp in 0xAC00..0xD7A3 || cp in 0xF900..0xFAFF || cp in 0xFF00..0xFF60 -> 2
            cp in 0x1F300..0x1FAFF -> 2
            cp in 0x0300..0x036F -> 0
            else -> 1
        }
        i += Character.charCount(cp)
    }
    return width
}

fun padDisplay(s: String, width: Int) = s + " ".repeat((width - displayWidth(s)).coerceAtLeast(0))

fun describe(s: String): String {
    val letters = s.count { it.isLetter() }
    val upper = s.count { it.isUpperCase() }
    val digits = s.count { it.isDigit() }
    val spaces = s.count { it.isWhitespace() }
    val surrogates = s.count { it.isSurrogate() }
    val cps = s.codePointCount(0, s.length)
    return "len=${s.length} cps=$cps letters=$letters upper=$upper digits=$digits spaces=$spaces surrogates=$surrogates"
}

fun main() {
    val titles = listOf(
        "Crème brûlée à la française",
        "Straße & Größe: Ärger über Öl",
        "Łódź, Kraków — Gdańsk!",
        "naïve café déjà vu 2024",
        "Smörgåsbord för 4 personer",
        "東京タワー 2024 🗼",
        "Ελληνικά κείμενα",
        "  Ünïcödé   spaces\t\ttabs  ",
    )
    for (t in titles) {
        println("${padDisplay(truncate(t, 18), 34)}|${slugify(t)}")
    }
    println()
    for (t in titles.take(4) + titles[6]) {
        println("${t.uppercase()} / ${t.lowercase()} / ${t.split(' ').joinToString(" ") { w -> w.replaceFirstChar { it.titlecase() } }}")
    }
    println("ß".uppercase() + " " + "ǆ".uppercase() + " " + 'ǆ'.titlecase() + " " + "İstanbul".lowercase().length + " " + "ΣΊΣΥΦΟΣ".lowercase())
    println()

    val emoji = "I ❤️ Kotlin 🎉🎉 and Lua 🌙! 👩‍💻"
    println(describe(emoji))
    println(describe(titles[5]))
    println(truncate(emoji, 12) + " | " + truncate(emoji, 15) + " | " + emoji.reversed())
    val cps = emoji.codePoints().toArray()
    println(cps.filter { it > 0xFFFF }.joinToString(" ") { "U+" + it.toString(16).uppercase() })
    println(cps.count { Character.isLetter(it) }.toString() + " letters by code point, " + emoji.length + " units")

    val sb = StringBuilder("héllo wörld")
    sb.setCharAt(0, 'H')
    sb.insert(6, "schöne ")
    sb.appendCodePoint(0x1F30D)
    sb.deleteCharAt(sb.indexOf("ö"))
    sb.replace(sb.indexOf("w"), sb.indexOf("w") + 1, "W")
    println("$sb (${sb.length} units, last cp ${Integer.toHexString(sb.codePointBefore(sb.length))})")
    sb.reverse()
    println(sb)

    val text = """
        Le cœur a ses raisons que la raison ne connaît point. Où est la cathédrale? À côté du café!
        L'été, l'été: déjà fini; ÉTÉ, Été — été.
    """.trimIndent()
    val words = Regex("[\\p{L}']+").findAll(text).map { it.value.lowercase() }.toList()
    val freq = words.groupingBy { it }.eachCount().entries.sortedWith(compareByDescending<Map.Entry<String, Int>> { it.value }.thenBy { it.key })
    println(freq.take(6).joinToString { "${it.key}=${it.value}" })
    println(words.filter { w -> w.any { it.code > 127 } }.distinct().sorted())
    println(words.map { it.length }.sum().toString() + " letters in " + words.size + " words; longest: " + words.maxBy { it.length })
    println("éa".compareTo("ez").sign.toString() + " " + listOf("zebra", "Äpfel", "apple", "École", "eclair").sorted() + " " +
        listOf("zebra", "Äpfel", "apple", "École", "eclair").sortedWith(String.CASE_INSENSITIVE_ORDER))
    println("Ǆemal".equals("ǆemal", ignoreCase = true).toString() + " " + "STRASSE".equals("straße", ignoreCase = true) + " " +
        "ÀB".contains("àb", ignoreCase = true) + " " + "Größe".indexOf("ö") + " " + "Größe".padStart(8, '·') + " " + "x".padEnd(3, 'é') + "|")
}
