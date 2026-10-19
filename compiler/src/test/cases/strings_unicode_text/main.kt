// Indents are measured by Char.isWhitespace, and number parsing takes Unicode digits, as on the JVM
fun show(s: String): String = s.map { if (it.isWhitespace() && it != '\n' && it != ' ') "[${it.code}]" else it.toString() }.joinToString("")

fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: Exception) {
        println("$label: ${e::class.simpleName}: ${e.message}")
    }
}

fun indents() {
    val nbsp = " "
    val em = " "
    val ideographic = "　"
    println(show("\n$nbsp${nbsp}line1\n$nbsp$nbsp${nbsp}line2\n$nbsp${nbsp}\n$nbsp${nbsp}line3\n".trimIndent()))
    println(show("$em${em}a\n$em${em}${em}b\n${em}c".trimIndent()))
    println(show("${ideographic}x\n${ideographic}${ideographic}y".trimIndent()))
    println(show("$nbsp a\n   b".trimIndent()))
    println(show("\u001Cx\n\u001C\u001Cy".trimIndent()))
    println(show("   a\n    b".trimIndent()))
    println(show("\n\n  a\n\n   b\n".trimIndent()))
    println(show("$nbsp$nbsp| a\n$em|  b\n   | c".trimMargin()))
    println(show("$nbsp>one\n$em>two\n three".trimMargin(">")))
    println(show("\n$nbsp$nbsp|x\n$nbsp$nbsp|y\n".trimMargin()))
    println(show("$ideographic|z\n $nbsp|w".trimMargin("|")))
    attempt("margin") { "a".trimMargin(" ") }
    attempt("marginNbsp") { "a".trimMargin(nbsp) }
    println(show("a\n\n$nbsp\nb".prependIndent("> ")))
    println(show("a\n$nbsp$nbsp\n".prependIndent(">>>")))
    println(show("a\n$nbsp\n".prependIndent(">>>")))
    println(show("$nbsp\nb".prependIndent("")))
    println("héllo\n  wörld".prependIndent("→"))
    println("    ünï\n      cödé".trimIndent())
}

fun digits() {
    println("١٢٣".toInt())
    println("-١٢٣".toInt())
    println("+٤٥".toInt())
    println("１２３".toInt())
    println("१२३".toLong())
    println("০১২".toInt())
    println("๑๒๓".toIntOrNull())
    println("12٣".toInt())
    println("٣٣٣٣٣٣٣٣٣٣٣٣".toLongOrNull())
    println("٣٣٣٣٣٣٣٣٣٣٣٣".toIntOrNull())
    println("ａｂ".toInt(16))
    println("ＡＢ".toInt(16))
    println("ａｂ".toIntOrNull(10))
    println("ｚ".toInt(36))
    println("ｚ".toIntOrNull(35))
    println("ff".toInt(16))
    println("٣f".toInt(16))
    println("²".toIntOrNull())
    println("ⅷ".toIntOrNull())
    println("١ ٢".toIntOrNull())
    println(" ١".toIntOrNull())
    println("٢.٥".toIntOrNull())
    println("-".toIntOrNull())
    println("٧".toLong())
    println("٩٩٩".toUInt())
    println("-٩".toUIntOrNull())
    println("٢٥٥".toUByte())
    println("٢٥٦".toUByteOrNull())
    println("ＦＦ".toUInt(16))
    println("１２３４５６７８９０１２３".toULong())
    println('٥'.digitToInt())
    println('５'.digitToInt())
    println('Ａ'.digitToInt(16))
    println('ａ'.digitToInt(16))
    println('ｚ'.digitToInt(36))
    println('ｚ'.digitToIntOrNull(16))
    println('९'.digitToIntOrNull())
    println('²'.digitToIntOrNull())
    attempt("bad") { "١٢x".toInt() }
    attempt("badRadix") { "ｚ".toInt(16) }
    attempt("empty") { "".toInt() }
    attempt("arabicMessage") { "٣٤٥٦٧٨٩٠١٢٣".toInt() }
    attempt("parseInt") { Integer.parseInt("٤٢") }
    attempt("parseLong") { java.lang.Long.parseLong("-٤٢٠") }
    attempt("valueOf") { Integer.valueOf("٧") }
    println("٤٢".toIntOrNull()?.plus(1))
    println("١٢٣".toDoubleOrNull())
}

fun main() {
    indents()
    digits()
}
