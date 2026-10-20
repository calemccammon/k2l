// The Unicode general categories in regexes (\p{Lu}, \p{IsLu}, \p{gc=Lu}, \P{..}, groups such as \p{L}), on ASCII text:
// in the default bytes mode non-ASCII characters are in no category (see regex_categories_utf16).

val CATEGORIES = listOf(
    "Lu", "Ll", "Lt", "Lm", "Lo", "Mn", "Mc", "Me", "Nd", "Nl", "No", "Zs", "Zl", "Zp", "Cc", "Cf", "Co", "Cs", "Cn",
    "Pd", "Ps", "Pe", "Pc", "Po", "Pi", "Pf", "Sm", "Sc", "Sk", "So", "L", "LC", "M", "N", "P", "S", "Z", "C",
)

val ASCII = (0 until 128).map { it.toChar() }.joinToString("")

fun members(regex: Regex): String = ASCII.filter { regex.matches(it.toString()) }
    .map { if (it < ' ') "^" + (it.code + 64).toChar() else if (it == '\u007f') "DEL" else it.toString() }.joinToString("")

fun main() {
    for (name in CATEGORIES) {
        println("${name.padEnd(3)} ${members(Regex("\\p{$name}"))}")
    }
    // the other spellings Java accepts, and negation
    val forms = listOf(
        "\\p{IsLu}", "\\p{gc=Lu}", "\\p{general_category=Nd}", "\\p{GC=Ps}", "\\pL", "\\pN", "\\P{L}", "\\PL", "\\P{IsN}",
        "[\\p{Lu}\\p{Nd}]", "[^\\p{Ll}\\p{Cc}]", "[\\P{L}&&[a-f0-5]]", "[\\p{Sm}\\p{Sc}]", "\\p{IsAlphabetic}",
        "\\p{IsUPPERCASE}", "\\p{Isuppercase}", "\\p{IsWhite_Space}", "\\p{IsPunctuation}", "\\p{IsAlpha}", "\\p{gc=Alnum}",
        "(?i)\\p{Lu}", "(?i)\\p{Ll}", "(?i)\\p{Lt}", "(?i)\\p{L}", "(?i)\\P{Lu}",
    )
    for (form in forms) {
        println("${form.padEnd(22)} ${members(Regex(form))}")
    }
    println("Hello, World! 42 (x+y)".replace(Regex("\\p{Lu}"), "_"))
    println(Regex("\\p{Lu}\\p{Ll}+").findAll("Camel case: ParseHTTPRequest Now").map { it.value }.toList())
    println("a-b_c(d)[e]{f}".split(Regex("[\\p{Pd}\\p{Pc}\\p{Ps}\\p{Pe}]+")))
    println(Regex("^\\p{Nd}+$").matches("2024") to Regex("^\\p{Nd}+$").matches("20x4"))
    for (bad in listOf("\\p{Xx}", "\\p{lu}", "\\p{IsGreekish}", "\\p{InNoSuchBlock}", "\\p{gc=Xx}", "\\p{foo=Lu}")) {
        val result = runCatching { Regex(bad) }
        println("$bad -> ${if (result.exceptionOrNull() is IllegalArgumentException) "rejected" else "accepted"}")
    }
}
