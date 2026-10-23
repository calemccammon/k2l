# Lua interop

The package `dev.k2l.lua` (the `lua-api` module) declares Lua APIs for Kotlin code. It is always on k2l's classpath.

- [Calling Lua from Kotlin](#calling-lua-from-kotlin)
- [Calling Kotlin from Lua](#calling-kotlin-from-lua)
- [Self](#self)

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
| `@NoSelf` | call with `.` instead of `:`. Members of external objects already are. Also works on Kotlin code, see [Self](#self). |
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
`require` it by its path under the source directory. With `--modules global` the declarations are globals instead, see
[below](#global-modules).

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
local e = mod.Registry:make(3)    -- object and companion members: `:` (`.` without self, see below)
print(e.hp, e:getAlive())         -- a plain property is a field; a custom getter is a method
local e2 = mod.Enemy.new(0)       -- constructors are Class.new(...)
print(tostring(e2))               -- tostring() is the object's toString()
```

- `@LuaName` on a top-level function or property gives it a Lua-style name in the module table.
- Private members of classes and objects are, where possible, locals of their file instead of fields.
- A plain Lua array is not a Kotlin `List`.
- The runtime has only what the Kotlin code uses. Lua can call a method of a Kotlin object, such as a list's
  `joinToString`, only if the Kotlin code calls a method of that name somewhere.
- Kotlin exceptions reach Lua's `pcall` as objects with a `message` field.
- Lua errors reach Kotlin as `RuntimeException`.
- To drive Kotlin coroutines from Lua, export a Kotlin function that starts them (with `startCoroutine`) and one that
  resumes your scheduler.

### Global modules

With `--modules global` ([Usage](usage.md#global-modules)), the same file sets globals. Lua code that runs after the
host has loaded it uses them directly:

```lua
print(on_load("x"))
local e = Registry:make(3)
local e2 = Enemy.new(0)
```

- A top-level `val` or `var` is a global that Lua can read and write.
- A top-level property `x` with a custom getter or setter is a pair of global functions, `getX()` and `setX(value)`.
- Internal and private declarations are not globals.

## Self

By default a member function takes `self`. k2l defines it as `function Book:Initialize(a, b)` and calls it as
`book:Initialize(a, b)`. Lua code that calls `Book.Initialize(a, b)` passes `a` as `self`.

Like TypeScriptToLua's `@noSelf`, you can define members without `self`:

| Declaration | Effect |
|---|---|
| `@NoSelf` on a class, object, companion object or interface | its functions and properties take no `self`. A class's companion follows the class. |
| `@NoSelf` on a member function or property | that member takes no `self` |
| `@file:NoSelfInFile` | every class, object and interface in the file is `@NoSelf` |
| `noImplicitSelf` option | every file is `@file:NoSelfInFile` (`--no-implicit-self`, `"noImplicitSelf": true`) |

Such a member is called with `.`, from Kotlin and from Lua:

```kotlin
@NoSelf
object Dispatch {
    var wheel = 0
    fun OnMouseWheel(x: Int, y: Int, delta: Int) { wheel += delta }
}
```

```lua
function Dispatch.OnMouseWheel(x, y, delta)
    Dispatch.wheel = Dispatch.wheel + delta
end

Dispatch.OnMouseWheel(1, 2, 3)
```

- In an object, `this` is the object's table. This includes companion objects and object expressions.
- An object or object expression that implements an interface has the interface's functions as functions of its table, so
  `ticker.start()` works.
- A class keeps its methods with `self` in the class table. Each instance gets a field for each member without `self`: a
  closure that calls the method with the instance. The constructor sets these fields. This costs one closure per such member
  per instance. Overrides, `super` calls and calls from inside the class work as usual. Private functions need no field:
  they are locals of the file.
- Function references (`Book::Initialize`, `obj::f`, `Class::f`) work with members without `self`.

Some members always take `self`:

- Members that override a member with `self`. Supertypes decide: an override takes `self` when the member it overrides
  does. This includes library members such as `toString`, `equals`, `hashCode` and `compareTo`, which the runtime calls
  with `:`.
- Operator functions and member extensions.
- The members k2l generates for data classes and enums.
- Calls into k2l's runtime, such as `list:add(x)`.

`@NoSelf` on a member that must take `self` is an error. So is a member that overrides one member with `self` and one
without.
