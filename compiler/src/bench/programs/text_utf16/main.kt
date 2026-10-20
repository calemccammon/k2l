// Adapted from realworld_text_unicode, compiled with --strings utf16: text with accents, CJK and emoji processed by
// UTF-16 code units and code points (length, indexing, substring, codePointAt, case mapping, reversing, slugs,
// StringBuilder edits and word counts).

const val SIZE = 6_000 // sentences

val FOLD = mapOf('à' to "a", 'á' to "a", 'ä' to "ae", 'ç' to "c", 'è' to "e", 'é' to "e", 'ê' to "e", 'ñ' to "n", 'ö' to "oe", 'ü' to "ue", 'ß' to "ss")

val WORDS = listOf("crème", "brûlée", "straße", "größe", "łódź", "naïve", "café", "déjà", "東京", "タワー", "Ελληνικά", "🌙", "👩‍💻", "kotlin", "lua", "ÜBER", "smörgåsbord")

fun slugify(s: String): String = buildString {
    for (c in s.lowercase()) {
        when {
            c in FOLD -> append(FOLD.getValue(c))
            c in 'a'..'z' || c in '0'..'9' -> append(c)
            c.isLetterOrDigit() -> append("-u").append(c.code.toString(16)).append('-')
            else -> if (isNotEmpty() && last() != '-') append('-')
        }
    }
}.trim('-')

fun displayWidth(s: String): Int {
    var width = 0
    var i = 0
    while (i < s.length) {
        val cp = s.codePointAt(i)
        width += when {
            cp in 0x2E80..0xA4CF || cp in 0xAC00..0xD7A3 || cp in 0xFF00..0xFF60 -> 2
            cp in 0x1F300..0x1FAFF -> 2
            cp in 0x0300..0x036F -> 0
            else -> 1
        }
        i += Character.charCount(cp)
    }
    return width
}

fun truncate(s: String, max: Int): String {
    if (s.codePointCount(0, s.length) <= max) return s
    return s.substring(0, s.offsetByCodePoints(0, max - 1)) + "…"
}

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

fun main() {
    val rng = Lcg(17)
    val sentences = List(SIZE) { List(4 + rng.next(8)) { WORDS[rng.next(WORDS.size)] }.joinToString(" ") }
    var units = 0L
    var width = 0L
    var letters = 0L
    var slugLength = 0L
    var surrogates = 0
    for (s in sentences) {
        units += s.length
        width += displayWidth(truncate(s, 20))
        letters += s.count { it.isLetter() }
        surrogates += s.count { it.isSurrogate() }
        slugLength += slugify(s).length
    }
    println("units $units width $width letters $letters surrogates $surrogates slugs $slugLength")

    var caseChecksum = 0L
    for (s in sentences.take(SIZE / 2)) {
        val up = s.uppercase()
        val low = s.lowercase()
        caseChecksum += up.length * 3 + low.length + (if (up.equals(low, ignoreCase = true)) 1 else 0) + s.indexOf("é") + s.lastIndexOf(' ')
        caseChecksum += s.reversed().length + s.substring(s.length / 3, s.length / 2).length + s[s.length / 2].code % 7
    }
    println("case $caseChecksum")

    val sb = StringBuilder()
    for (i in 0 until SIZE) {
        sb.append(WORDS[i % WORDS.size]).append(' ')
        if (i % 10 == 9) {
            sb.insert(sb.length / 2, "→")
            sb.deleteCharAt(0)
            sb.setCharAt(sb.length - 1, '·')
        }
        if (sb.length > 300) sb.setLength(100)
    }
    println("builder ${sb.length} ${sb.toString().codePointCount(0, sb.length)}")

    val freq = sentences.flatMap { it.split(' ') }.groupingBy { it.lowercase() }.eachCount()
    println(freq.entries.sortedWith(compareByDescending<Map.Entry<String, Int>> { it.value }.thenBy { it.key }).take(5).joinToString { "${it.key}=${it.value}" })
}
