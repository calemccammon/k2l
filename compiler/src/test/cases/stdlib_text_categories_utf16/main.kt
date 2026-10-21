// Char.category, CharCategory and the predicates derived from it, on Unicode characters (--strings utf16)
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun main() {
    val samples = "Aa1 é Σ ǅ ٣ € « » ½ ʰ 中 Ⅻ ́ ⃝ ः ­      ͸ \u0085 ￿"
    for (c in samples.filter { it != ' ' }) {
        val cat = c.category
        println("U+${c.code.toString(16).padStart(4, '0')} $cat ${cat.code} ${cat.value} defined=${c.isDefined()} title=${c.isTitleCase()}")
    }
    t("surrogate") { listOf('\uD83D'.category, '\uDE00'.category, '\uD83D'.isSurrogate(), '\uDE00'.isLowSurrogate()) }
    t("pair") { "😀".map { "${it.isHighSurrogate()}/${it.isLowSurrogate()}/${it.isSurrogate()}" } }
    t("titlecase") { listOf('ǆ'.titlecaseChar(), 'ǆ'.titlecase(), 'ǅ'.isTitleCase(), 'ß'.titlecase(), 'a'.titlecase()) }
    t("contains") { listOf('é' in CharCategory.LOWERCASE_LETTER, '中' in CharCategory.OTHER_LETTER, '€' in CharCategory.MATH_SYMBOL) }
    t("identifier") { "é€_٣­́·".map { "${it.isJavaIdentifierStart()}/${it.isJavaIdentifierPart()}/${it.isIdentifierIgnorable()}" } }
    t("count by category") {
        (0x370 until 0x400).map { it.toChar() }.groupingBy { it.category.code }.eachCount().toSortedMap()
    }
    t("defined in Greek") { (0x370 until 0x400).count { it.toChar().isDefined() } }
}
