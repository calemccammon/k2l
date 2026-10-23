package util

fun shout(s: String) = s.uppercase() + "!"

val words = mutableListOf("alpha", "beta")

var calls = 0

fun joined(): String {
    calls++
    return words.joinToString(", ")
}

object Settings {
    var verbose = false
}
