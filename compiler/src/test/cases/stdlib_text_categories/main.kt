// Char.category and CharCategory, and the Char predicates derived from the general category (ASCII characters)
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

fun describe(c: Char): String {
    val cat = c.category
    return "${c.code}:${cat}/${cat.code}/${cat.value}"
}

fun kind(c: Char): String = when (c.category) {
    CharCategory.UPPERCASE_LETTER, CharCategory.LOWERCASE_LETTER -> "letter"
    CharCategory.DECIMAL_DIGIT_NUMBER -> "digit"
    CharCategory.SPACE_SEPARATOR, CharCategory.CONTROL -> "blank"
    CharCategory.MATH_SYMBOL, CharCategory.CURRENCY_SYMBOL, CharCategory.MODIFIER_SYMBOL -> "symbol"
    else -> "punctuation"
}

fun main() {
    // every ASCII character's category
    val all = (0 until 128).map { it.toChar() }
    t("ascii") { all.groupBy({ it.category }, { it.code }).mapValues { (_, codes) -> codes.size } }
    t("printable") { (32 until 127).map { it.toChar() }.joinToString(" ") { "${it}${it.category.code}" } }
    t("describe") { listOf('A', 'z', '5', ' ', '\n', '$', '_', '(', ')', '-', '+', '^', '~', '\u007f').map(::describe) }
    t("kinds") { "Hi, 42 + \$5^2!".map(::kind) }

    // CharCategory members
    t("entries") { CharCategory.entries.size }
    t("first entries") { CharCategory.entries.take(5) }
    t("values") { CharCategory.values().map { it.code }.joinToString(",") }
    t("value numbers") { CharCategory.entries.map { it.value } }
    t("ordinals") { CharCategory.entries.map { it.ordinal }.sum() }
    t("valueOf") { CharCategory.valueOf("MATH_SYMBOL") }
    t("valueOf bad") { CharCategory.valueOf("NOPE") }
    t("contains") { listOf('a' in CharCategory.LOWERCASE_LETTER, 'A' in CharCategory.LOWERCASE_LETTER, '7' in CharCategory.DECIMAL_DIGIT_NUMBER) }
    t("compare") { listOf(CharCategory.CONTROL > CharCategory.UPPERCASE_LETTER, CharCategory.FORMAT.compareTo(CharCategory.CONTROL)) }
    t("name") { CharCategory.CURRENCY_SYMBOL.name + "/" + CharCategory.CURRENCY_SYMBOL.ordinal }
    t("set") { "aA1 a".map { it.category }.toSet() }

    // predicates
    t("isDefined") { all.count { it.isDefined() } }
    t("isTitleCase") { all.count { it.isTitleCase() } }
    t("titlecase") { listOf('a'.titlecase(), 'Z'.titlecaseChar(), '1'.titlecaseChar()) }
    t("surrogates") { all.count { it.isSurrogate() || it.isHighSurrogate() || it.isLowSurrogate() } }
    t("identifier start") { all.filter { it.isJavaIdentifierStart() }.size }
    t("identifier part") { all.filter { it.isJavaIdentifierPart() }.size }
    t("identifier ignorable") { all.filter { it.isIdentifierIgnorable() }.map { it.code } }
    t("identifier chars") { "a_1\$-".map { "${it.isJavaIdentifierStart()}/${it.isJavaIdentifierPart()}" } }
}
