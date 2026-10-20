// With --strings utf16 the regex categories (\p{Lu}, \p{Nd}, \P{L}, ...) test non-ASCII characters, supplementary ones
// included, by the general categories of the JDK the tables were generated from (UnicodeCategories.lua).

val CATEGORIES = listOf(
    "Lu", "Ll", "Lt", "Lm", "Lo", "Mn", "Mc", "Me", "Nd", "Nl", "No", "Zs", "Zl", "Zp", "Cc", "Cf", "Co", "Cn",
    "Pd", "Ps", "Pe", "Pc", "Po", "Pi", "Pf", "Sm", "Sc", "Sk", "So", "L", "LC", "M", "N", "P", "S", "Z", "C",
)

// every 7th code point from U+0080 to U+2FFFF (no surrogates), and the planes 14 to 16 more sparsely
val SAMPLE: String = buildString {
    var cp = 0x80
    while (cp < 0x110000) {
        if (cp !in 0xD800..0xDFFF) appendCodePoint(cp)
        cp += if (cp < 0x30000) 7 else 4099
    }
}

fun summary(regex: Regex): String {
    var count = 0
    var sum = 0L
    for (m in regex.findAll(SAMPLE)) {
        count++
        sum = (sum * 31 + m.value.hashCode()) % 1_000_000_007L
    }
    return "$count $sum"
}

fun main() {
    for (name in CATEGORIES) {
        println("${name.padEnd(3)} ${summary(Regex("\\p{$name}"))}")
    }
    for (form in listOf("\\P{L}", "\\p{IsLu}", "\\p{gc=Nl}", "[\\p{Lu}\\p{Lt}]", "[^\\p{L}\\p{N}\\p{Cn}]", "(?i)\\p{Lt}", "\\pM")) {
        println("${form.padEnd(22)} ${summary(Regex(form))}")
    }
    val text = "Ⓐ ⓑ Ǆemal ǅuro: Ⅻ ½ ٣ ʰ 中 é ́ ‿ « » ‹ › ‐ ¢ ˆ ⊕ ©   ­  𝐀 𐍁 😀"
    for (name in listOf("Lu", "Ll", "Lt", "Lm", "Lo", "Nl", "No", "Nd", "Mn", "Pc", "Pi", "Pf", "Pd", "Sc", "Sk", "Sm", "So", "Zl", "Cf", "Co")) {
        println("$name: " + Regex("\\p{$name}").findAll(text).map { it.value }.joinToString(" "))
    }
    println(text.replace(Regex("[\\p{Z}\\p{P}]+"), "|"))
    println(Regex("\\p{Lu}\\p{Ll}*").findAll("Ἀθῆναι Ελλάδα Ärger Öl").map { it.value }.toList())
}
