package screens

import core.LIMIT
import core.clamp

fun width(w: Int) = clamp(w, 10, LIMIT)

// The parameter is named like the global function it calls.
fun shrink(clamp: Int) = core.clamp(clamp, 0, 5)

val Int.doubled: Int get() = this * 2

private fun helper() = "private to Hotbar"

fun describe() = helper()
