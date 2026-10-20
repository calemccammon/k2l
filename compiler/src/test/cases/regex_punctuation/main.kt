// \p{P} and \p{S} are Unicode's punctuation and symbol categories (ASCII's POSIX \p{Punct} is split between them), and
// \p{Punct} stays ASCII as in Java. Non-ASCII characters are in the categories with --strings utf16 (see regex_punctuation_utf16).

fun classify(regex: String, text: String): String = text.map { if (Regex(regex).matches(it.toString())) '1' else '0' }.joinToString("")

fun main() {
    val ascii = (33..126).map { it.toChar() }.filter { !it.isLetterOrDigit() }.joinToString("")
    println(ascii)
    for (regex in listOf("\\p{P}", "\\p{IsP}", "\\p{IsPunctuation}", "\\p{Punct}", "\\p{S}", "\\p{IsS}", "\\P{P}", "[\\p{P}\\p{S}]")) {
        println("${regex.padEnd(20)} ${classify(regex, ascii)}")
    }
    println("Hello, world! (a+b) = $5; x_y".replace(Regex("\\p{P}+"), ""))
    println("Hello, world! (a+b) = $5; x_y".split(Regex("[\\s\\p{P}]+")))
    println(Regex("\\p{S}").findAll("1+2<3 and $4|^").map { it.value }.toList())
}
