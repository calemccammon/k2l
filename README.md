# k2l: Kotlin to Lua

k2l compiles Kotlin to plain, readable Lua. It is the Kotlin counterpart of
[TypeScriptToLua](https://typescripttolua.github.io/). You write Kotlin and keep its compile-time checks: types, null safety,
sealed classes and exhaustive `when`, data classes, extension functions, generics, inline functions, named and default
arguments, lambdas and operators. At run time the program is ordinary Lua: Lua numbers, byte strings, tables and the Lua
standard library. k2l does not emulate the JVM. The places where Lua's behaviour shows through are listed under
[Caveats](#caveats). A library API that k2l does not translate is a compile error, never a silent miscompilation.

k2l uses the official Kotlin compiler's [Analysis API](https://kotlin.github.io/analysis-api/) to parse and type-check
the sources. It targets Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT, and needs nothing third-party at run time.

```kotlin
sealed interface Shape
class Circle(val r: Double) : Shape
class Rect(val w: Double, val h: Double) : Shape

fun Shape.area(): Double = when (this) {
    is Circle -> 3.14159 * r * r
    is Rect -> w * h
}

fun main() {
    val shapes = listOf(Circle(1.0), Rect(2.0, 3.0))
    val big = shapes.filter { it.area() > 4.0 }
    println("${big.size} of ${shapes.size} are big")
}
```

```lua
-- (excerpt; Circle and Rect are classes made with __K2L_Class)
local function area(self)
    local ____mt = getmetatable(self)
    if ____mt == Circle then
        return 3.14159 * self.r * self.r
    elseif ____mt == Rect then
        return self.w * self.h
    end
end

local function main()
    local shapes = __K2L_ListOf(Circle.new(1.0), Rect.new(2.0, 3.0))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = shapes:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if area(it) > 4.0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local big = __K2L_ListWrap(____out, ____count)
    print(big.size .. " of " .. shapes.size .. " are big")
end
```

Common collection operations with a lambda literal, such as `filter` here, become loops. The other operations are
methods of a small runtime library (the "lualib"), which is written once as `lualib_bundle.lua`.

## Quick start

You need JDK 21 or newer to run k2l, and a Lua interpreter to run its output.

```sh
./gradlew :compiler:installDist          # builds compiler/build/install/k2l
export PATH="$PWD/compiler/build/install/k2l/bin:$PATH"

cd examples/hello
k2l                                      # reads k2l.json, writes out/
cd out && lua5.4 main.lua
```

Generated files load each other with `require`, which resolves paths from the current directory. Run Lua from the
output directory, or add `out/?.lua` to `package.path`.

Release builds will be published as `k2l-<version>.zip` on the GitHub Releases page, and the Gradle plugin `dev.k2l` on
the Gradle Plugin Portal (see [RELEASING.md](RELEASING.md)). Nothing has been released yet.

### Command line

```
usage: k2l [options] [SOURCE_DIR...]

  -p, --project FILE      read settings from a k2l.json project file
  -o, --out DIR           output directory (default: out)
  -t, --target VERSION    Lua version: 5.1, 5.2, 5.3, 5.4 (default) or JIT
      --lualib MODE       require (default: one shared lualib_bundle.lua) or inline
      --classpath PATHS   extra jars or class directories, e.g. Lua bindings
      --source-map        write main.lua.map files and make Lua errors and tracebacks show Kotlin positions
                          (on by default with --watch)
      --no-source-map     no source maps, also with --watch
      --check             report errors and unsupported constructs without writing any files
      --watch             rebuild whenever a source file or the project file changes (Ctrl-C to stop)
  -h, --help              show this help
      --version           show the version
```

Each `.kt` file becomes a `.lua` file at the same relative path. Its module name is that path (`util/strings.kt` is
`require("util.strings")`). With `--lualib inline`, each file carries its own copy of the runtime functions it uses
instead of loading `lualib_bundle.lua`.

### `k2l.json`

With no arguments, k2l reads `./k2l.json`, such as `{"srcDirs": ["src"], "outDir": "out", "luaTarget": "5.4"}`. Paths in
the file are relative to it, and command-line options override it. Comments and trailing commas are allowed. An unknown
key is an error that suggests the nearest valid key, and so is a value of the wrong type.

| Key | Meaning | CLI option |
|---|---|---|
| `srcDirs` | Kotlin source directories | `SOURCE_DIR...` |
| `outDir` | output directory (default `out`) | `-o`, `--out` |
| `luaTarget` | `5.1`, `5.2`, `5.3`, `5.4` or `JIT` | `-t`, `--target` |
| `luaLibImport` | `require` or `inline` | `--lualib` |
| `classpath` | extra jars or class directories | `--classpath` |
| `sourceMap` | source maps (default: on with `--watch`, off otherwise) | `--source-map`, `--no-source-map` |

### Gradle plugin

The `gradle-plugin` project provides the plugin `dev.k2l`. Until it is published, use it from a checkout of this
repository as an included build:

```kotlin
// settings.gradle.kts
pluginManagement {
    includeBuild("/path/to/k2l")     // makes the plugin `dev.k2l` available
}
includeBuild("/path/to/k2l")         // resolves the compiler it runs (dev.k2l:compiler)

// build.gradle.kts
plugins { id("dev.k2l") }

k2l {
    // All optional; these are the defaults:
    sourceDirs.setFrom("src/main/kotlin")
    outputDir.set(layout.buildDirectory.dir("lua"))
    luaTarget.set("5.4")              // 5.1, 5.2, 5.3, 5.4 or JIT
    luaLibImport.set("require")       // or "inline"
    sourceMap.set(false)
    classpath.from(files("libs/bindings.jar"))   // extra Lua bindings
}
```

- `./gradlew compileKotlinToLua` writes the Lua files to `build/lua`, and `assemble` runs it. It is up to date while the
  sources, options and compiler are unchanged, and it supports the configuration cache.
- `./gradlew k2lCheck` runs [`k2l --check`](#diagnostics-and-k2l---check). It is not part of `check`; add
  `tasks.check { dependsOn("k2lCheck") }` if you want it there.

The compiler runs in a separate JVM on its own classpath (the `k2lCompiler` configuration), so the Analysis API jars
never reach your build classpath. When the Kotlin JVM plugin is applied too, `dev.k2l:lua-api` is added to `compileOnly`,
so the [interop annotations](#lua-interop) resolve in the IDE. The plugin runs the compiler on JDK 21: Gradle's own JVM
when it is 21 or newer, otherwise a toolchain.

### Diagnostics and `k2l --check`

Kotlin compile errors stop the build, and so does every construct k2l cannot translate. Each diagnostic shows its
position, the source line and the problem underlined, and a hint where a simple workaround exists:

```
/path/to/src/main.kt:5:19: error: Unsigned type 'UInt' is not supported yet
    val n: UInt = 3u
                  ^^
  hint: use Int or Long: numbers are Lua numbers, and Lua has no unsigned ones
/path/to/src/main.kt:6:13: error: Regex alternation `|` is not supported (Lua patterns have no alternation)
    val r = Regex("cat|dog")
            ^^^^^^^^^^^^^^^^
k2l: checked 1 file(s): 2 errors, 0 warnings
```

A build with errors writes nothing. `k2l --check` takes the same options as a build and reports every problem without
writing any Lua, for example before you port existing code, or in CI. It exits with status 1 when there are errors, 2
for a bad command line or `k2l.json`, and 0 otherwise.

### Source maps and watch mode

With `--source-map` (or `"sourceMap": true`), k2l writes a [Source Map v3](https://sourcemaps.info/spec.html) file next
to each Lua file (`main.lua.map`). It also embeds a line table in each Lua file and rewrites Lua positions to Kotlin ones
in error messages and tracebacks, including the ones `debug.traceback` returns:

```
AppError: load failed
stack traceback:
	main.kt:51: in function <main.kt:3>
	...
```

`k2l --watch` builds once, then rebuilds whenever a `.kt` file under the source directories or the `k2l.json` changes. It
re-reads `k2l.json` on every rebuild. Source maps are on by default in watch mode, and off for one-off builds and the
Gradle plugin unless you set them.

## Language features

Almost all of the Kotlin language compiles to the Lua you would write by hand:

| Kotlin | Lua |
|---|---|
| functions, top-level `val`/`var` | `local function`, `local`; public declarations are also exported in the file's module table |
| `if`/`when`/`try` as expressions, `when` with subjects, ranges and guards | `if` chains, or `a and b or c` where that is safe |
| `for` over ranges, `downTo`, `step`, `until`; `while`, `do`/`while` | numeric `for`, `while`, `repeat` |
| `break`/`continue`, labeled too | `goto` (flags and `repeat ... until true` on Lua 5.1) |
| classes, interfaces, `object`, companion objects, `enum class`, `data class`, `sealed` | metatable-based classes: `Point.new(1, 2)`, `p:distance(q)`; data classes get `toString`, `equals`, `hashCode`, `copy` and `componentN` |
| inheritance, abstract and open members, `super` calls, interface default methods | the superclass's table as the `__index` chain |
| inner, nested, local and anonymous classes (`object : Greeter { }`) | classes; captured locals are upvalues |
| `x?.y`, `x ?: y`, `x!!`, smart casts | `x and x.y`, `x or y` where safe, a null check that throws `NullPointerException` |
| `is`, `as`, `as?` | metatable checks; a failed `as` throws `ClassCastException` |
| lambdas, function references, function types, `fun interface` | Lua closures |
| extension functions and properties | plain functions taking the receiver first |
| default and named arguments | `if x == nil then x = default end` in the callee |
| `vararg` and `*spread` | Lua varargs |
| overloads | `describe`, `describe__1`, ... |
| operator overloading, `get`/`set`/`invoke`/`contains`/`compareTo`, destructuring | method calls; `componentN` |
| `inline fun`, `reified` type parameters, non-local `return`, `break` and `continue` from lambdas | expanded at the call site where needed, else an ordinary function |
| `let`, `apply`, `also`, `run`, `with`, `use`, `buildString`, `buildList`, ... | inlined |
| generics, variance, type aliases, contracts | erased |
| `lateinit`, `by lazy`, `Delegates.observable`, `by map`, your own `getValue`/`setValue` | fields and small runtime objects |
| interface delegation (`class C(impl: I) : I by impl`) | forwarding methods |
| value classes | a table holding the value (not unboxed) |
| `throw`, `try`/`catch`/`finally` | `error(exception)` and `pcall` |
| `suspend` functions, `sequence { }`, `iterator { }` | Lua coroutines (see [Coroutines](#coroutines-and-sequences)) |
| several files and packages | one Lua module per file, linked with `require`; import cycles work |

Objects, companion objects and enum classes are initialized on first use where an initializer could have visible
effects, and where they are declared otherwise. A file's top-level properties with such initializers wait for their
first read or write, as the JVM initializes a file's class.

What is not supported yet, each a compile error: references to library functions with a `vararg` parameter (`::listOf`)
and to library constructors or properties k2l does not map, delegating library interfaces other than the collections,
`Comparator`, `CharSequence`, `Sequence`, `Iterator`, `Comparable`, `Runnable`, `Callable` and function types, and
`kotlinx.coroutines`.

## Standard library

k2l translates the parts of the Kotlin standard library that map onto Lua. Each is built on Lua's own values:

- **Collections** (`kotlin.collections`, `kotlin.sequences`, `kotlin.comparisons`): `List`, `MutableList`, `Set`, `Map`,
  `ArrayList`, `HashMap`, `LinkedHashMap`, `HashSet`, `ArrayDeque`, the arrays and primitive arrays, `Pair`, `Triple`
  and almost every extension function on them. They are Lua tables: a list keeps its elements in the array part (1-based)
  with a `size` field, and maps and sets keep insertion order. `Sequence` is lazy. Your classes can extend the abstract
  collections, `ArrayList`, `HashMap`, `LinkedHashMap`, `HashSet` and `LinkedHashSet`, or implement the collection
  interfaces. `sortedMapOf`, `toSortedMap`, `sortedSetOf` and `toSortedSet` give sorted maps and sets with the `Map` and
  `Set` operations only.
- **Text** (`kotlin.text`, `StringBuilder`): searching, splitting, trimming, padding, case and number conversions, string
  templates, `Char` predicates, `String.format` on Lua's `string.format`, and `Regex` on [Lua patterns](#regex).
- **Numbers** (`kotlin`, `kotlin.math`, `java.lang.Math`): arithmetic, conversions, bit operations and the math
  functions, on Lua's `math` library. `kotlin.random.Random` draws from `math.random`.
- **The rest of `kotlin`**: ranges and progressions, `Result` and `runCatching`, exceptions, `require`/`check`/`error`,
  `repeat`, `TODO`, `lazy`, the property delegates, `println`/`print`/`readln`,
  `measureTimeMillis`, and `System.currentTimeMillis`/`nanoTime`.
- **Coroutines** (`kotlin.coroutines`): see [Coroutines and sequences](#coroutines-and-sequences).

Not translated, and a compile error when used:

- the unsigned types (`UInt`, `ULong`, `UByte`, `UShort`, their arrays and ranges);
- `java.math` (`BigInteger`, `BigDecimal`) and `kotlin.time` (`Duration`, `Instant`, `Clock`, `measureTime`, time
  sources);
- reflection beyond `::class.simpleName` and the `name` of a callable reference (`KClass`, `javaClass`, `typeOf`,
  `qualifiedName`, the members of `KProperty` and `KFunction`);
- the JDK's own collections and helpers: `TreeMap`, `TreeSet`, `PriorityQueue`, `LinkedList`, `java.util.ArrayDeque`,
  `EnumMap`, `BitSet`, `Collections.*`, `Arrays.*`, `Optional`, `Objects`, streams, the `Comparator` statics;
- the `java.lang` statics of the boxed types (`Integer.toHexString`, `Long.parseLong`, `Character.isDigit`, ...) and
  `Math`'s `*Exact` functions;
- code point and surrogate APIs, `java.util.Locale` and the `Locale` overloads, the Unicode character categories;
- the IEEE bit APIs of `Double`/`Float` (`toBits`, `toRawBits`, `fromBits`, `ulp`, `nextUp`, `nextDown`, `nextTowards`),
  `DeepRecursiveFunction`, and type tests against a primitive array type (`is IntArray`);
- `kotlinx.*` libraries.

When you need one of these, write it in Kotlin, or bind a Lua library with [`@LuaExternal`](#calling-lua-from-kotlin).

### Regex

`Regex` is Kotlin's API on Lua patterns, with the part of the regex syntax that Lua patterns can express. The compiler
translates the pattern, so a pattern must be a compile-time constant string (`Regex("[a-z]+")`, `"\\d+".toRegex()`).
A pattern built at run time is a compile error, and so is a construct that Lua patterns lack, which the error names.
`Regex.fromLiteral(text)` and `Regex(Regex.escape(text))` work with any `text`: they search for the text itself.

Supported:

- literal characters, with Lua's magic characters escaped; `\t \n \r \f \a \e \0oo \xhh \uhhhh` and `\Q...\E`;
- `.`, classes `[a-z_]` and `[^...]`, and `\d \D \s \S \w \W` (also inside classes, except `\W`);
- `^` at the start and `$` at the end of the pattern;
- `*`, `+`, `?`, and the lazy `*?` and `+?`, on one character or class; `{n}`, `{n,}` and `{n,m}` up to 20 (expanded);
- groups `(...)` without a quantifier, and back-references `\1` to `\9` to a group closed before them;
- `\b` before or after a word character (Lua's `%f` frontier);
- the options `IGNORE_CASE` (also a leading `(?i)`), `LITERAL`, `DOT_MATCHES_ALL` and `UNIX_LINES`.

Not supported: alternation `|`, quantified groups `(ab)+`, non-capturing, named and atomic groups, lookahead and
lookbehind, `??` and possessive quantifiers, `\p{...}`, `\B`, class intersections, non-ASCII characters in a class or
under a quantifier, other inline flags, and `MULTILINE`, `COMMENTS` and `CANON_EQ`.

The API: `matches`, `containsMatchIn`, `find`, `findAll` (a lazy `Sequence`), `matchEntire`, `matchAt`/`matchesAt`,
`replace` with a replacement string (`$1`) or a transform, `replaceFirst`, `split`, `splitToSequence`, `escape`,
`escapeReplacement`, and the `String` functions taking a `Regex`. A `MatchResult` has `value`, `range`, `groupValues`,
`groups` (whose `MatchGroup`s have a `value` but no `range`), `destructured` and `next()`. `split` and `replace` with a
`String` argument use plain `string.find`, with no pattern.

### Coroutines and sequences

k2l supports the coroutine machinery of the Kotlin standard library on Lua's native coroutines. It does not support
`kotlinx.coroutines`.

- A `suspend` function compiles to an ordinary Lua function, and `suspend fun main` works.
- `block.startCoroutine(completion)` runs `block` in a new Lua coroutine until it first suspends.
- `suspendCoroutine { cont -> }` gives the block a continuation. When nothing resumes it right away, the coroutine
  yields, and a later `cont.resume(x)` or `resumeWithException(e)` continues it.
- Contexts, `ContinuationInterceptor` and `kotlin.coroutines.intrinsics` are supported, so a scheduler or dispatcher can
  be written in plain Kotlin.

`sequence { }` and `iterator { }` run their block in a coroutine that yields at each `yield(x)`, so elements are computed
on demand and infinite generators work. A recursive `yieldAll` goes as deep as the data.

Lua 5.1 cannot yield across `pcall`, which `try` compiles to, so on 5.1 a `try` that can suspend runs its block in a
coroutine of its own. A yield through a C function, such as a `table.sort` comparator, still fails on 5.1.

## Lua interop

The package `dev.k2l.lua` (the `lua-api` module, always on k2l's classpath) declares Lua APIs for Kotlin code.

### Calling Lua from Kotlin

External declarations generate no Lua; references to them use their Lua names.

```kotlin
@file:LuaRequire("lib.greeter")   // these declarations are fields of require("lib.greeter")
package bindings

import dev.k2l.lua.*

external fun greet(name: String): String
external fun divmod(a: Int, b: Int): LuaMultiReturn2<Int, Int>

@LuaExternal                      // a Lua object returned by some function
interface Counter {
    val count: Int
    fun increment(by: Int)        // called as counter:increment(by)
    @NoSelf fun describe(c: Counter): String   // called as counter.describe(c)
}
```

```kotlin
val (q, r) = divmod(17, 5)        // local q, r = ____greeter.divmod(17, 5)
val t = LuaTable<String, Int>()   // local t = {}
t["retries"] = 3                  // t.retries = 3
t.forEach { k, v -> println(k) }  // for k, v in pairs(t) do ... end
Lua.print("raw", 1, true)         // print("raw", 1, true)
```

| Declaration | Meaning |
|---|---|
| `@LuaExternal` | the declaration (or every member of a class, interface or object) is implemented in Lua; `external fun` works too |
| `@LuaName("name")` | the Lua name, when it differs from the Kotlin one; a Lua keyword works (`M["end"](...)`), and an object named `_G` maps its members to globals |
| `@LuaRequire("module")` | on a file, its external declarations are fields of `require("module")`; on a class or object, the module is that class or object |
| `@NoSelf` | call with `.` instead of `:` (members of external objects already are) |
| `definedExternally` | the body of an external property: `val VERSION: String get() = definedExternally` |
| `LuaTable<K, V>` | a plain table: `t[k]`, `t[k] = v`, `length` (`#t`), `has`, `remove`, `forEach` (`pairs`) |
| `LuaMultiReturn2`, `LuaMultiReturn3` | several return values, destructured |
| `Lua`, `LuaOs`, `LuaIo` | some of Lua's globals and of the `os` and `io` libraries |

External classes are constructed with `Class.new(...)`. Kotlin lambdas are Lua functions, and Kotlin lists are Lua
sequences with a `size` field, so they can be passed to Lua functions that read arrays.

### Calling Kotlin from Lua

Every file is a Lua module whose table holds its public top-level declarations, so hand-written Lua can `require` it
by its path under the source directory. `@LuaName("on_load")` on a top-level function or property gives it a Lua-style
name in that table.

```lua
local mod = require("mods.Greeter")
mod.on_load(host)                                           -- a top-level function: `.`
local v = require("shared.Events").Version:parse("2.10")   -- object and companion members: `:`
print(tostring(v), v.major)                                 -- tostring() of an object is its toString()
```

Constructors are `Class.new(...)`. Plain properties are fields, and properties with custom getters are methods
(`e:getAlive()`). A plain Lua array is not a Kotlin `List`. Kotlin exceptions reach Lua's `pcall` as objects with a
`message` field, and Lua errors reach Kotlin as `RuntimeException`. To drive Kotlin coroutines from Lua, export a Kotlin
function that starts them (calling `startCoroutine`) and one that resumes your scheduler.

## Lua targets

| Target | Numbers | Bitwise operations | Notes |
|---|---|---|---|
| `5.4` (default), `5.3` | 64-bit integers and doubles, `//` | native operators | |
| `5.2` | doubles only | `bit32` | |
| `5.1` | doubles only | plain Lua | no `goto`: `continue` and labeled jumps use flags; a `try` that suspends runs in a coroutine |
| `JIT` (LuaJIT 2.1) | doubles only | the `bit` library | usually the fastest; has `goto` |

A program behaves the same on every target, except for the [numbers](#numbers). The test cases record each target's
output where it differs from 5.4's (see [Tests](#tests)).

## Caveats

k2l keeps Kotlin's static semantics, but at run time it uses Lua's values and library. These are the differences from
Kotlin/JVM that a program can see.

### Numbers

- `Int`, `Long`, `Short`, `Byte`, `Float` and `Double` are all Lua numbers. Arithmetic does not wrap to 32 bits:
  `Int.MAX_VALUE + 1` is `2147483648`. On Lua 5.3 and 5.4, integers are 64-bit and wrap there.
- On Lua 5.1, 5.2 and LuaJIT, every number is a double: `Long` is exact only up to 2^53, and a large `Long`
  prints as `9.2233720368548e+18`.
- `Float` is not rounded to single precision.
- `/` of two integers is floor division (`//`, or `math.floor(a / b)` before 5.3), so `-7 / 2` is `-4`. `%`, `rem` and
  `mod` are Lua's `%`, whose result has the sign of the divisor: `-7 % 3` is `2`. An integer division by zero is Lua's
  error on 5.3 and 5.4, and infinite or NaN before.
- `toInt()` and `toLong()` of a `Double` truncate toward zero. Conversions between integer types (`toByte()`,
  `toShort()`, `toInt()`) return the number unchanged.
- Bitwise operations of an `Int` wrap to 32 bits. Shift distances outside `0..31` give different results on LuaJIT and
  on the other targets. On 5.1, 5.2 and LuaJIT, `Long`'s `and`, `or` and `xor` are 32-bit, and its shifts are exact only
  below 2^53.
- Numbers print with Lua's `tostring`: 14 significant digits, `1e+20`, `inf`, `-nan` or `nan`. An integral `Double` prints
  as `2.0` on 5.3 and 5.4 but as `2` on 5.1, 5.2 and LuaJIT, where it is the same value as the `Int` `2`.
- `String.toDouble()` is `tonumber`, so `"NaN"`, `"Infinity"` and `"1.5f"` do not parse.
- `kotlin.math` is Lua's `math`, plus short formulas for what Lua lacks (`hypot`, `cbrt`, `expm1`, `ln1p`, the hyperbolic
  functions). Results can differ from the JVM's in the last digits.
- `==` of two numbers is Lua's `==`, also through `Any` and `equals`: `-0.0` equals `0.0`, and NaN equals nothing, so it
  cannot be a map key.

### Strings

- Strings are Lua's byte strings. `length`, indexes and ranges count UTF-8 bytes, so `"héllo".length` is 6.
- A `Char` is a one-byte string, so a `Char` held as `Any` passes `is String`.
- `uppercase()` and `lowercase()` are `string.upper` and `string.lower`, and `isLetter()`, `isDigit()`,
  `isWhitespace()` and the other predicates are ASCII tests. Strings compare and hash by bytes.
- Code point APIs (`codePointAt`, `codePoints()`, `appendCodePoint`, ...) are compile errors.

### Collections

- `HashMap` and `HashSet` keep insertion order, like `LinkedHashMap` and `LinkedHashSet`.
- `keys`, `values` and `entries` are snapshots taken when they are read: a later change to the map does not show in them.
  Removing from them does remove from the map. `for (k in map.keys)` and `k in map.keys` read the map directly
  (`k in map.keys` is `containsKey`).
- `subList` and `asList` return copies, not views: writes to them do not reach the original.
- Read-only collections are mutable at run time: `listOf(1, 2) is MutableList<*>` is `true`.
- Changing a collection while iterating over it is not detected: there is no `ConcurrentModificationException`. A
  `for` loop runs up to the size the collection had when the loop started.
- Sorting (`sorted`, `sortedBy`, `sortWith`, ...) is a stable merge sort, but it does not call comparators in the order the
  JDK does.

### Library behaviour

- `Random.Default` is `math.random`. Lua 5.4 seeds it randomly at startup; on the other targets, call `math.randomseed`
  (bound with `@LuaExternal`) if you want different numbers on every run. `Random(seed)` is a small generator of k2l's
  own: its numbers are the same on every target, but not the JVM's.
- `String.format` is Lua's `string.format`. A constant format is checked at compile time: `%n`, `%s`/`%S`, `%b`, `%c` and
  the `,` flag of `%d` and `%f` are translated, and argument indexes (`%1$s`), `%<s`, `%(d`, `%h` and date formats are
  errors. Other formats are translated at run time, where those specifiers are errors. Rounding is the interpreter's:
  a value exactly halfway (`"%.2f".format(0.125)`, `"%.0f".format(2.5)`) can round differently between LuaJIT builds
  and PUC Lua.

### Regex matching

- Only the subset described in [Regex](#regex) is supported, and patterns must be compile-time constants.
- Indexes (`range`, `find(input, startIndex)`) count bytes, and classes and `IGNORE_CASE` are ASCII.
- `$` matches only at the very end of the input, not before a final line break.

### Exceptions

- The library's exceptions have the Kotlin and Java class names (`java.lang.IllegalStateException: bad`), with short
  messages that can differ from the JVM's.
- A Lua runtime error is caught as a `RuntimeException` with Lua's message. An overflow of the Lua or the C stack is a
  `StackOverflowError`, which `catch (e: Exception)` does not catch.
- An exception that ends `main` prints its `toString()` and the Lua traceback on stderr, and the program exits with
  status 1. There are no `Caused by:` lines, and `printStackTrace()` prints only the `toString()`.
- Every `try` (and `use`, `runCatching`, ...) runs its block in a `pcall`. Lua 5.1 to 5.4 allow only about 200 nested C
  calls, so a recursion with a `try` at each level fails with "C stack overflow" after some 190 levels. LuaJIT goes
  deeper.

### Types and reflection

- Generics are erased, and so are unchecked casts: `x as List<String>` accepts any list, and `x as T` checks nothing.
- The only reflection is `::class.simpleName` (`x::class.simpleName`, `Foo::class.simpleName`, a reified
  `T::class.simpleName`) and the `name` of a callable reference written in place (`::greet.name`). Callable references are
  plain Lua functions.
- `Any.toString()` of a class without its own `toString` is the class name and a counter in hex (`app.P@1f`), not the
  JVM's identity hash; `Any()` prints as `kotlin.Any@1f`.
- All arrays are one Lua class whatever their element type: `is Array<*>` is true of an `IntArray`, `is IntArray` is a
  compile error, and `as IntArray` only checks that the value is an array. An array prints its elements like a list
  (`[1, 2, 3]`), not `[I@1b6d3586`; `==` of two arrays is still identity.
- The unsigned types are not supported.
- A value class is not unboxed: it is a table holding the value.
- A `Unit` returned by Lua code through `@LuaExternal` is `nil`, so it prints as `null`.

## Performance

Plain classes, loops and arithmetic compile to what you would write by hand. The costs are in the library:

- A `Map` or `Set` keeps insertion order, so `remove` takes time linear in the number of entries added after the removed
  one. Removing the most recent entries is cheap. To drop many entries, use `clear` or build a new map.
- `list[i]` on a `MutableList` is bounds-checked on every access (`list:get(i)`). Use `for (x in list)` or `indices`,
  which index the table directly.
- Use `--target JIT` and LuaJIT for CPU-bound programs.

Medians of `./gradlew :compiler:bench` (14 programs, 3 runs each, on the maintainer's machine): the sum over the programs
is about 8.1 s on Lua 5.4, 9.9 s on 5.3, 11.2 s on 5.2, 11.6 s on 5.1 and 2.5 s on LuaJIT.

The compiler itself runs on the JVM, which starts slowly. The start script keeps an AppCDS archive of the loaded classes
in `${XDG_CACHE_HOME:-~/.cache}/k2l`, which makes later runs start about twice as fast. Set `K2L_CDS_DIR` to move it, or
`K2L_NO_CDS=1` to turn it off. Compile time is dominated by the Kotlin analysis; `K2L_PROFILE=1` prints the time of each
phase.

## Development

```sh
./gradlew test                     # transpile and run every test case on every Lua interpreter found
./gradlew test -PupdateGolden      # rewrite expected.lua and the stdout files after an intended change (review the diff)
./gradlew test -Ponly=casts,lazy_objects        # only these cases
./gradlew :compiler:test -PluaTargets=5.1,JIT   # only the tests of these Lua targets
./gradlew check                    # tests, Gradle plugin functional tests, ktlint (spotlessCheck) and detekt
./gradlew :gradle-plugin:functionalTest         # only the TestKit tests of the Gradle plugin
./gradlew spotlessApply            # reformat the Kotlin sources with ktlint
./gradlew :compiler:distZip        # compiler/build/distributions/k2l-<version>.zip, the CLI distribution
./gradlew publishToMavenLocal      # install compiler, lua-api and the plugin into ~/.m2
```

The version of everything, including `k2l --version`, is the `version` in `gradle.properties`. See
[RELEASING.md](RELEASING.md) for cutting a release. Kotlin code is formatted with ktlint and analyzed with detekt
(`config/detekt.yml`), and compiler warnings are errors.

### Tests

Each directory in `compiler/src/test/cases` is a program: `main.kt` (and any other `.kt` files), `expected.lua` (the
exact Lua output for 5.4) and `stdout.txt` (what it prints on Lua 5.4). The tests run each program on every target whose
interpreter is installed (`lua5.1`, `lua5.2`, `lua5.3`, `lua5.4`, `luajit`; override with `-Plua51=/path/to/lua` and
likewise `-Plua52`, `-Plua53`, `-Plua54`, `-Pluajit`). They compare the output with `stdout.txt`, or with
`stdout.<target>.txt` (`stdout.5.1.txt`, `stdout.JIT.txt`) where that target prints something else.

Expected output is never written by hand. `-PupdateGolden` rewrites `expected.lua` and `stdout.txt` from the 5.4 run,
and writes a `stdout.<target>.txt` only where that target's output differs (deleting it when it no longer does). Review
the diff before you commit. A case with `errors.txt` checks the diagnostics instead; `targets-skip.txt` lists targets a
case cannot run on, with the reason; `options.txt` sets compiler options (`luaLibImport=inline`).

`-PluaTargets=5.1,JIT` runs only the compiler tests of those targets, and a missing interpreter then fails instead of
skipping. The tests that are not about one target (the golden output, the `errors.txt` cases, the CLI, ...) go with
`5.4`. CI runs `:compiler:test` in three shards (`-PluaTargets=5.4`, `5.1,JIT` and `5.2,5.3`) next to the rest of
`check` (`-x :compiler:test`), and its `test` job passes only when all of them pass.

### Benchmarks

`compiler/src/bench/programs` holds 14 programs adapted from the `realworld_*` test cases and scaled up to run for about
0.5 to 2.5 s on Lua 5.4: collections (`coll_*`), strings (`str_*`), classes and lambdas (`oop_*`) and numbers (`num_*`).
Each one prints a small checksum, checked like a test case's `stdout.txt`.

```sh
./gradlew :compiler:bench                          # every program on every Lua found, 5 runs, compared with the baseline
./gradlew :compiler:bench -PbenchRuns=3 -PbenchOnly=coll_grid,str_parse -PbenchTargets=5.4,JIT
./gradlew :compiler:bench -PbenchSave              # also write compiler/src/bench/baseline.json (or -PbenchSave=other.json)
./gradlew :compiler:bench -PbenchCompare=other.json   # compare with another file (-PbenchCompare=none: no comparison)
./gradlew :compiler:bench -PbenchProfile           # a sampling profile on 5.4 and LuaJIT instead of timings
./gradlew :compiler:bench -PupdateGolden -PbenchRuns=1   # rewrite the programs' stdout files
```

A run fails a program whose output is wrong, prints the median and minimum wall time per program and target (also in
`compiler/build/bench/results.json` and `results.csv`), and the ratio of each median to the baseline with the geometric
mean per target (below 1.00 is faster). Compare runs from the same machine. `-PbenchProfile` writes a report per program
to `compiler/build/bench/profile/<target>/`, with lines mapped back to Kotlin and to the lualib. The harness is not part
of `check`; `BenchProgramsTest` only checks that the programs transpile.

### Layout

In `compiler/src/main/kotlin/dev/k2l`, `frontend` is the Analysis API session, `transform` turns Kotlin into a Lua syntax
tree (one file per language or library area), and `codegen` prints it. The runtime is plain Lua in
`compiler/src/main/resources/dev/k2l/lualib` (`Name.float.lua` and the like are target-specific variants). `lua-api`
holds the interop declarations, and `gradle-plugin` the Gradle plugin and its TestKit tests.

The Analysis API artifacts come from JetBrains' `intellij-dependencies` repository and must match the Kotlin version
exactly; see the comments in `gradle/libs.versions.toml` before upgrading.
