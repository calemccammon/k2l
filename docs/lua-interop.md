# Lua interop

The package `dev.k2l.lua` (the `lua-api` module) declares Lua APIs for Kotlin code. It is always on k2l's classpath.

- [Calling Lua from Kotlin](#calling-lua-from-kotlin)
- [Calling Kotlin from Lua](#calling-kotlin-from-lua)

## Calling Lua from Kotlin

Declare the Lua API in Kotlin. External declarations generate no Lua: references to them use their Lua names.

```kotlin
@file:LuaRequire("lib.greeter")   // these declarations are fields of require("lib.greeter")
package bindings

import dev.k2l.lua.*

external fun greet(name: String): String
external fun divmod(a: Int, b: Int): LuaMultiReturn2<Int, Int>

@LuaExternal
val VERSION: String get() = definedExternally

@LuaExternal                      // a Lua object returned by some function
interface Counter {
    val count: Int
    fun increment(by: Int)        // called as counter:increment(by)
    @NoSelf fun describe(c: Counter): String   // called as counter.describe(c)
}
```

Use it:

```kotlin
val (q, r) = divmod(17, 5)        // local q, r = ____greeter.divmod(17, 5)
val t = LuaTable<String, Int>()   // local t = {}
t["retries"] = 3                  // t.retries = 3
t.forEach { k, v -> println(k) }  // for k, v in pairs(t) do ... end
Lua.print("raw", 1, true)         // print("raw", 1, true)
```

| Declaration | Meaning |
|---|---|
| `@LuaExternal` | implemented in Lua; on a class, interface or object, every member is too. `external fun` works as well. |
| `@LuaName("name")` | the Lua name, when it differs from the Kotlin name. A Lua keyword works (`M["end"](...)`). An object named `_G` maps its members to globals. |
| `@LuaRequire("module")` | on a file: its external declarations are fields of `require("module")`. On a class or object: the module itself is that class or object. |
| `@NoSelf` | call with `.` instead of `:`. Members of external objects already are. |
| `definedExternally` | the body of an external property: `val VERSION: String get() = definedExternally` |
| `LuaTable<K, V>` | a plain table: `t[k]`, `t[k] = v`, `length` (`#t`), `has`, `remove`, `forEach` (`pairs`) |
| `LuaMultiReturn2`, `LuaMultiReturn3` | several return values; destructure them |
| `Lua` | Lua's globals: `print`, `tostring`, `tonumber`, `type`, `pcall`, `error`, `require`, `select` |
| `LuaOs` | `os.time`, `os.clock`, `os.getenv`, `os.date` |
| `LuaIo` | `io.write`, `io.read` |

Notes:

- External classes are constructed with `Class.new(...)`.
- Kotlin lambdas are Lua functions.
- Kotlin lists are Lua sequences with a `size` field, so Lua functions that read arrays can take them.
- Put bindings in a jar or class directory and pass it with `--classpath` (or `classpath` in `k2l.json` or the Gradle
  plugin), or keep them in your source directories.

## Calling Kotlin from Lua

Every Kotlin file is a Lua module. Its table holds the file's public top-level declarations. Hand-written Lua can
`require` it by its path under the source directory.

```kotlin
// src/mods/Greeter.kt
package mods

class Enemy(var hp: Int) {
    val alive: Boolean get() = hp > 0
}

object Registry {
    fun make(hp: Int) = Enemy(hp)
}

@LuaName("on_load")
fun onLoad(name: String) = "loaded $name"
```

```lua
local mod = require("mods.Greeter")
print(mod.on_load("x"))           -- a top-level function: `.`
local e = mod.Registry:make(3)    -- object and companion members: `:`
print(e.hp, e:getAlive())         -- a plain property is a field; a custom getter is a method
local e2 = mod.Enemy.new(0)       -- constructors are Class.new(...)
print(tostring(e2))               -- tostring() is the object's toString()
```

- `@LuaName` on a top-level function or property gives it a Lua-style name in the module table.
- A plain Lua array is not a Kotlin `List`.
- Kotlin exceptions reach Lua's `pcall` as objects with a `message` field.
- Lua errors reach Kotlin as `RuntimeException`.
- To drive Kotlin coroutines from Lua, export a Kotlin function that starts them (with `startCoroutine`) and one that
  resumes your scheduler.
