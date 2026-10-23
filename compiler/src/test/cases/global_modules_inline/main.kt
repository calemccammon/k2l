import util.*

fun main() {
    println(shout("hey"))
    words.add("gamma")
    println(joined())
    println(joined().length)
    println(calls)
    Settings.verbose = true
    println(Settings.verbose)
    println(words.map { it.length })
}
