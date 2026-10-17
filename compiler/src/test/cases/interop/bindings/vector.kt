package bindings

import dev.k2l.lua.LuaExternal
import dev.k2l.lua.LuaRequire

@LuaExternal
@LuaRequire("lib.vector")
class Vector(val x: Double, val y: Double) {
    external fun length(): Double
    external fun add(other: Vector): Vector
}
