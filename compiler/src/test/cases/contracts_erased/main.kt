@file:OptIn(ExperimentalContracts::class)

import kotlin.contracts.ExperimentalContracts
import kotlin.contracts.InvocationKind
import kotlin.contracts.contract

// `contract { }` only informs the compiler: it has no code in Lua, in plain and inline functions alike.

inline fun <R> once(block: () -> R): R {
    contract {
        callsInPlace(block, InvocationKind.EXACTLY_ONCE)
    }
    return block()
}

fun isText(value: Any?): Boolean {
    contract {
        returns(true) implies (value is String)
    }
    return value is String
}

fun requireNotBlank(value: String?): String {
    contract {
        returns() implies (value != null)
    }
    require(!value.isNullOrBlank()) { "blank" }
    return value
}

class Counter {
    var count = 0

    inline fun bump(times: Int, step: () -> Int) {
        contract { callsInPlace(step, InvocationKind.UNKNOWN) }
        repeat(times) { count += step() }
    }
}

fun main() {
    val x: Int
    once { x = 41 }
    println(x + 1)
    println(once { "once" })
    val v: Any? = "text"
    if (isText(v)) println(v.length)
    println(isText(3))
    println(requireNotBlank(" ok ").trim())
    try {
        requireNotBlank("  ")
    } catch (e: IllegalArgumentException) {
        println("caught ${e.message}")
    }
    val c = Counter()
    c.bump(3) { 2 }
    println(c.count)
}
