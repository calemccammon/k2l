import java.util.Locale

// --strings utf16: Char classification and case mapping follow the JDK's Unicode tables

fun flags(c: Char): String = buildString {
    if (c.isLetter()) append('L')
    if (c.isDigit()) append('D')
    if (c.isLetterOrDigit()) append('A')
    if (c.isWhitespace()) append('W')
    if (c.isUpperCase()) append('U')
    if (c.isLowerCase()) append('l')
}

fun classification() {
    val samples = listOf(
        'a', 'Z', '5', ' ', '\t', '_', 'é', 'É', 'ß', 'ÿ', 'Σ', 'ς', 'σ', 'Ω', 'ж', 'Ж', '日', 'テ', 'ｱ', '한', '١', '٣', '²', '½', '٫',
        '\u00A0', '\u2003', '\u200B', '\u3000', '\u0085', '\u001F', 'ǅ', 'ǆ', 'Ⅷ', 'ⅷ', 'ⓐ', 'Ⓐ', 'ª', 'º', 'ʰ', '\u0301', '€',
    )
    for (c in samples) {
        println("U+${c.code.toString(16).padStart(4, '0')} ${flags(c)}")
    }
}

fun caseMapping() {
    println('é'.uppercaseChar())
    println('É'.lowercaseChar())
    println('ß'.uppercaseChar())
    println('ß'.uppercase())
    println('ǆ'.uppercaseChar())
    println('ǆ'.titlecaseChar())
    println('ǆ'.titlecase())
    println('ǅ'.lowercaseChar())
    println('ŉ'.uppercase())
    println('ŉ'.titlecase())
    println('ΐ'.uppercase())
    println('ΐ'.uppercase().length)
    println('İ'.lowercase())
    println('İ'.lowercase().length)
    println('ı'.uppercaseChar())
    println('ÿ'.uppercaseChar())
    println('µ'.uppercaseChar())
    println('a'.uppercaseChar())
    println('Z'.lowercase())
    println('ǈ'.uppercase())
    println('ﬃ'.uppercase())
    println('ﬃ'.titlecase())
    println("éa".replaceFirstChar { it.uppercase() })
    println("ǆemal".replaceFirstChar { it.titlecase() })
    println("ßtraße".replaceFirstChar { it.titlecase() })
}

fun stringCase() {
    val words = listOf(
        "straße", "Straße", "ǆ", "ﬃ", "άέή ώ", "ΐ", "ŉ", "İSTANBUL", "ÀÉÎÕÜ", "àéîõü", "日本語 abc", "Привет Мир", "ÿ", "µ",
        "a😀b", "𐐨𐐀", "ǅungla",
    )
    for (w in words) {
        println("$w -> ${w.uppercase()} ${w.lowercase()} ${w.uppercase().length} ${w.lowercase().length}")
    }
    println("ÀÉÎ".uppercase(Locale.ROOT))
    println("ÀÉÎ".lowercase(Locale.US))
    println("ÀÉÎ".lowercase(Locale.getDefault()))
    println("straße".uppercase(Locale.ENGLISH))
    println("ΑΣ".lowercase())
    println("ΑΣΑ".lowercase())
    println("ΣΑΣ".lowercase())
    println("Σ".lowercase())
    println("ΑΣ ΒΣ ΓΣΓ".lowercase())
    println("ΟΔΥΣΣΕΎΣ".lowercase())
    println("ΑΣ.".lowercase())
    println("ΑΣ!".lowercase())
    println("ΣΑΣ ΣΑΣ".lowercase())
    println("ΑΣ1".lowercase())
    println("Α-Σ".lowercase())
    println("ΑΣΣ".lowercase())
    println("αΣ".lowercase())
    println("aΣ".lowercase())
}

fun ignoreCase() {
    println("É".equals("é", ignoreCase = true))
    println("Straße".equals("STRASSE", ignoreCase = true))
    println("Σ".equals("ς", ignoreCase = true))
    println("ǅ".equals("ǆ", ignoreCase = true))
    println("ПРИВЕТ".equals("привет", ignoreCase = true))
    println("abc".equals("ABD", ignoreCase = true))
    println("Éclair".startsWith("éc", ignoreCase = true))
    println("Éclair".endsWith("AIR", ignoreCase = true))
    println("un ÉCLAIR".contains("éclair", ignoreCase = true))
    println("un ÉCLAIR".indexOf("éclair", ignoreCase = true))
    println("un ÉCLAIR é".lastIndexOf("É", ignoreCase = true))
    println("un ÉCLAIR".replace("éclair", "tarte", ignoreCase = true))
    println("a É b é c".split("é", ignoreCase = true))
    println("é".compareTo("É", ignoreCase = true))
    println("é".compareTo("É"))
    println(listOf("zèbre", "Zèbre", "éclair", "Éclat", "apple", "Äpfel", "Zoo").sortedWith(String.CASE_INSENSITIVE_ORDER))
    println(listOf("zèbre", "Zèbre", "éclair", "Éclat", "apple", "Äpfel", "Zoo").sorted())
    println(listOf("b", "é", "a", "É").sortedWith(compareBy(String.CASE_INSENSITIVE_ORDER) { it }))
    println("é".equals("É"))
    println('é'.equals('É', ignoreCase = true))
    println('a'.equals('b', ignoreCase = true))
}

fun digits() {
    println('٣'.digitToInt())
    println('a'.digitToInt(16))
    println('F'.digitToInt(16))
    println('x'.digitToIntOrNull())
    println('٣'.digitToIntOrNull())
    println('9'.digitToInt())
    println('७'.digitToInt())
    println('²'.digitToIntOrNull())
}

fun predicates() {
    val s = "Héllo, Wörld! 日本語 123 ١٢٣ 😀"
    println(s.count { it.isLetter() })
    println(s.count { it.isDigit() })
    println(s.count { it.isWhitespace() })
    println(s.count { it.isUpperCase() })
    println(s.count { it.isLowerCase() })
    println(s.filter { it.isLetterOrDigit() })
    println(s.map { if (it.isLetter()) it.uppercaseChar() else it }.joinToString(""))
    println(s.any { it.isSurrogate() })
    println(s.all { it.isLetter() })
    println(s.trim { !it.isLetter() })
    println("\u00A0 é \u3000".trim())
    println("\u00A0 é \u3000".trim().length)
    println("\u2003\u2003".isBlank())
    println("\u200B".isBlank())
    println(" é ".isNotBlank())
    println("\u00A0é".trimStart().length)
    println("é\u2028".trimEnd().length)
    println("été".capitalizeFirst())
    println("ÉTÉ".lowercase().replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() })
}

fun String.capitalizeFirst(): String = replaceFirstChar { it.uppercase() }

fun regexClasses() {
    val word = Regex("\\w+")
    println(word.findAll("héllo wörld 日本語 abc").map { it.value }.toList())
    println(Regex("\\d+").findAll("a١٢٣b123").map { it.value }.toList())
    println(Regex("\\s").findAll("a\u00A0b c").count())
    println(Regex("[a-z]+").findAll("héllo").map { it.value }.toList())
    println(Regex("é").find("héllo")?.range)
    println(Regex("(.)(.)").find("日本語")?.groupValues)
    println("ÀB".matches(Regex("[ÀÉ]B")))
}

fun main() {
    classification()
    caseMapping()
    stringCase()
    ignoreCase()
    digits()
    predicates()
    regexClasses()
}
