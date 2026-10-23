package app

import state.*

// Public: globals the host calls.
object Screen {
    internal var current = initial

    fun OnShown() {
        for (e in effects()) current = reduce(current, e)
        notify({ println("listener ${it.describe()}") }, current)
        println(summary)
    }
}

fun hostVersion() = "v$START"

internal fun local() = "only main.kt uses this"

fun main() {
    traced { println(local()) }
    ticks += 10
    println(summary)
    println(defaults)
    Screen.OnShown()
}
