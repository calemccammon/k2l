package app.util

const val GREETING = "hello"

var calls = 0

fun counted(): Int {
    calls++
    return calls
}

fun shout(s: String) = s.uppercase() + "!"

fun Int.twice() = this * 2
