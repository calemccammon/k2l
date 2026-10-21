// A `when` branch `in <collection>` after an equality branch, with library and program types.
enum class Color { RED, GREEN, BLUE }

fun classify(n: Int): String = when (n) {
    0 -> "zero"
    in listOf(1, 2, 3) -> "small"
    in setOf(10, 20) -> "round"
    !in 0..100 -> "out of range"
    else -> "other"
}

fun warm(c: Color): Boolean = when (c) {
    Color.BLUE -> false
    in listOf(Color.RED) -> true
    else -> false
}

fun cool(c: Color): String = when (val shade = c) {
    Color.RED -> "warm"
    in listOf(Color.GREEN, Color.BLUE) -> "cool $shade"
    else -> "?"
}

fun word(s: String): String = when (s) {
    "" -> "empty"
    in arrayOf("a", "e", "i", "o", "u") -> "vowel"
    in mutableListOf("y") -> "sometimes"
    else -> "consonant"
}

fun main() {
    for (n in listOf(0, 2, 10, 50, 500)) println("$n ${classify(n)}")
    for (c in Color.entries) println("$c ${warm(c)} ${cool(c)}")
    for (s in listOf("", "e", "y", "k")) println("'$s' ${word(s)}")
}
