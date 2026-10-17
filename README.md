# k2l: Kotlin to Lua

k2l transpiles Kotlin source code to readable Lua, in the spirit of
[TypeScriptToLua](https://typescripttolua.github.io/). It uses the official Kotlin compiler's
[Analysis API](https://kotlin.github.io/analysis-api/) to parse and type-check your code, then
generates Lua that looks like something you would write by hand:

```kotlin
data class Item(val name: String, val price: Int)

fun cheapest(items: List<Item>): String? =
    items.filter { it.price > 0 }.minByOrNull { it.price }?.name
```

```lua
local function cheapest(items)
    local ____receiver = items:filter(function(it) return it.price > 0 end):minByOrNull(function(it) return it.price end)
    return ____receiver and ____receiver.name
end
```

Supported targets are Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT.

## Quick start

Requirements: JDK 21 (to build and run the transpiler) and a Lua interpreter.

```sh
./gradlew :compiler:installDist          # builds compiler/build/install/k2l
export PATH="$PWD/compiler/build/install/k2l/bin:$PATH"

cd examples/hello
k2l                                      # reads k2l.json, writes out/
cd out && lua5.4 main.lua
```

Generated files load each other with `require`, which resolves relative to the current directory,
so run Lua from the output directory (or add `out/?.lua` to `package.path`).

## Usage

```
k2l [options] [SOURCE_DIR...]

  -p, --project FILE      read settings from a k2l.json project file
  -o, --out DIR           output directory (default: out)
  -t, --target VERSION    Lua version: 5.1, 5.2, 5.3, 5.4 (default) or JIT
      --lualib MODE       require (default: one shared lualib_bundle.lua) or inline
      --classpath PATHS   extra jars or class directories, e.g. Lua bindings
```

With no arguments, k2l reads `./k2l.json`. Paths in it are relative to the file, and command-line
options override it:

```json
{
  "srcDirs": ["src"],
  "outDir": "out",
  "luaTarget": "5.4",
  "luaLibImport": "require",
  "classpath": []
}
```

Each `.kt` file becomes a `.lua` file at the same relative path. The runtime support code (the
"lualib") is written once as `lualib_bundle.lua`; each file imports only what it uses. With
`--lualib inline`, each file carries its own copy instead.

Kotlin compile errors are reported and stop the build. Kotlin features k2l can't translate yet are
reported as `error: ... is not supported yet`, with file and line; k2l never silently miscompiles a
construct it doesn't understand.

## How Kotlin maps to Lua

| Kotlin | Lua |
|---|---|
| `fun f(x: Int) = x + 1` | `local function f(x) return x + 1 end` |
| top-level declarations | locals; public ones are exported in the module table |
| `val`/`var` | `local` |
| `if`/`when` as values | `if` chains assigning to the target, or `c and a or b` when that's safe |
| `for (i in 0 until n)`, `downTo`, `step` | numeric `for` |
| `for (x in list)` | `for _, x in ipairs(list)` (a numeric loop if elements can be null) |
| `for ((k, v) in map)` | `for k, v in map:iter()` |
| `continue`, labeled `break`/`continue` | `goto` (flags and `repeat ... until true` on Lua 5.1) |
| `a / b` on `Int`, `a % b` | `__K2L_IDiv(a, b)` (truncating), `math.fmod(a, b)` |
| string templates | `..` concatenation; values formatted like Kotlin's `toString()` |
| `class`, `interface`, `object`, `enum class`, `data class` | metatable-based classes: `Point.new(1, 2)`, `p:distance(q)` |
| primary/secondary constructors, `init` | `Class:____init(...)`, chained to the superclass |
| properties | table fields; custom accessors become `getX()`/`setX()` methods |
| companion objects | members on the class table: `Point:of(1, 2)` |
| `==` | `==` for primitives/enums/objects, `equals()` when a class may override it |
| `is`, `as?` | `__K2L_InstanceOf(x, Class)`, `type(x) == "string"`, ... |
| `x?.y`, `x ?: y`, `x!!` | `x and x.y`, `x or y` (when safe), `__K2L_NotNull(x)` |
| lambdas, function references | Lua closures |
| `let`, `apply`, `also`, `run`, `with`, `forEach`, `buildString`, ... | inlined, so `return` inside them works as in Kotlin |
| extension functions | plain functions taking the receiver first: `shout("hi")` |
| default and named arguments | `if x == nil then x = default end` in the callee; callers pass `nil` for omitted ones |
| overloads | `describe`, `describe__1`, ... (overrides keep their parent's name) |
| `vararg`, `*spread` | Lua varargs packed into an array; `table.unpack` |
| `throw`, `try`/`catch`/`finally` | `error(exception)`, `pcall`; JVM exception classes and messages |
| `List`, `MutableList`, `Array` | a lualib class: elements in the array part, explicit `size` (nil-safe) |
| `xs[i]`, `xs.size` | `xs[i + 1]`, `xs.size` |
| `Map`, `Set` | insertion-ordered lualib classes honoring `equals()`/`hashCode()` keys |
| `xs.filter { }.map { }`, `groupBy`, `joinToString`, ... | methods of the same name: `xs:filter(f):map(g)` |
| `Pair`, `Triple`, destructuring | lualib classes; `local a, b = p.first, p.second` |
| multiple files | `local ____util = require("util")`, `____util.helper(...)` |

`Int` arithmetic is not wrapped to 32 bits (Lua integers are 64-bit, or doubles before 5.3);
explicit conversions like `Long.toInt()` and bitwise operations do wrap.

## Calling Lua from Kotlin

The `dev.k2l.lua` package (module `lua-api`, always on the transpiler's classpath) declares Lua APIs
for Kotlin code. External declarations generate no Lua; references to them use their Lua names.

```kotlin
@file:LuaRequire("lib.greeter")   // these functions are fields of require("lib.greeter")
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

@LuaExternal
@LuaRequire("lib.vector")         // require("lib.vector") returns the class itself
class Vector(val x: Double, val y: Double) {
    external fun add(other: Vector): Vector
}
```

```kotlin
val (q, r) = divmod(17, 5)        // local q, r = ____greeter.divmod(17, 5)
val v = Vector(3.0, 4.0)          // local v = ____vector.new(3.0, 4.0)

val t = LuaTable<String, Int>()   // local t = {}
t["retries"] = 3                  // t.retries = 3
t.forEach { k, v -> println(k) }  // for k, v in pairs(t) do ... end

Lua.print("raw", 1, true)         // print("raw", 1, true)
val (ok, err) = Lua.pcall { error("boom") }
```

- `@LuaExternal` marks a declaration (or a whole class, interface or object) as implemented in Lua.
  Kotlin's `external` keyword works for functions.
- `@LuaName("name")` uses a different Lua name. An object named `_G` maps its members to globals.
- `@LuaRequire("module")` on a file makes its external top-level declarations fields of that module;
  on a class or object, the module is the class or object.
- Members of external objects are called with `.`, instance members with `:` unless `@NoSelf`.
- External classes are constructed with `Class.new(...)`.
- `LuaTable<K, V>` is a plain table; `LuaMultiReturn2`/`3` destructure multiple return values.
- `Lua` (globals), `LuaOs` and `LuaIo` bind parts of the standard library.

Kotlin lists are Lua sequences (1-based, with a `size` field), so they can be passed to Lua functions
that expect arrays; Kotlin lambdas are Lua functions.

## Lua targets

`--target 5.4` (the default) and `5.3` use integers, `//` and native bitwise operators. On `5.2`,
`5.1` and `JIT`, which have only floating-point numbers:

- `Double` values are printed from their static type (`2.0`, not `2`); an integral `Double` inside a
  collection prints like an `Int`, since the two are the same Lua number at runtime.
- `Long` values above 2^53 lose precision, and `Long` bitwise operations are 32-bit.
- Bitwise operations use `bit32` (5.2), LuaJIT's `bit` library, or plain Lua (5.1).
- Lua 5.1 has no `goto`: `continue` breaks out of a one-iteration `repeat ... until true`, and
  labeled jumps use flags.

## Not supported yet

Inner classes, extension properties, coroutines (`suspend`), reflection (`::class`), sequences
other than as eager lists, `break`/`continue` out of a `try` block, and custom accessors on open
properties. Each is reported as an error rather than miscompiled.

Other semantic differences to be aware of: strings are byte strings, so `length` and indexing count
UTF-8 bytes; `xs[i]` is not bounds-checked (`get(i)` and `elementAt(i)` are); objects are initialized
when their file loads rather than on first access; Lua runtime errors are caught as
`RuntimeException`.

## Development

```sh
./gradlew test                     # transpile + run every test case on every Lua interpreter found
./gradlew test -PupdateGolden      # rewrite expected.lua files after an intended output change
./gradlew :compiler:kotlinOracle   # check each stdout.txt against what Kotlin/JVM prints
```

Each directory in `compiler/src/test/cases` is a program: `main.kt` (plus any other `.kt` files),
`expected.lua` (the exact Lua output for 5.4), and `stdout.txt`. The tests also run each program on
Lua 5.1, 5.2, 5.3 and LuaJIT when those interpreters are installed (`lua5.1`, `lua5.2`, `lua5.3`,
`luajit`; override with `-Dk2l.lua51=...` etc.). Expected output isn't written by hand: the
`kotlinOracle` task compiles and runs each case with the real Kotlin compiler (`-PupdateOracle`
rewrites the files). A case with `errors.txt` instead checks the diagnostics; `targets-skip.txt`
lists documented differences on specific targets; `jvm-skip` marks cases that call hand-written Lua.

Layout:

- `compiler/src/main/kotlin/dev/k2l/frontend`: the standalone Analysis API session.
- `.../transform`: Kotlin PSI and types to a Lua syntax tree (`FileTransformer`, plus the
  stdlib and collection mappings).
- `.../lua`: the Lua syntax tree, its printer and the lualib loader.
- `compiler/src/main/resources/dev/k2l/lualib`: the runtime, as plain Lua; `Name.float.lua` and
  similar files are target-specific variants.
- `lua-api`: the `dev.k2l.lua` interop declarations.

The Analysis API artifacts come from JetBrains' `intellij-dependencies` repository and must match the
Kotlin version exactly; see the comments in `gradle/libs.versions.toml` before upgrading.
