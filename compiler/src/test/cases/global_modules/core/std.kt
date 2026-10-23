package core

import dev.k2l.lua.LuaName

fun clamp(x: Int, lo: Int, hi: Int) = if (x < lo) lo else if (x > hi) hi else x

@LuaName("format_hp")
fun formatHp(hp: Int) = "HP $hp"

const val LIMIT = 400

val sizes = listOf(10, 20)

var counter = 0

internal fun bump(): Int {
    counter += 1
    return counter
}

private val secret = "core"

val greeting: String get() = "hello from $secret"

var volume: Int = 3
    set(value) {
        field = clamp(value, 0, 10)
    }

// In require mode this initializer would wait for the first read; globals are initialized when the file loads.
val computed = compute()

private fun compute(): Int {
    println("computing in core")
    return 42
}
