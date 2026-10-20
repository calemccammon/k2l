package mods.mods

import dev.k2l.lua.LuaName
import mods.bindings.Host
import mods.shared.Events

// Its properties are initialized when the driver first reads one (as the JVM does on first use of the file), and the
// driver writes `click_count` directly.

val bootMessage: String = run {
    println("counter: initializing its top-level state")
    "counter ready after ${Events.fired.size} events"
}

@LuaName("click_count")
var clickCount = 0

private var host: Host? = null

@LuaName("on_load")
fun loadCounter(h: Host): String {
    host = h
    Events.on("click") { click(it.toIntOrNull() ?: 1) }
    return "counter"
}

fun click(times: Int = 1): Int {
    clickCount += times
    host?.log("clicked $times, total $clickCount")
    return clickCount
}

fun summary(): String = "$bootMessage; $clickCount clicks"
