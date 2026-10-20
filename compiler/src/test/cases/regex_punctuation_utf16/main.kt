// With --strings utf16, \p{P} and \p{S} test non-ASCII characters by the Unicode tables; \p{Punct} stays ASCII as in Java.

fun classify(regex: String, text: String): String = text.map { if (Regex(regex).matches(it.toString())) '1' else '0' }.joinToString("")

fun main() {
    val text = "¡¿«»—–…‘’“”·§¶†€£¥©®°±×÷≠∞→★♥€ｦ、。「」"
    for (regex in listOf("\\p{P}", "\\p{IsPunctuation}", "\\p{Punct}", "\\p{S}", "\\P{P}", "[\\p{P}\\p{S}]", "[^\\p{P}]")) {
        println("${regex.padEnd(20)} ${classify(regex, text)}")
    }
    println("«Bonjour», dit-il… “¿Qué?” — ¡sí!".replace(Regex("\\p{P}"), ""))
    println("Prix: 5€ ± 2£ → ★".split(Regex("\\p{S}+")).map { it.trim() })
    println(Regex("[\\p{L}\\p{P}]+").findAll("naïve—café, ok? 😀 «x»").map { it.value }.toList())
    // supplementary characters: U+10100 AEGEAN WORD SEPARATOR LINE is punctuation, U+1F600 a symbol
    println(Regex("\\p{P}").containsMatchIn("\uD800\uDD00") to Regex("\\p{S}").containsMatchIn("\uD83D\uDE00"))
}
