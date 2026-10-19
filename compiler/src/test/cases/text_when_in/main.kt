// `in` conditions of a `when` with a subject that are not ranges: strings, collections, map keys and values (the
// `contains` operator they resolve to), negated, combined and with a subject evaluated once.

fun next(): Int {
    println("next")
    return 3
}

fun classify(c: Char): String = when (c) {
    in "aeiou" -> "vowel"
    !in "bcdfghjklmnpqrstvwxyz" -> "other"
    else -> "consonant"
}

class Bag(private val items: Set<String>) {
    operator fun contains(s: String) = s.lowercase() in items
}

fun main() {
    val pairs = mapOf(')' to '(', ']' to '[')
    for (c in "a(b]z!") {
        when (c) {
            in pairs.values -> println("open $c")
            in pairs.keys -> println("close $c")
            else -> println("${classify(c)} $c")
        }
    }
    val set = setOf(1, 2, 3)
    when (next()) {
        in set -> println("in set")
        else -> println("no")
    }
    when (val n = next()) {
        in listOf(5, 6), in set -> println("n=$n in")
        else -> println("no")
    }
    val word = "kotlin"
    println(when (word) { in listOf("java", "kotlin") -> "jvm"; else -> "?" })
    println(when ("lin") { in word -> "sub"; else -> "?" })
    val bag = Bag(setOf("apple", "pear"))
    for (f in listOf("Apple", "kiwi")) println(when (f) { in bag -> "$f in bag"; !in bag -> "$f not in bag"; else -> "?" })
    val ranges = listOf(1..3, 10..12)
    println(when (11) { in ranges[0] -> "first"; in ranges[1] -> "second"; else -> "none" })
    println(when ('x') { in charArrayOf('x', 'y') -> "xy"; else -> "-" })
}
