package mods.mods

import dev.k2l.lua.LuaName
import mods.bindings.Host
import mods.shared.Events
import mods.shared.Version

// A mod written in Kotlin and loaded by the Lua driver: `require("mods.Greeter").on_load(host)`.

val requires = Version(1, 2)

@LuaName("greeting_style")
var style = "plain"

@LuaName("on_load")
fun loadGreeter(host: Host): String {
    host.log("greeter loaded into ${host.name}")
    Events.on("join") { who -> host.log(greet(who)) }
    host.schedule(2) { host.log("greeter: delayed hello") }
    return "greeter"
}

fun greet(who: String, punctuation: String = "!"): String = when (style) {
    "loud" -> "HELLO ${who.uppercase()}$punctuation"
    else -> "hello $who$punctuation"
}

@LuaName("greet_all")
fun greetAll(vararg names: String): List<String> = names.map { greet(it, ".") }

fun compatible(hostVersion: String): Boolean = Version.parse(hostVersion) >= requires
