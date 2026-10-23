package other

import dev.k2l.lua.LuaName

fun clamp(x: Int) = x

class Panel

@LuaName("render")
fun draw() = Unit

// private declarations stay local: no clash
private fun helper() = 1

fun useHelper() = helper()
