package other

import dev.k2l.lua.LuaName

fun clamp(x: Int) = x

class Panel

@LuaName("render")
fun draw() = Unit

// private declarations stay local: no clash
private fun helper() = 1

fun useHelper() = helper()

internal class Model

internal fun models() = listOf(Model(), app.Model())

// internal declarations that only their own file uses stay local: no clash with app.shrink
internal fun shrink() = 4

internal val shrunk = shrink()
