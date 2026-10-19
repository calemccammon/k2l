// Regex Unicode properties with --strings utf16: \p{L}, \p{Lu}, \p{Ll}, \p{Lt}, \p{N}, \p{Nd}, \p{M}, \p{Z},
// \p{IsWhite_Space}, \p{javaWhitespace}, negations and classes containing them, next to the ASCII-only POSIX classes.

fun show(pattern: String, text: String) {
    val r = Regex(pattern)
    println("%-22s %s".format(pattern, r.findAll(text).map { it.value }.joinToString("|", "[", "]")))
}

fun main() {
    val text = "Ça coûte 12€ — ǅemal Ünal, ΣΊΣΥΦΟΣ ١٢٣ x́ a\tb c d"
    for (p in listOf("\\p{L}+", "\\p{Lu}", "\\p{Ll}+", "\\p{Lt}", "\\p{N}+", "\\p{Nd}+", "\\p{IsDigit}+", "\\p{M}", "\\p{IsLetter}+",
        "\\p{javaUpperCase}", "\\p{Alpha}+", "\\p{Upper}", "\\p{Digit}+", "[\\p{L}\\p{M}]+", "[^\\p{L}\\s]+", "\\P{L}+",
        "[\\p{Lu}\\d]+", "\\p{IsAlphabetic}{3,}", "\\p{javaLetterOrDigit}+", "[\\P{L}&&[^ ]]")) {
        try {
            show(p, text)
        } catch (e: Exception) {
            println("%-22s %s".format(p, e::class.simpleName))
        }
    }
    val spaces = "a b\tc d e f\u0085g"
    for (p in listOf("\\p{Z}", "\\p{Zs}", "\\p{IsWhite_Space}", "\\p{javaWhitespace}", "\\s", "\\p{Space}")) {
        println("%-22s %s".format(p, Regex(p).findAll(spaces).map { "%04X".format(it.value[0].code) }.toList()))
    }
    val dynamic = "\\p{" + "Lu" + "}"
    println(Regex(dynamic).findAll("ÀbÇdÉ").map { it.value }.toList() + " " + "\\p{Ll}+".toRegex().replace("ÀbcÇdé", "_"))
    println(Regex("\\b\\p{Lu}\\p{Ll}+").findAll("Ärger über Öl und Ébène").map { it.value }.toList())
    println("Größe 12 straße".split(Regex("\\P{L}+")) + " " + Regex("^\\p{Lu}").containsMatchIn("Éclair"))
    println(Regex("[\\p{L}&&[^aeiou]]+").findAll("crème brûlée").map { it.value }.toList())
}
