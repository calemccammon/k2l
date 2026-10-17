import bindings.Vector
import bindings.VERSION
import bindings.divmod
import bindings.each
import bindings.greet
import bindings.makeCounter
import dev.k2l.lua.Lua
import dev.k2l.lua.LuaOs
import dev.k2l.lua.LuaTable

fun main() {
    println(greet("lua") + " v" + VERSION)
    val (q, r) = divmod(17, 5)
    println("$q $r")

    val names = LuaTable<Int, String>()
    names[1] = "ann"
    names[2] = "bob"
    println(names.length)
    each(names) { println("item $it") }

    val counter = makeCounter(10)
    counter.increment(5)
    println(counter.count)
    println(counter.describe(counter))

    val v = Vector(3.0, 4.0).add(Vector(0.0, 0.0))
    println(v.length())
    println(v.x)

    val config = LuaTable<String, Int>()
    config["retries"] = 3
    println(config.has("retries"))
    config.remove("retries")
    println(config["retries"])

    Lua.print("raw", 1, true)
    println(Lua.type(names))
    println(LuaOs.time() > 0)
    val (ok, _) = Lua.pcall { error("boom") }
    println(ok)
}
