// Arguments of a vararg call that are `in` expressions, hash codes of numbers and of a map, and exception messages.
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC: ${e.message}")
    }
}

fun main() {
    // arguments of a vararg call that are `in` / `!in` expressions
    t("in-varargs") { listOf(5 in 1..10, 5 !in 1..4, 'c' in 'a'..'z', 9 in 1..3) }
    t("setOf-in") { setOf(1 in 0..2, 3 in 0..2) }
    // hashCode of non-Int numbers
    t("dblHash") { listOf(1.5.hashCode(), (-0.1).hashCode()) }
    t("longHash") { listOf(5000000000L.hashCode(), (-5000000000L).hashCode(), 7L.hashCode()) }
    t("mapHash") { mapOf(1.5 to "a").hashCode() }
    // exception messages
    t("digitToInt") { 'x'.digitToInt() }
    t("digitToInt16") { 'x'.digitToInt(16) }
    t("windowed") { "abc".windowed(0) }
    t("padStart") { "abc".padStart(-1) }
    t("repeat") { "abc".repeat(-1) }
}
