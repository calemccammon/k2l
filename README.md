# k2l: Kotlin to Lua

k2l transpiles Kotlin source code to readable Lua, in the spirit of
[TypeScriptToLua](https://typescripttolua.github.io/). It uses the official Kotlin compiler's
[Analysis API](https://kotlin.github.io/analysis-api/) to parse and type-check your code, then
generates readable Lua, close to what you would write by hand:

```kotlin
data class Item(val name: String, val price: Int)

fun cheapest(items: List<Item>): String? =
    items.filter { it.price > 0 }.minByOrNull { it.price }?.name
```

```lua
local ____lambda_1 = function(it) return it.price end
local function cheapest(items)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = items:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it.price > 0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ____receiver = __K2L_ListWrap(____out, ____count):minByOrNull(____lambda_1)
    return ____receiver and ____receiver.name
end
```

Common collection functions with a lambda literal (`filter` here) become loops; the others are methods of the runtime
library (`minByOrNull`). Supported targets are Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT. The test suite (277 programs, 51 of
them realistic applications) runs every program on each target and compares its output with what Kotlin/JVM prints.
In 0.2.0 the generated code runs about twice as fast as it did before this release's optimization work (see
[Performance](#performance)).

## Installation

Requirements: JDK 21 or newer, and a Lua interpreter to run the output.

**Command line.** Download `k2l-0.2.0.zip` (or `.tar`) from the
[Releases](https://github.com/calemccammon/k2l/releases) page, check it against `SHA256SUMS`, unpack it and put
`k2l-0.2.0/bin` on your `PATH`:

```sh
sha256sum -c --ignore-missing SHA256SUMS
unzip k2l-0.2.0.zip
export PATH="$PWD/k2l-0.2.0/bin:$PATH"
k2l --version                 # k2l 0.2.0
```

**Gradle plugin.** Once published, the plugin `dev.k2l` comes from the Gradle Plugin Portal, with its version equal to the
compiler's:

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories { gradlePluginPortal(); mavenCentral() }
}

// build.gradle.kts
plugins { id("dev.k2l") version "0.2.0" }
repositories { mavenCentral() }   // where the plugin finds the compiler (dev.k2l:compiler) and dev.k2l:lua-api
```

The compiler's own POM lists JetBrains-only artifacts (the Kotlin Analysis API) that Maven Central does not have, so
depend on `dev.k2l:compiler` from a Maven build only after adding the JetBrains repositories shown in
`settings.gradle.kts`. The Gradle plugin does not need them: it resolves `compiler-0.2.0-runtime-libs.zip`, a
self-contained archive of everything the compiler runs with.

To build from a checkout instead, see [Quick start](#quick-start).

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
      --int-overflow MODE unchecked (default) or wrap: make Int arithmetic wrap to 32 bits like the JVM
      --strings MODE      bytes (default) or utf16: make String and Char behave like the JVM's UTF-16 strings
      --long64 MODE       double (default) or emulate: exact 64-bit Long and ULong on Lua 5.1, 5.2 and LuaJIT (slower)
      --classpath PATHS   extra jars or class directories, e.g. Lua bindings
      --source-map        write main.lua.map files and make Lua errors and tracebacks show Kotlin positions
                          (on by default with --watch)
      --no-source-map     no source maps, also with --watch
      --check             report errors and unsupported constructs without writing any files
      --watch             rebuild whenever a source file or the project file changes (Ctrl-C to stop)
```

With no arguments, k2l reads `./k2l.json`. Paths in it are relative to the file, and command-line
options override it. Comments and trailing commas are allowed. An unknown key is an error that names the nearest valid
key, and so is a value of the wrong type:

```json
{
  "srcDirs": ["src"],
  "outDir": "out",
  "luaTarget": "5.4",
  "luaLibImport": "require",
  "classpath": [],
  "intOverflow": "unchecked",
  "strings": "bytes",
  "long64": "double",
  "sourceMap": false
}
```

| Key | Meaning | CLI option |
|---|---|---|
| `srcDirs` | Kotlin source directories | `SOURCE_DIR...` |
| `outDir` | output directory | `-o`, `--out` |
| `luaTarget` | `5.1`, `5.2`, `5.3`, `5.4` or `JIT` | `-t`, `--target` |
| `luaLibImport` | `require` or `inline` | `--lualib` |
| `intOverflow` | `unchecked` or `wrap` | `--int-overflow` |
| `strings` | `bytes` or `utf16` (see [Strings](#strings)) | `--strings` |
| `long64` | `double` or `emulate` (see [Lua targets](#lua-targets)) | `--long64` |
| `classpath` | extra jars or class directories | `--classpath` |
| `sourceMap` | source maps and Kotlin positions in errors (default: on with `--watch`, off otherwise) | `--source-map`, `--no-source-map` |

Each `.kt` file becomes a `.lua` file at the same relative path. The runtime support code (the
"lualib") is written once as `lualib_bundle.lua`; each file imports only what it uses. With
`--lualib inline`, each file carries its own copy instead.

### Uncaught exceptions

An exception that ends `main` prints the way the JVM prints it, the same on every target: on stderr,
`Exception in thread "main"` and the exception's `toString()`, a `Caused by:` line for each cause, then the Lua traceback
of the stack it was raised from. The program exits with status 1, after what it printed has been flushed:

```
Exception in thread "main" AppError: load failed
Caused by: java.lang.IllegalArgumentException: java.lang.NumberFormatException: For input string: "x"
Caused by: java.lang.NumberFormatException: For input string: "x"
stack traceback:
	[C]: in function 'error'
	main.lua:65: in function <main.lua:58>
```

The lines up to `stack traceback:` are those of the JVM without its `at` frames. The frames are Lua's, since JVM frames
cannot be reproduced (with [source maps](#source-maps-and-kotlin-tracebacks) they show Kotlin positions). A `catch`
that does not match raises the exception again, so the traceback starts at that `catch` rather than at the `throw`. A Lua
error that is not an exception (a string, as from `Lua.error` or a Lua runtime error) prints its message and the
traceback. This holds for `main()`, `main(args)` and `suspend fun main()`: `main` runs under `xpcall` (or in the
coroutine driver of `try` blocks, see [Other semantic differences](#other-semantic-differences)), which costs nothing
until something is thrown. Without it, Lua 5.1 would print `(error object is not a string)`, Lua 5.2 to 5.4 the
`toString()` alone and LuaJIT the `toString()` and a traceback, each after the program's buffered output. Suppressed
exceptions are not printed: k2l does not record them. The exit uses `os.exit(1)`, so a host embedding Lua that runs
the main file stops as well.

An overflow of the Lua stack (an endless recursion) prints `Exception in thread "main" java.lang.StackOverflowError`,
then Lua's message with the position (`main.lua:5: stack overflow`) and the traceback. On LuaJIT, `main` runs in a
coroutine instead of under `xpcall`: when the overflow happens in compiled code (a trace), LuaJIT unwinds the stack
without calling the `xpcall` handler, so the traceback was lost and only `stack overflow` printed. A coroutine stopped by
an error keeps its stack, which the traceback is read from after the resume. The frame of the trace itself shows no line
(`main.lua: in function 'down'`); the frames below it do.

## Diagnostics and `k2l --check`

Kotlin compile errors are reported and stop the build. Kotlin features k2l can't translate yet are
reported as `error: ... is not supported yet`; k2l never silently miscompiles a construct it doesn't understand.
Like kotlinc, k2l prints each diagnostic with its position, the source line and the problem underlined. Where a cheap
and correct workaround exists, it adds a one-line hint:

```
src/main.kt:5:8: error: 'appendCodePoint' without --strings utf16 is not supported yet
    sb.appendCodePoint(0x1F600)
       ^^^^^^^^^^^^^^^^^^^^^^^^
  hint: compile with --strings utf16 (k2l.json: "strings": "utf16") to get the JVM's UTF-16 strings
src/main.kt:9:37: error: Reference to the library constructor 'java.util.concurrent.atomic.AtomicInteger' is not supported yet
    val make: () -> AtomicInteger = ::AtomicInteger
                                    ^^^^^^^^^^^^^^^
  hint: use a lambda instead of the reference, e.g. { AtomicInteger() }
k2l: 2 errors, 0 warnings; no files written
```

A hint shared by several diagnostics is printed under the first one only, and a construct that the compiler reaches
more than once is reported once. A build with errors writes nothing.

To see everything k2l would reject without writing any Lua (for example, before porting an existing code base, or
in CI), run a check:

```sh
k2l --check                # the project in ./k2l.json
k2l --check -t 5.1 src     # the same options as a build; they decide what is supported
```

It analyzes and transforms every file exactly as a build does, prints every diagnostic, and ends with
`k2l: checked 12 file(s): 2 errors, 0 warnings`. It exits with status 1 when there are errors, 2 for a bad command
line or k2l.json, and 0 otherwise. It skips printing Lua and writing files, but most of a build's time goes to the Kotlin
analysis, which a check still does, so it saves only a little time. In the Gradle plugin the same check is the
`k2lCheck` task.

## Source maps and Kotlin tracebacks

With `--source-map` (or `"sourceMap": true`), and by default in [watch mode](#watch-mode), k2l records the
Kotlin position of every statement it generates and writes a standard [Source Map v3](https://sourcemaps.info/spec.html) file next to each Lua
file (`main.lua.map`, `sources` relative to the map, VLQ `mappings`). Statements are mapped with line and
column; expressions inside a statement share its position. The Lua file ends with a
`--# sourceMappingURL=main.lua.map` comment. Without source maps the generated Lua is unchanged.

Source maps are a debugging aid, so they are on by default only with `--watch`, the development loop. A one-off build
(`k2l`, the Gradle plugin's `compileKotlinToLua`) produces the plain Lua you would ship. Explicit settings win:
`--source-map` or `"sourceMap": true` turns them on for any build, and `--no-source-map` or `"sourceMap": false` turns
them off in watch mode too.

The same information is embedded in each Lua file as a compact line table, and a small runtime helper
rewrites Lua positions to Kotlin ones in error messages and tracebacks (Lua 5.1 to 5.4 and LuaJIT), so an
[uncaught exception](#uncaught-exceptions) prints a Kotlin trace:

```
Exception in thread "main" java.lang.IllegalStateException: insufficient funds
stack traceback:
	[C]: in function 'error'
	main.kt:4: in method 'withdraw'
	main.kt:13: in upvalue 'process'
	main.kt:18: in function <main.kt:16>
```

instead of `main.lua:15:`, `main.lua:26:` and so on. `debug.traceback` is wrapped as well, so tracebacks
you print yourself are rewritten. Lines of the lualib itself (and inlined lualib code) keep their Lua
positions. A Lua line that starts no statement (such as a closing `end`) reports the nearest statement
before it.

## Watch mode

`k2l --watch` builds once (with [source maps](#source-maps-and-kotlin-tracebacks) unless they are turned off) and
then rebuilds whenever a `.kt` file under the source directories (or the `k2l.json`) is created, changed or deleted, printing the diagnostics each time. Changes within 150 ms
are batched. It re-reads `k2l.json` on every rebuild, so editing source directories or options takes
effect without a restart. A new analysis session is created for each build: once the JVM is warm that costs
about 250 ms for a small project (the first build takes about 2 s), so sessions are not reused. Stop with Ctrl-C.

## Gradle plugin

The `gradle-plugin` project provides the plugin `dev.k2l`. Besides the published plugin (see [Installation](#installation)), you can use it from a checkout
of this repository as an included build, in the `settings.gradle.kts` of your project:

```kotlin
pluginManagement {
    includeBuild("/path/to/k2l")     // makes the plugin `dev.k2l` available
}
includeBuild("/path/to/k2l")         // resolves the compiler it runs (dev.k2l:compiler)
```

```kotlin
plugins {
    id("dev.k2l")
}

k2l {
    // All optional; these are the defaults:
    sourceDirs.setFrom("src/main/kotlin")
    outputDir.set(layout.buildDirectory.dir("lua"))
    luaTarget.set("5.4")              // 5.1, 5.2, 5.3, 5.4 or JIT
    luaLibImport.set("require")       // or "inline"
    intOverflow.set("unchecked")      // or "wrap"
    strings.set("bytes")              // or "utf16"
    long64.set("double")              // or "emulate": exact Long/ULong on Lua 5.1, 5.2 and LuaJIT
    sourceMap.set(false)
    classpath.from(files("libs/bindings.jar"))   // extra Lua bindings
}
```

`./gradlew k2lCheck` runs [`k2l --check`](#diagnostics-and-k2l---check): it reports every error and unsupported
construct, writes no Lua and fails the build if there are errors. It is up to date while the sources and options are
unchanged, and it is not part of `check`, so `build` does not analyze the sources twice. Add
`tasks.check { dependsOn("k2lCheck") }` if you want it there. Source maps stay off unless `sourceMap` is set, as in a
one-off CLI build. To turn them on for development only, pass a property, for example
`sourceMap.set(providers.gradleProperty("k2l.debug").map { true }.orElse(false))` with `./gradlew compileKotlinToLua -Pk2l.debug`.

`./gradlew compileKotlinToLua` writes the `.lua` files (and `.lua.map` files) to `build/lua`; `assemble` runs it.
The task is up to date while sources, options and compiler are unchanged, is compatible with the configuration
cache, and fails the build with the compiler's diagnostics (`file:line:col: error: ...`) on a Kotlin error. The
compiler runs in a separate JVM (`javaexec`) on its own classpath, which is the `k2lCompiler` configuration (by
default `dev.k2l:compiler:<plugin version>`), so the Analysis API jars never reach the build classpath. The
`@LuaExternal` annotations are always on the transpiler's classpath; if the Kotlin JVM plugin is applied too,
`dev.k2l:lua-api` is also added to `compileOnly`. The plugin needs JDK 21 to run the compiler (Gradle's own JVM if
it is 21 or newer, otherwise a toolchain).

## How Kotlin maps to Lua

| Kotlin | Lua |
|---|---|
| `fun f(x: Int) = x + 1` | `local function f(x) return x + 1 end` |
| top-level declarations | locals; public ones are exported in the module table |
| `val`/`var` | `local` |
| `if`/`when` as values | `if` chains assigning to the target, or `c and a or b` when that's safe; a `when` guard (`is Int if x > 0 ->`) joins its branch's condition with `and` |
| `for (i in 0 until n)`, `downTo`, `step` | numeric `for`; a step that is not a positive constant goes through `__K2L_CheckStep` (`IllegalArgumentException`, as `step` throws) |
| `x in a..b`, `x !in a until b`, `in a..b ->` | `x >= a and x <= b`; with a step (`x in a..b step s`, also `downTo`) `and (x - a) % s == 0`, so only the progression's elements match (a
`ULong` compares with `math.ult` and an unsigned remainder on 5.3/5.4; a range of other Comparables, such as enum entries or
classes of the program, compares with `compareTo`). The range's operands are evaluated before `x`, as in Kotlin |
| `for (x in list)` | `for i = 1, list.size do local x = list[i] ... end` (checked for changes of the list, see below) |
| `for ((k, v) in map)`, `for (k in map.keys)` | a numeric `for` over the map's arrays: `local keys, values, n = map:____arrays()`, then `for i = 1, n do local k, v = keys[i], values[i] ... end` |
| `for (c in s)` with `s: CharSequence`, or a `StringBuilder` | `for c in __K2L_Text.chars(s) do`: the chars of a string, else the value's `get(i)` while `i < length`, both read at each step like the JVM's iterator. `length`, `s[i]`, `lastIndex` and `indices` of a `CharSequence` (`__K2L_Text.charsLength(s)`, `charsGet`) call the members of a `StringBuilder` or a class of the program; the String functions (`contains`, `split`, ...) run on its text, also for a `StringBuilder` passed where they take a `CharSequence` (`"abc".contains(sb)`) |
| `continue`, labeled `break`/`continue` | `goto` (flags and `repeat ... until true` on Lua 5.1); a label on anything but a loop only names a lambda for `return@label` and is otherwise ignored |
| `a / b` on `Int`, `a % b` | `__K2L_IDiv(a, b)` (truncating); `a % b` is `b ~= 0 and fmod(a, b) or __K2L_IRem(a, b)`. By a positive literal both use Lua's operators (`a >= 0 and a // 4 or 0 - -a // 4` on 5.3/5.4). Integer division by zero throws `ArithmeticException("/ by zero")` |
| string templates | `..` concatenation; values formatted like Kotlin's `toString()` |
| `class`, `interface`, `object`, `enum class`, `data class` | metatable-based classes named with their JVM binary name: `local Point = __K2L_Class("app.Point")`, `Point.new(1, 2)`, `p:distance(q)` |
| `object : Greeter { ... }`, `object : Base(1), I { }`, `object { val x = 1 }` | a local object declared where the expression is evaluated (`local ____object = __K2L_Class("app.MainKt$main$1", nil, Greeter)`), initialized right away; like a named `object`, its table is the instance. Its methods are closures, so they read and assign captured locals; `this@Outer` is kept in a local (`local ____this = self`). Members of the anonymous type, `by` delegation and overriding work as for classes |
| `p.toString()`, `"$p"`, `println(p)` for a class without `toString()` | `__K2L_Str(p)`, which gives `Any.toString()`: the binary class name and `hashCode()` in hex (`app.P@1f`). The hash of an object is a counter, not the JVM's address-like number |
| primary/secondary constructors, `init` | `Class:____init(...)`, chained to the superclass |
| properties | table fields; custom accessors become `getX()`/`setX()` methods (for open, overriding and interface properties, in every member of the override family; `override val message` on an exception is also what lualib code reading `e.message` sees) |
| `lateinit var name: String` | a plain field or local; a read is `self.name or __K2L_Uninitialized("name")` (a lateinit value is never nil or false), which throws `UninitializedPropertyAccessException`; `::name.isInitialized` is `self.name ~= nil` |
| top-level properties with custom accessors | functions `getNow()` / `setTotal(v)`, exported like any function; a backing field is a hidden local `____total_field`; reads, writes, `+=` and `++` call them |
| companion objects | members on the class table: `Point:of(1, 2)` (when the companion has no supertypes and no member named like a member of the instances, such as `fun ok()` next to `val ok` or `toString`; otherwise it is an object of its own, as below) |
| `companion object : Factory<Point>` (interfaces, classes of the program) | an object of its own, a field of the class named like the companion: `Point.Companion = __K2L_Class("Companion", nil, Factory)`, `Point.Companion:create()`. `Point` used as a value (`val f: Factory<Point> = Point`, `make(Point)`, `is`, `as`) is `Point.Companion`; constructing a `Point` initializes it like the JVM does |
| `inner class` | a nested class whose instances keep `self.____outer`; `outer.Inner(x)` is `Outer.Inner.new(outer, x)` and `this@Outer` is `self.____outer` |
| enum entries with bodies, `values()`, `entries`, `valueOf` | each body is an anonymous subclass of the enum: `Op.PLUS = ____PLUS.new("PLUS", 0, "+")`; `__K2L_EnumValues(Op)` (also through the companion's implicit receiver). Enums are `Comparable` by ordinal: every enum class has `compareTo`, so `<`, `sorted()`, `maxOf`, `TreeSet` and `compareBy { it.level }` work |
| `data object Quit`, `value class Id(val raw: Int)` | a `data object` gets `toString()` (its name) and `hashCode()` (the hash of its qualified name, as Kotlin generates). A value class is not unboxed: it is a table holding the value, with a data class's `equals`, `hashCode` and `toString` (`Id(raw=7)`), so it works as a map key and in sets |
| `==` | `==` for primitives/enums/objects, `equals()` when a class may override it |
| `is`, `as?` | `getmetatable(x) == Class` for a final class (read once per `when`), else `__K2L_InstanceOf(x, Class)`; `type(x) == "string"`, ...; `is Number`, `is Comparable<*>` and `is CharSequence` are `__K2L_IsNumber(x)` (a Lua number, `BigInteger`, `BigDecimal`), `__K2L_IsComparable(x)` (numbers, strings, booleans, enums, `BigInteger`/`BigDecimal`, `StringBuilder` (Comparable since Java 11) and classes of the program implementing `Comparable`, directly or through a superclass or interface: their table has `____comparable = true`, so objects count and a class with only an `operator fun compareTo` does not; a companion sharing the table of such a class is marked `____companion`, as it is not Comparable itself) and `__K2L_IsCharSequence(x)` (strings, `StringBuilder` and objects with `subSequence`: a class of the program implementing `CharSequence` is told by its methods). `Number.toInt()`, `toDouble()`, ... pick the conversion at run time |
| `x as T`, `x as T?` | a check unless the static type already guarantees it (upcasts, smart casts, type parameters): `__K2L_CastFail` throws `ClassCastException` (`class A cannot be cast to class B (...)`, JVM wording) or `NullPointerException` for null. Only the erased class is checked (`as List<String>` accepts any list, `as T` of an erased `T` checks nothing); the values such unchecked casts pass on are checked later, where the JVM checks them (see [Other semantic differences](#other-semantic-differences)) |
| `object`, companion objects, enums | initialized where they are declared when that is unobservable (constants, literals, collection factories, plain constructors); otherwise on first access, see [Lazy initialization](#lazy-initialization) |
| `x?.y`, `x ?: y`, `x!!` | `x and x.y`, `x or y` (when safe), `__K2L_NotNull(x)` |
| lambdas, function references | Lua closures |
| `class C(impl: I) : I by impl`, `: I by Impl()`, also on objects and companions | the constructor stores the delegate in `self.____delegate_I` (after the superclass constructor, before the initializers); every member of `I` and its superinterfaces that `C` does not declare, default methods and property accessors included, is a forwarding method `function C:greet(...) return self.____delegate_I:greet(...) end`. `toString`/`equals`/`hashCode` are forwarded only when `I` declares them. Properties of a delegated interface use `getX()`/`setX()` in their whole override family |
| `class Logged(inner: MutableList<Int>) : MutableList<Int> by inner`, `: Comparator<T> by cmp`, `: Map<K, V> by m`, `: CharSequence by s`, `: (Int) -> Int by f` | the class implements the library interface as if it declared it (the lualib base or SAM mixin below), and each member Kotlin delegates (the abstract ones the class does not override, not Java's default methods such as `removeIf`) is a method calling it on `self.____delegate_MutableList` as a call on a value of the interface type compiles (`self.____delegate_Comparator(a, b)`, `__K2L_StringCharAt(self.____delegate_CharSequence, i)`). The library's functions, `for` loops and the default methods run on the class's members, so they see its overrides; `toString`/`equals`/`hashCode` are `Any`'s, as on the JVM. Delegatable: the collection interfaces, `Iterator`/`ListIterator`, `Map.Entry`, `Comparable`, `CharSequence` (the String functions read the delegate's text), `Sequence`, `Comparator`, `Runnable`, `Callable` and function types |
| `::ArrayList`, `::Pair`, `::StringBuilder`, `::IllegalStateException`, `::Regex`, ... | a function making the call of the constructor the reference resolves to (the expected type picks the overload): `function(____p1) return __K2L_Regex.new(____p1) end` |
| `let`, `apply`, `also`, `run`, `with`, `forEach`, `buildString`, ... | inlined, so `return`, `break` and `continue` inside them work as in Kotlin (a `break` or `continue` out of a lambda expanded into a loop is a `goto` to the label of the loop around the call; on Lua 5.1 it sets a flag and breaks out of each loop in between) |
| your own `inline fun` | an ordinary function, unless a lambda argument has a `return` out of the caller (or a `break`/`continue` of a loop around the call) or a type parameter is `reified`: then the body is expanded at the call site (arguments evaluated once, lambdas inlined where the body invokes them, the body's `return` is a `goto`), so a non-local `return` leaves the caller and `is T` checks the actual type. A lambda parameter the body passes on to a function that is not expanded (`s.trim(predicate)`) is the lambda as a closure. `noinline`/`crossinline` lambdas stay closures. A `vararg` parameter is bound to an `Array` built from the arguments (spreads `*xs` included, also before other arguments). Locals of the caller that have the name of a top-level declaration the body uses get a fresh Lua name (`____limit`), so the expansion still sees the declaration |
| extension functions | plain functions taking the receiver first: `shout("hi")` |
| extension properties | `getLastChar(s)` / `setLastChar(s, v)`: functions taking the receiver first |
| extension functions and properties declared in a class | methods taking the extension receiver as their first argument: `function Builder:unaryPlus(____this)`, `builder:unaryPlus("x")`; `this` is `____this` and `this@Builder` is `self`. Properties are `builder:getTag(s)` / `builder:setTag(s, v)` (same-named ones, `val String.x` and `val Int.x`, are `getX` and `getX__1`); operators such as `+"x"` work, also inside `with(builder) { }` |
| `super.toString()`, `super.equals(o)`, `super.hashCode()` | `__K2L_AnyToString(self)` (`Name@hex`, as on the JVM), `self == o` (identity), `__K2L_IdentityHash(self)` (the hash `Map`/`Set` give objects without `hashCode()`); on exceptions `super.toString()` is `Throwable.toString` and `super.message`/`super.cause` are fields |
| delegated properties (`by`) | `provideDelegate` is called once when the delegate is stored, `getValue`/`setValue` may be extensions, open and overriding ones are accessor families with a delegate slot per class; the delegate lives in `self.____x_delegate` (a local `____x_delegate` outside classes); reads and writes call its `getValue`/`setValue` |
| `by lazy { }`, `Delegates.observable`/`vetoable`/`notNull`, `ReadOnlyProperty { }`, `by map`, your own `getValue`/`setValue` | lualib objects with the same methods; `by map` reads `map:getValue("x")` |
| default and named arguments | `if x == nil then x = default end` in the callee; callers pass `nil` for omitted ones. An override applies the defaults it inherits (`override fun render(indent: String)` of `fun render(indent: String = "")`), with the overridden function's parameter names mapped to its own |
| overloads | `describe`, `describe__1`, ... (overrides keep their parent's name); a method named like a property of its class, a superclass or a subclass (`private val items` and `fun items()`) is `items__1`, as Lua tables hold fields and methods in one namespace |
| `vararg`, `*spread` | Lua varargs packed into an array (also for constructors); `table.unpack`. A spread that is not last (`listOf(*xs, y)`, `f(*a, *b)`) makes the rest of the arguments one `__K2L_Spread("s.", xs, y)`, which returns all the elements. A `vararg` parameter that is not the last one still comes last in Lua (`fun row(vararg cells: String, width: Int = 5)` is `function row(width, ...)`, called `row(3, "a", "b")`). A reference to a function with a `vararg` used as a function taking the `Array` (`val f: (IntArray) -> Int = ::sum`) unpacks it: `function(____p1) return sum(__K2L_Unpack(____p1)) end` |
| `::method`, `::property` inside a class or object | bound to `this` (or the object), as in Kotlin |
| `var (a, b) = pair` | two locals, which can be reassigned |
| `throw`, `try`/`catch`/`finally` | `error(exception)`, `pcall`; JVM exception classes and messages. A `return`, `break` or `continue` (labeled too) out of the `try` or a `catch` returns a code from the `pcall`ed function (`return true, x` for `return`, `return 1` for the first jump, ...); after the `pcall` and the `finally` code, the matching `return`/`break`/`goto` is re-issued |
| `x::class`, `Foo::class`, `T::class` (reified), `.simpleName`, `.qualifiedName`, `isInstance`, `javaClass` | `__K2L_KClassOfValue(x)`, `__K2L_KClassOf(Foo)`, `__K2L_KClassNamed("kotlin.String")`: one object per class, so `==` is identity; `javaClass` is `__K2L_JavaClass(...)` of it; see [Reflection](#reflection) |
| `return` inside `map { }`, `filter { }`, `any { }`, `first { }`, `fold`, ... | a lambda with a `return` out of the enclosing function (or a `break`/`continue` of a loop around the call) makes the call an inlined loop: `local r = __K2L_ListOf(); for _, it in ipairs(xs) do ... return ... r:add(v) end`. Without such a `return`, `map`, `mapIndexed`, `mapNotNull`, `filter`, `filterNot`, `filterIndexed`, `flatMap`, `count`, `any`, `all`, `none`, `sumOf`, `first`, `firstOrNull`, `find`, `maxOf`, `minOf`, `groupBy`, `associateBy` and `associateWith` with lambda literals on lists, arrays and sets are still loops (over `xs:____array()`, wrapped with `__K2L_ListWrap`), and the rest are ordinary method calls. Expanded this way: `map`, `mapNotNull`, `filter`, `filterNot`, `takeWhile`, `flatMap`, `any`, `all`, `none`, `count`, `first`, `firstOrNull`, `find`, `sumOf`, `onEach`, `fold`, `associate*`, `groupBy`, `partition`, `maxBy`/`minBy`(`OrNull`), `maxOf`/`minOf`(`OrNull`), `reduce`/`reduceOrNull`, `distinctBy`, `filterIndexed`, `mapIndexed`, `indexOfFirst`/`indexOfLast`, `last`/`lastOrNull`/`findLast`, `single`/`singleOrNull`, `takeLastWhile`/`dropLastWhile`/`dropWhile`, `zip(other) { }`, the collecting forms `mapTo`, `filterTo`, `filterNotTo`, `mapNotNullTo`, `flatMapTo`, `associateTo`, `associateByTo`, `associateWithTo`, `groupByTo`, `filterIndexedTo`, `mapIndexedTo`, `mapIndexedNotNull`, `flatMapIndexed`, `foldIndexed`, `reduceIndexed`, `foldRight`, `reduceRight`, `runningFold`/`scan`/`runningReduce`, `sumBy`, `onEachIndexed`, `firstNotNullOf`/`firstNotNullOfOrNull`, `getOrPut`/`getOrElse` (maps, lists, arrays), `ifEmpty`/`ifBlank`, on a `Map` `filter`, `filterNot`, `onEach`, `mapValues`, `mapKeys`, `filterKeys`, `filterValues`, `mapTo`/`mapValuesTo`/`mapKeysTo`/`filterTo`, `maxBy`/`minBy`; on a `String` (walked as its chars; `filter`, `takeWhile` and `dropWhile` give a String again) `map`, `filter`, `count`, `any`, `all`, `indexOfFirst`, `takeWhile`, `dropWhile`, `sumOf`, `fold`, `forEachIndexed`, ...; on a `Result` `getOrElse`, `onSuccess`, `onFailure`, `fold`, `map`, `recover`; and `runCatching`, `measureTimeMillis`/`measureNanoTime`. `forEach`/`forEachIndexed`, `repeat`, `buildList`/`buildString`/`buildMap`, `use` and `synchronized` always are expanded. `sortedBy`'s selector is `crossinline` in Kotlin, so it cannot contain a `return`. Lists and arrays are walked from the end where the JVM does so (`last { }`, `indexOfLast { }`, `takeLastWhile { }`, `foldRight`) |
| `return`, `break` or `continue` out of a lambda passed to another inline library function (`trim { }`, `mapCatching`, `recoverCatching`, `List(n) { }`, `Array(n) { }`, `zipWithNext { }`, the terminal functions of a `Sequence` such as `any`, `first`, `fold`, `sumOf`, `maxOf`, ...) | the lambda stays a Lua function. The call runs in a `pcall` (`__K2L_CoPcall` on Lua 5.1 when the lambda can suspend) after `local ____jump = __K2L_NewJump()`; the jump is `__K2L_Jump(____jump, code, value)`, which raises the token, and after the `pcall` `if ____result == ____jump then return ____jump.value end` (or the `break`, `goto`, or the jump of another code) makes it. A jump through several such lambdas is passed on from call to call. Every runtime function that catches errors (`catch` blocks, `runCatching`, `mapCatching`, coroutines) raises a token again, so no `catch (e: Throwable)` sees it, while `finally` blocks run and `use` closes its resource normally on the way out, as on the JVM. Calls of inline functions without such jumps are unchanged |
| `closeable.use { }`, `synchronized(lock) { }`, `runCatching { }` | `use` runs the block in a `pcall` and closes the resource afterwards, also when the block fails, returns or jumps (an error of `close()` after a failed block does not replace the block's error); `Closeable` and `AutoCloseable` are interfaces without members to implement, `close()` is an ordinary method. `synchronized` runs the block (there are no threads). `runCatching` without a non-local `return` is `__K2L_RunCatching` |
| `List`, `MutableList`, `Array` | a lualib class: elements in the array part, explicit `size` (nil-safe) |
| `xs[i]`, `xs.size` | `xs:get(i)` (throws `IndexOutOfBoundsException`), `xs.size`; the index of a loop over `xs.indices` is a direct `xs[i + 1]` |
| your own `operator fun get(i, j)`/`set(i, j, v)` | `m:get(i, j)`, `m:set(i, j, v)`; `m[i, j] += v` and `m[i, j]++` evaluate the receiver and indices once: `m:set(i, j, m:get(i, j) + v)`. Extension operators (also on library types) are called as functions: `set(table, i, j, v)` |
| `Map`, `Set` | insertion-ordered lualib classes honoring `equals()`/`hashCode()` keys |
| `map.keys`, `map.values`, `map.entries`, `navigableKeySet()`, `descendingKeySet()`, `descendingMap()` | live views of the map, made once per map: they read the map's arrays on every use, so they see later changes, their `size` is the map's, and `keys.remove`, `values.removeIf`, `entries.removeIf`, `retainAll`, `clear`, their iterators' `remove()` and `entry.setValue` write through (adding throws `UnsupportedOperationException`); the JVM's classes (`LinkedHashMap$LinkedKeySet`, `HashMap$Values`, `TreeMap$EntrySet`, `TreeMap$DescendingSubMap`), `values` a plain `Collection` (`is List` is false), keys and entries sets. `for (k in map.keys)`, `for ((k, v) in map)` and `map.forEach` read the map's arrays directly, without making a view. The entries are live like the JVM's nodes (`HashMap$Node`, `LinkedHashMap$Entry`, `TreeMap$Entry`): made once per key and kept by the map, so `entry.value` sees a later `put` of its key, `===` holds between two reads, and a removed key's entry keeps its last value (its `setValue` no longer writes to the map); `firstEntry()`, `floorEntry()`, `pollFirstEntry()` and the like are `AbstractMap$SimpleImmutableEntry` copies, as on the JVM |
| `treeMap.headMap(k)`, `tailMap`, `subMap`, `treeSet.headSet(k)`, `tailSet`, `subSet`, `descendingSet()` | live views (`TreeMap$AscendingSubMap`, `TreeMap$DescendingSubMap`, a `TreeSet` over those): they keep the map or set and their range of keys, so they see its later changes and their `size` is counted in it; writes go to it, a key outside the range reads as missing and writing one throws `IllegalArgumentException("key out of range")`, views of views narrow the range (a bound outside it throws `fromKey out of range`/`toKey out of range`, reversed bounds `fromKey > toKey`), and loops and iterators over a view throw `ConcurrentModificationException` after any structural change of the map or set. Methods other than lookups and writes of one key run on a copy of the range made for the call (O(n)) |
| `for (x in list)`, `forEach`, iterators | a numeric `for` over the elements (sets and other collections: over `c:____array()`, the map's arrays for a map). As on the JVM, a structural change of an `ArrayList`, `LinkedList`, `kotlin.collections.ArrayDeque`, `HashMap`, `LinkedHashMap`, `HashSet`, `TreeMap`, `TreeSet` or `PriorityQueue` made by the body (or by other code while an iterator is used) throws `ConcurrentModificationException` on the next step: the collections count changes in `____modCount`, and the loop compares it after each pass and asks the collection whether the JVM's `hasNext()` would still be true (removing the second-to-last element of a list ends the loop quietly, as on the JVM). A body made only of locals, literals, operators on numbers and strings, reads of plain properties and `println` cannot change a collection and gets no check, nor does a loop over an array or a fresh `listOf(...)`; `map.forEach { k, v -> }` throws after the whole map, as `HashMap.forEach` does. A `java.util.ArrayDeque`'s iterators check no count, as the JDK's: they read its circular array slot by slot (k2l follows where the JDK's `head` and capacity are) and throw only on reaching an empty slot, so adding while iterating goes on until the array has to grow, and removing the first element is fine; loops over a value that may be one (a `java.util.ArrayDeque`, `Deque`, `Queue`, `Collection` or `Iterable`) go through `__K2L_LoopItems`, which reads one through its iterator. A `subList` is stale after a structural change of its list made around it: reading it throws the JVM's exception |
| `buildList { }`, `buildSet { }`, `buildMap { }` | the stdlib's `ListBuilder`, `SetBuilder` and `MapBuilder` (`kotlin.collections.builders`), filled by the inlined block and made read-only after it (`____build()`): still `is MutableList`, but every mutator, also through views and iterators, throws `UnsupportedOperationException` |
| `listOf(x)`, `emptyList()`, `listOf(a, b)`, `setOf(x)`, `mapOf(k to v)`, ... | the JVM's classes: `Collections$SingletonList`, `EmptyList`, `Arrays$ArrayList` (also what `sorted*()` returns), `Collections$SingletonSet`, `EmptySet`, `Collections$SingletonMap`, `EmptyMap`, with their index messages, `ArrayIndexOutOfBoundsException` for `Arrays$ArrayList` and arrays, and `UnsupportedOperationException` from their mutators (`toList()`, `toSet()`, `toMap()`, `take`, `drop`, ... give the same classes for zero and one element, as in Kotlin). As on the JVM, `listOf(1, 2) as MutableList` succeeds (and can be written by index), while Kotlin's own read-only collections (`emptyList()`, `emptySet()`, `emptyMap()`, a primitive array's `asList()`, objects of classes implementing only `List`, `Set`, `Map`, ...) are not `MutableList`/`MutableSet`/`MutableMap` (their lualib class has `____readOnly`): `is` is false and `as` throws `ClassCastException` (`kotlin.collections.EmptyList cannot be cast to kotlin.collections.MutableList`) |
| `list.subList(a, b)`, `array.asList()` | live views: a table whose `view[i]` reads and writes `list[a + i]` through `__index`/`__newindex`, so the view sees the list's changes and writes go to the list; adding to or removing from a `subList` changes the list (through its `addAt`/`addAllAt`/`removeAt`, as the JDK's views call them; `list.subList(a, b).clear()` removes a range) and the sizes of the views it was made from. `asList()` of an `Array` is a fixed-size `Arrays$ArrayList` writing through both ways, of a primitive array a read-only view. Like `unmodifiableList`, a program mentioning `subList` or `asList` iterates lists by index (see [Standard library coverage](#standard-library-coverage)). Changing the list's size other than through a view makes the view stale: its next use throws `ConcurrentModificationException`, as on the JVM |
| `class Bag : AbstractList<Int>()`, `AbstractMutableList`, `AbstractSet`, `AbstractMap`, `AbstractCollection` (and their mutable variants), `AbstractIterator`; classes implementing `List`, `Set`, `Map`, `Collection`, `Iterable` | the class extends a lualib base that implements every inherited operation (`contains`, `indexOf`, `toString`, `equals`/`hashCode`, `iterator`, `map`/`filter`/`joinToString`, `for` loops, `subList`, the mutators of the mutable variants) in terms of what the class overrides (`size` and `get` for a list; `iterator()` for a collection; `entries` for a map; `set`/`add(index, e)`/`removeAt`, `add` or `put` to make it mutable; `computeNext()`), calling them as often and in the order the JDK and Kotlin's stdlib do. An `AbstractList`'s `list[i]` is `get(i - 1)`, so loops over lists index them on all Lua versions (see `unmodifiableList` in [Standard library coverage](#standard-library-coverage)); a `for` loop over a class implementing `List` itself uses its `iterator()`. A class implementing an interface keeps `Any`'s `toString`/`equals`/`hashCode`. Next to a base class that is not a collection (`class Row : Named("r"), List<String>`), the lualib base is a mixin, one of the class's interfaces, so the base class's members win |
| `class ByLength : Comparator<String>`, `Runnable`, `Callable`, `(Int) -> Int` | values of these library interfaces are Lua callables: a lambda (and `Comparator { a, b -> }`, `Runnable { }`) is a function, and an object of a class implementing one is callable through `__call`, so it works with `sortedWith`, `TreeSet(comparator)`, `reversed()`, `thenBy`, `map(f)`, ...; `c.compare(a, b)` and `r.run()` on an interface type call the value |
| `fun interface Check`, `Check { it > 0 }`, a lambda passed for a `Check` parameter | an object of the interface whose method calls the lambda: `__K2L_FunInterface(Check, "test", f)` |
| `class Letters : CharSequence`, `class Count : Iterator<Int>`, `MutableIterator`, `ListIterator`, `Map.Entry`, `Comparable` | the class's own members; `for` loops and the library functions use them (the String functions read the chars of a CharSequence object through its `length` and `get`, not its `toString()`) |
| `class DateRange(...) : ClosedRange<Date>, Iterable<Date>` | `contains` and `isEmpty` come from the interface (a mixin comparing `start` and `endInclusive`), also next to a collection base; `start`/`endInclusive` of a value typed as `ClosedRange` read the class's properties or a library range's bounds |
| `class Stack : ArrayList<Int>()`, `HashMap`, `LinkedHashMap`, `HashSet`, `LinkedHashSet`, `TreeMap`, `TreeSet`, `PriorityQueue`, `java.util.ArrayDeque`, `LinkedList` | the class extends the lualib collection; `super.add(x)` calls the library member (`__K2L_List.add(self, x)`). The library's methods call the overridable ones exactly where the JDK's do: `ArrayList.addAll` does not call an overridden `add` while `HashSet.addAll` and `HashSet(elements)` do; `PriorityQueue.add` calls `offer`, `addAll` calls `add`, `remove()` calls `poll` and `element()` `peek`; `ArrayDeque.add`, `offer`, `addAll` and `ArrayDeque(elements)` call `addLast`, `push` calls `addFirst`, `pop`/`remove()`/`removeFirst` call `pollFirst`; `LinkedList.offer` calls `add`, `LinkedList(c)` calls `addAll(c)`, which calls `addAll(size, c)`, `push` calls `addFirst`; `TreeMap.putAll` and `TreeMap(map)` call `put` (TreeMap's `putIfAbsent`, `merge` and `compute*` do not), `TreeSet.addAll` and `TreeSet(elements)` call `add`, `getOrPut` and `getValue` call `get`, `AbstractSet.equals`/`removeAll` call `contains`/`remove`. `LinkedHashMap(capacity, loadFactor, true)` with `removeEldestEntry` makes an LRU cache. A class overriding a member the library's own operations call on the JVM (`size`, `iterator()`, `get`, `contains`, `isEmpty`, `indexOf`, `listIterator`, `entries`, `keys`, `values`, `containsKey`) gets `__K2L_HonorOverrides(C, base)`: versions of those operations (see `CollectionOverrides.lua`) that call the overrides exactly where the JDK and the stdlib do, e.g. `toString`, `for` loops and `filter` call `iterator()`, `map` and `toSet` call `size` first, `first()` of a list `isEmpty` and `get(0)`, `ArrayList.contains` calls `indexOf`, `isEmpty` calls `size` in a `LinkedList`, `PriorityQueue` and `TreeMap` but not in an `ArrayList`, `AbstractSet.equals` calls `size` and `contains`, a map's `toString`, loops and `map` read `entries`. Classes without such overrides, and the library's own collections, keep their direct paths |
| `xs.filter(f).map(g)`, `groupBy`, `joinToString`, ... | methods of the same name: `xs:filter(f):map(g)`; with lambda literals on lists, arrays and sets the common ones are loops, see the `return` row above |
| `Pair`, `Triple`, destructuring | lualib classes; `local a, b = p.first, p.second` |
| `Sequence`, `asSequence()`, `generateSequence`, `sequenceOf` | a lazy lualib class: `__K2L_AsSequence(xs):map(f):take(3):toList()` |
| `seq.asIterable()`, `seq.toCollection(c)` | `asIterable()` is an `Iterable` that reads the sequence again for each operation (a `constrainOnce` sequence fails the second time), pulling only what `first`, `firstOrNull`, `find`, `any`, `all`, `none`, `contains`, `indexOf` and `take` need, so those also work on infinite sequences; other operations and `for` loops read all of it. `list.asIterable().asSequence()` returns the sequence |
| `for (x in sequence)`, `seq.forEach { }` | `for _, x in seq:iter() do` (a generator returning `true, x` per element) |
| `class Foo : Sequence<T>` | the class extends the lualib sequence and its `iterator()` feeds every `Sequence` operation and `for` |
| `sequence { yield(x) }`, `iterator { }` | the block runs in a Lua coroutine: `__K2L_SequenceBuilder(function(self) self:yield(x) end)` |
| `suspend fun`, suspend lambdas | plain Lua functions, run inside a Lua coroutine (see [Coroutines](#coroutines)) |
| `startCoroutine`, `suspendCoroutine`, `cont.resume(x)` | `__K2L_StartCoroutine(block, completion)`, `__K2L_SuspendCoroutine(function(cont) ... end)`, `cont:resumeWith(__K2L_Result.success(x))` |
| `Result`, `runCatching` | a lualib class: `result:getOrThrow()`, `__K2L_RunCatching(f)` |
| `Unit` as a value | a call of a function returning Unit returns nothing in Lua, and is a plain call as a statement. Where a Unit expression is used as a value (an argument, an initializer, an element, a string template, `Any`/`T`, `x?.unitCall()`), it runs as a statement and the value is the runtime object `__K2L_Unit`, which prints as `kotlin.Unit` (identity `equals`/`hashCode`, `is Unit` is `x == __K2L_Unit`). A lambda returning Unit passed where a function with a result is expected (`runCatching { }`, `map { }`, `() -> T`, `() -> Any`) returns it, a function reference or variable returning Unit passed as such an argument (`runCatching(::work)`) is wrapped to return it, and so does the body of a `suspend () -> Unit` coroutine for its completion |
| multiple files | `local ____util = require("util")`, `____util.helper(...)`; a file's module is its path (`ui/Style.common.kt` is `ui.Style_common`). Files on an import cycle register their table in `package.loaded` first and export as they go, and an entry file that other files import runs `main` only as the script (`if ... ~= "main" then main() end`) |

By default `Int` arithmetic is not wrapped to 32 bits (Lua integers are 64-bit, or doubles before 5.3);
explicit conversions like `Long.toInt()` and bitwise operations do wrap. With `--int-overflow wrap`
(`"intOverflow": "wrap"` in k2l.json) `Int` `+ - *`, unary minus, `++`/`--` and compound assignments wrap like the
JVM (`Short`/`Byte` arithmetic is `Int` arithmetic, as in Kotlin; `Short`/`Byte` `++` wraps to 16/8 bits). A chain is
wrapped once: `31 * h + x` is `(31 * h + x + 0x80000000 & 0xFFFFFFFF) - 0x80000000` on 5.3/5.4 and
`__K2L_ToInt32(31 * h + x)` on 5.1/5.2/LuaJIT, where a product of two variables goes through `__K2L_IMul`
(an exact 32-bit multiply, since the plain product can exceed 2^53). Constant `Int` expressions are folded like
Kotlin does. Also wrapped: `Int.MIN_VALUE / -1`, `abs(Int.MIN_VALUE)`, `sum()`/`sumOf` of `Int`s (once, at the end) and
`inc()`/`dec()`. Not wrapped: `Long` (64-bit natively on 5.3/5.4; a double elsewhere, unless `--long64 emulate` makes it exact).

`Float` is a double rounded to IEEE single precision after every arithmetic operation, conversion and `kotlin.math` call
(`__K2L_Fround`: `string.pack("f")` on 5.3/5.4, a `frexp`/`ldexp` rounding elsewhere), and a statically typed `Float` prints
like `Float.toString` (`1f / 3` is `0.33333334`, `1.1f.toDouble()` is `1.100000023841858`). `UByte`, `UShort`, `UInt` and
`ULong` are Lua numbers holding the unsigned value; the first three wrap modulo 2^8/2^16/2^32 on every target whatever
`--int-overflow` says (`(a + b) & 0xFFFFFFFF`, or `% 2^32` before 5.3), `ULong` is a 64-bit pattern in a Lua integer on 5.3/5.4
(unsigned division, comparison via `math.ult`, printing) and a double elsewhere.

## Lazy initialization

Kotlin initializes `object`s, companion objects and enum classes on first access. k2l does that only where somebody
could notice: an `init` block that does more than assign pure values, a property initializer that calls code or reads
mutable state, a constructor with a body, entry arguments or a superclass doing any of that. Everything else is
initialized where it is declared, as before. For the observable cases the table is armed with
`__K2L_LazyObject(Config, "____init")`: its members are put aside and the first read or write of a member (or using the
object as a value, `__K2L_TouchObject(Config)`) restores them and runs the initializers; afterwards calls are plain
table lookups. A companion arms its outer class (its first use is a member access or construction; a companion with
supertypes is armed itself as well, as it can be used as a value); an enum arms
`____initEnum`, which creates the entries. Nested classes and the `____name`/metamethod keys stay available.

The top-level properties of a file work the same way, as the JVM initializes a file's facade class (`StoreKt`) on its first
use. A file without `main` whose plain top-level properties (no custom accessors, no delegate, not `const`) have an
initializer that calls code or reads mutable state, its own `val`s aside, keeps them all, private ones included, in its exports
table. `__K2L_LazyFile(____exports, init, {"stock", "opened"})` runs their initializers, in declaration order, on the
first read or write of one of them, from any file. This happens neither at startup nor when another file is `require`d
first in an import cycle. So `val header = "== ${Config.user} =="` sees what `main` set before, and a cycle whose
initializers read each other in an order the JVM accepts works. A file stays initialized when it loads if one of its
properties with accessors or a delegate has such an initializer.

Properties read during construction before their initializer ran behave like the JVM, which zeroes fields first: open or
abstract properties that a constructor reads (directly or through the functions it calls) and a subclass overrides with its
own field, and properties that an earlier initializer or `init` block reaches through a method call, or a superclass
constructor through an override (`val x = compute()` declared before the `val y = 5` that `compute()` reads), read `0`,
`false`, `null` (a non-null `String` reads as `"null"`) until initialized: the constructor stores those values first
(`self.y = 0`).

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
- `@LuaName("name")` uses a different Lua name. An object named `_G` maps its members to globals. A keyword works as
  a name (`@LuaName("end")` is `M["end"](...)`, a method `s["repeat"](s, n)`).
- `@LuaRequire("module")` on a file makes its external top-level declarations fields of that module;
  on a class or object, the module is the class or object.
- Members of external objects are called with `.`, instance members with `:` unless `@NoSelf`.
- External classes are constructed with `Class.new(...)`.
- `LuaTable<K, V>` is a plain table; `LuaMultiReturn2`/`3` destructure multiple return values.
- `Lua` (globals), `LuaOs` and `LuaIo` bind parts of the standard library.

Kotlin lists are Lua sequences (1-based, with a `size` field), so they can be passed to Lua functions
that expect arrays; Kotlin lambdas are Lua functions.

### Calling Kotlin from Lua

Every file is a Lua module whose table holds its public top-level declarations, so hand-written Lua can
`require("mods.Greeter")` (the file's path under the source directory) and call into Kotlin:

```kotlin
package mods.mods

@LuaName("on_load")               // the field Lua reads; the Kotlin name stays loadGreeter
fun loadGreeter(host: Host): String = ...

@LuaName("greeting_style")
var style = "plain"               // Lua reads and writes mod.greeting_style; Kotlin sees the change
```

```lua
local mod = require("mods.Greeter")
mod.on_load(host)
mod.greeting_style = "loud"
local v = require("shared.Events").Version:parse("2.10")   -- companion and object members take `:`
print(tostring(v), v.major, v:compareTo(other))             -- tostring() of an object is its toString()
```

Top-level functions are fields called with `.`, members of objects, companions and instances with `:`, and constructors are
`Class.new(...)`. Plain properties are fields, while properties with custom getters are methods (`e:getAlive()`). `@LuaName`
on a top-level function or plain property gives it a Lua-style name, when the name is a Lua identifier that is neither a
keyword nor a global the generated code uses. Parameters typed `LuaTable` or as an external interface take Lua tables, and
function types take Lua functions. A plain Lua array is not a Kotlin `List`. Kotlin exceptions reach Lua's `pcall` as
objects with a `message` field, and Lua errors reach Kotlin as `RuntimeException`.

## Coroutines

k2l supports the coroutine machinery of the Kotlin standard library (not kotlinx.coroutines), mapped
onto Lua's native coroutines:

- A `suspend` function compiles to an ordinary Lua function, so calling one is an ordinary call.
- `block.startCoroutine(completion)` runs `block` in a new Lua coroutine until it first suspends.
- `suspendCoroutine { cont -> }` passes the block a continuation. If the block (or anything it calls)
  resumes it right away, execution simply continues; otherwise the coroutine yields, and a later
  `cont.resume(x)` / `resumeWithException(e)` resumes it on the caller's stack, as on the JVM.
- When the block returns or throws, `completion.resumeWith(...)` receives a `Result`.

This is enough to write schedulers in plain Kotlin, such as a game loop where coroutines wait for frames:

```kotlin
suspend fun waitFrames(n: Int) = suspendCoroutine<Unit> { cont -> waiting += Waiting(frame + n, cont) }

fun runFrame() {
    frame++
    val due = waiting.filter { it.wakeAt <= frame }
    waiting.removeAll(due)
    due.forEach { it.cont.resume(Unit) }
}
```

```lua
local function waitFrames(n)
    return __K2L_SuspendCoroutine(function(cont)
        waiting:add(Waiting.new(frame + n, cont))
    end)
end
```

`sequence { }` and `iterator { }` use the same mechanism: each iteration runs the block in a coroutine
that yields an element at each `yield(x)`, so elements are computed on demand and infinite generators
work. Sequences are lazy, and side effects in `map`/`filter` interleave exactly as on the JVM. A
`yieldAll` of another `sequence { }` or `iterator { }` does not resume that block's coroutine from inside the outer one (each
nested resume is a C call, and Lua allows only about 200): it hands the inner block to the generator, which keeps a stack of the
active coroutines and resumes the innermost directly, so a recursive tree walk
(`fun walk(n): Sequence<T> = sequence { yield(n); for (c in n.children) yieldAll(walk(c)) }`) goes as deep as the data. As on the
JVM, whose `hasNext()` calls that of the inner iterator, an exception such an inner block throws before its first element comes
out of the `yieldAll`, and one thrown later reaches the consumer directly, past any `try` around the `yieldAll`.

### Contexts, interceptors and intrinsics

A coroutine's context is the completion's `context`. `CoroutineContext`, `Element`, `Key`, `AbstractCoroutineContextElement`,
`EmptyCoroutineContext`, `coroutineContext[Key]`, `plus` / `+`, `minusKey` and `fold` follow the standard library (the
interceptor stays last when contexts are added). An element is any object with a `key` field (or a `key` property with a custom getter); the context operations are lualib
functions (`__K2L_ContextGet(ctx, key)`, ...), not methods. A `ContinuationInterceptor` in the context is honoured: the coroutine is
started through `interceptor:interceptContinuation(cont)`, and so is every resumption of a `suspendCoroutine`
(`createCoroutine` as well), so a dispatcher written in plain Kotlin decides when the coroutine runs again. `releaseInterceptedContinuation`
is called when the coroutine ends. `startCoroutine` dispatches its first run like the JVM does.

`kotlin.coroutines.intrinsics` maps onto the same model: `suspendCoroutineUninterceptedOrReturn { cont -> }` returns the block's value,
or, when it returns `COROUTINE_SUSPENDED`, yields until `cont` is resumed (directly, not through the interceptor);
`createCoroutineUnintercepted` and `startCoroutineUninterceptedOrReturn` (its value if the block finishes without suspending, else
`COROUTINE_SUSPENDED`) run the block as a task of its own; `cont.intercepted()` asks the interceptor.

To drive Kotlin coroutines from hand-written Lua, export an ordinary Kotlin function that starts them
(e.g. `fun launch(task: suspend () -> Unit)` calling `task.startCoroutine(...)`) and one that resumes
your scheduler; Lua code calls those like any other exported function.

Lua 5.1 cannot yield across `pcall`, which `try` compiles to. On 5.1 only, a `try` whose block or
catch clauses contain a suspension point runs through `__K2L_CoPcall`, which executes the block in
its own coroutine and passes its yields on to the enclosing coroutine (the "coxpcall" technique);
`runCatching` does the same. Lua 5.2+ and LuaJIT yield across `pcall` natively and use it as is.
Yielding through a Lua C function (e.g. a `table.sort` comparator or raw `Lua.pcall`) still fails on 5.1.

## Reflection

`x::class`, `Foo::class` and `T::class` (in an expanded reified inline function) give a `KClass`; `javaClass` and
`KClass.java` give its `Class` (an object of its own, one per class, with `KClass.kotlin`/`Class.kotlin` leading back). Supported
members: `simpleName`, `qualifiedName`, `isInstance(x)`, `name` and `enumConstants` of a `Class` (a fresh array of an enum
class's entries, `null` for other classes), `Enum.declaringJavaClass`, `toString()`, and `==`/`!=`, use as map keys, in
`when` and in collections. Classes of the program match the JVM: package-qualified names (`app.model.Outer.Nested`, binary
`app.model.Outer$Nested` for `javaClass.name`), `null` as `qualifiedName` of local classes, binary names of local classes and object expressions
(`app.MainKt$main$Local`, `app.Shop$greeter$1`, `app.MainKt$main$made$1$1`: numbered within the function, property or lambda
around them, as the Kotlin/JVM compiler does), `null` as `simpleName` of an object expression (`""` from `javaClass.simpleName`),
enum entries with bodies are classes named after the entry, and a companion object's value has the companion's class (`Outer.Companion`, `simpleName` `Companion`).
A `KClass` prints like the JVM's without kotlin-reflect (`class app.Dog (Kotlin reflection is not available)`), a `Class` like
`java.lang.Class` (`class app.Dog`, `interface app.Shape`).

`typeOf<T>()` (of a concrete or reified type) is a `KType` like the JVM's without kotlin-reflect: it prints with JVM names
(`java.util.List<java.lang.Integer> (Kotlin reflection is not available)`, `int` for a non-null `Int` on its own), is `==` to
another `KType` of the same type (so it can key a map), and has `isMarkedNullable`, `classifier` and `arguments` (`KTypeProjection`s
with `type`, printing `*`, `in ...` and `out ...`). The `classifier` of a nullable primitive (`typeOf<Int?>()`) prints as `Int::class`
does (`int`), where the JVM prints `class java.lang.Integer`; `KTypeProjection.variance` is not supported.

Property references are values with `name`, `get`, `set` and `invoke` (also called like a function): `Person::name`,
`person::age` (bound), `Config::level` (an `object`'s property), `::counter`, extension properties (`String::lastChar`,
`"lua"::lastChar`, `Box::first` with `get`/`set`; their accessors are the generated `getLastChar`/`setLastChar` functions), and
properties of the library: `String::length`, `"abc"::length`, `List<*>::size`, `IntArray::size`, `Pair<*, *>::first`,
`Map.Entry<*, *>::key`, `StringBuilder::length`, `String::lastIndex`, `CharSequence::indices`, constants such as
`Int.Companion::MAX_VALUE` and `::PI`. `Person::name` is
`__K2L_PropertyRef.new("name", "app/Person.name", function(receiver) return receiver.name end)`, passable to `map(Person::name)`; a
reference to a library property passed straight to a parameter of a function type stays a plain function (`map(String::length)` is
`map(function(s) return #s end)`). Library properties are read-only here (their writes are not mapped).

`::fn.name` and `Type::method.name` are the name written in the reference (`<init>` for a constructor). A reference to a function
(of the program or of the library: `String::uppercase`, `Int::plus`, `"x"::plus`, `listOf(1)::contains`, `::println`) stays a plain
Lua function, unless the program looks at a function reference held in a value as an object: reads its `name`
(`val f = ::greet; f.name`, a `KFunction<*>` or `KCallable<*>` parameter), prints it, compares it with `==` or calls `hashCode()`.
Then the references that are not passed straight to a parameter of a function type (`map(::f)` stays plain) become
`__K2L_FunctionRef` objects, callable tables with the `name`. They are not Lua functions, so a C function expecting a callback (a
`table.sort` comparator) cannot be given one.

References print and compare like the JVM's: `property name (Kotlin reflection is not available)`,
`function twice (Kotlin reflection is not available)`, `constructor (Kotlin reflection is not available)`; two references to the
same callable are `==` (and have the same `hashCode()`) when they are bound to equal receivers or both unbound. The `KProperty`
passed to a delegate's `getValue`/`setValue`/`provideDelegate` is such a property reference too: it prints the same and is `==` to
`Holder::x` (it has no accessors: on the JVM only kotlin-reflect would reach them from a `KProperty<*>`, and an unchecked cast to
`KProperty1` gets an `UnsupportedOperationException` from them).

The members that need kotlin-reflect throw `KotlinReflectionNotSupportedError` like a JVM program without `kotlin-reflect` does
(the oracle compiles with `-no-reflect`): of `KClass` `isData`, `isAbstract`, `isOpen`, `isFinal`, `isSealed`, `isCompanion`,
`isInner`, `objectInstance`, `sealedSubclasses`, `supertypes`, `members`, `constructors`, ...; of references (`KCallable`,
`KFunction`, `KProperty`, also the delegate's `KProperty`) `parameters`, `returnType`, `typeParameters`, `visibility`, `isSuspend`,
`isOpen`/`isFinal`/`isAbstract`, `call`, `callBy`, `annotations`, `isInline`/`isOperator`/`isInfix`/`isExternal`, `getter`,
`setter`, `isConst`, `isLateinit` and `getDelegate`. Other members (Java reflection such as `Class.methods`) are reported as
unsupported.

Names are only recorded in the generated classes when the module uses `::class` or `javaClass`. Differences from the JVM,
because Lua values carry less type information:

- `Int` and `Long` are the same Lua number, `Char` and `String` the same string: the class of a value of static type
  `Any` is `Int` or `String`. `1L::class` and `'c'::class` are right because the static type is used. On Lua 5.1, 5.2
  and LuaJIT a `Double` with an integral value is an `Int` at runtime (on 5.3+ `math.type` tells them apart).
- Library collections report the JVM's classes for the factories and the functions listed in the table above
  (`listOf(1)` is a `java.util.Collections.SingletonList`, `javaClass.name` `java.util.Collections$SingletonList`), and so do
  the views a map returns (`keys` of a `LinkedHashMap` are a `LinkedHashMap$LinkedKeySet`, `values` of a `HashMap` a
  `HashMap$Values`, the entries of a `TreeMap` `TreeMap$Entry`), the iterators of the lists, sets, ranges, arrays and queues
  (`ArrayList$Itr`, `Arrays$ArrayItr`, `HashMap$KeyIterator`, ...), `subList` (`ArrayList$SubList`,
  `AbstractList$RandomAccessSubList`), `ArrayDeque` and `LinkedList`. Other iterators and views (of strings, sequences,
  `asReversed()`, `withIndex()`) report a lualib class. An array's class comes from its static type: `IntArray` is
  `kotlin.IntArray` (JVM name `[I`, Java simple name `int[]`), `Array<String>` is `kotlin.Array` (`[Ljava.lang.String;`,
  `String[]`). Arrays also know their class at run time (a lualib class per JVM name, given where the array is made: `intArrayOf`,
  `IntArray(n)`, `arrayOf<String>`, `Array(n) { }`, `toTypedArray()`, `toIntArray()`, `toCharArray()`, ...), so an array held in
  an `Any` has the same class, `is IntArray`/`is Array<*>` tell them apart, and `toString()` is the JVM's `[I@1b`. An array made
  from a `vararg` parameter, or by library code that does not know the element type (`BigInteger.divideAndRemainder`), is an
  `Object[]` (`[Ljava.lang.Object;`) when held in an `Any`. A lambda is `kotlin.Function`.
- Library classes have their Kotlin names (`String::class.java.name` is `kotlin.String`); `toString()` uses the JVM's for the
  builtin types and collection interfaces (`class java.lang.String`, `int`, `interface java.util.List`) and the Kotlin name for the
  others (`class kotlin.collections.ArrayList`).
- A function reference that goes straight to a parameter of a function type is a plain function there: printing or comparing that
  parameter does not see the reference (`fun show(f: (Int) -> Int) = println(f)` does not print `function twice ...`).
- An object expression (or local class) creates its class table each time it is evaluated, as its methods are closures over the
  locals around it. Its `KClass` and `Class` are still one per declaration site, found by the binary name, so two objects made by
  the same expression have `==` classes and `isInstance` holds for both, as on the JVM.

## Strings

By default Lua strings are byte strings: `length` and indexing count UTF-8 bytes, `Char` is a one-byte string (so a `Char`
held as `Any` passes `is String`, and a one-character `String` passes `is Char`), and
`isLetter()`, `uppercase()` and so on are ASCII only. With `--strings utf16` (`"strings": "utf16"` in k2l.json,
`strings.set("utf16")` in Gradle) strings behave like the JVM's UTF-16 strings, while still being UTF-8 Lua strings
that print and concatenate normally (`"😀".length == 2`, `s[i]` is a UTF-16 code unit):

- A `Char` is the UTF-8 string of one code unit. A surrogate half, which UTF-8 cannot encode, is its 3-byte generalized form
  (WTF-8), so lone surrogates round-trip; `+`, templates with a `Char`, `StringBuilder`, `String(chars)`, `joinToString` and
  `filter` join two adjacent halves into the real 4-byte character. `print` writes an
  unpaired surrogate as `?`, like the JVM.
- All-ASCII strings (checked once per string and cached) use the byte implementations; other strings are decoded to
  UTF-16 units once (a small cache) and `length`, `[]`, `substring`, `indexOf`/`lastIndexOf`, `padStart`, `reversed()` (keeps
  surrogate pairs), `take`/`drop`, `chunked`, `windowed`, `for (c in s)`, `Char.code`, `Char(code)`, `toChar()`, `Char + Int`,
  char ranges, `toCharArray`, `StringBuilder` (`insert`, `setCharAt`, `deleteCharAt`, `length`, ...), `compareTo` and `<`
  (UTF-16 order) and `hashCode` (also used for `HashMap` order) work on code units, exactly like the JVM.
- `isLetter`, `isDigit`, `isLetterOrDigit`, `isWhitespace`, `isUpperCase`, `isLowerCase`, `uppercaseChar()`, `uppercase()`
  (`ß` becomes `SS`), `titlecase()`, `String.uppercase()/lowercase()`, `equals(ignoreCase)` and the other `ignoreCase`
  functions, and `digitToInt()` use Unicode tables generated from the JDK (`compiler/tools/GenUnicode.java`, about 24 KB of
  range lists in `Unicode.lua`, loaded only by programs that use them). Regex `\w \d \s` and the POSIX classes (`\p{Alpha}`,
  `\p{Digit}`, ...) stay ASCII, as in Java, while the binary properties (`\p{IsAlphabetic}`, `\p{IsUppercase}`,
  `\p{IsWhite_Space}`, `\p{javaWhitespace}`, ...) use the same tables (`\p{IsAlphabetic}` is `Character.isAlphabetic`: the
  letters, `Nl` and `Other_Alphabetic`) and the general categories (`\p{Lu}`, `\p{L}`, ...) a
  table of every code point's `Character.getType` (`UnicodeCategories.lua`, about 7 KB, also generated by `GenUnicode.java`).
  A regex whose pattern has `\p` or `\P`, or is not a literal, loads them.
- Code points: `codePointAt/Before/Count`, `offsetByCodePoints`, `codePoints()` and `chars()` (an `IntStream`,
  see [Streams](#streams)), `Character.toChars`,
  `isSupplementaryCodePoint`, `charCount`, `toCodePoint`, `isSurrogate`..., `StringBuilder.appendCodePoint`, and the
  `Character.isLetter(int)` family. Regex match ranges and start indices are UTF-16 indices.
- `Locale` values are their string forms (`tr_TR`, `en_US`, `az_AZ_#Latn`, `""` for `Locale.ROOT`): the constants, `Locale("tr")`,
  `Locale("tr", "TR", "variant")`, `Locale.of(...)`, `Locale.forLanguageTag("lt-LT")`, `language`, `country`, `variant`,
  `toString()` and `toLanguageTag()` work in both modes. With `--strings utf16`, `uppercase(locale)`, `lowercase(locale)` and
  `Char.titlecase(locale)` follow the rules of the JDK for Turkish and Azeri (`i` becomes `İ`, `I` becomes `ı`, `İ` becomes `i`, a
  combining dot above after `I` is dropped) and Lithuanian (the dot of `i`, `j` and `į` is kept under accents above, `Ì`/`Í`/`Ĩ`
  lose it as `i̇̀` and so on); every other locale maps like `Locale.ROOT`, and `Locale.getDefault()` is `en_US` (so it does too).
  Without `--strings utf16` every locale maps like `Locale.ROOT` (ASCII) for case mapping.
- Locale display names, in English (the default locale is `en_US`): `displayLanguage`, `displayCountry`, `displayScript`,
  `displayVariant` and `displayName` (`Turkish (Türkiye)`, `Chinese (Simplified, China)`), also as `getDisplayLanguage(Locale.ENGLISH)`
  and so on. The names are the JDK's own (CLDR), generated by `compiler/tools/GenLocale.java` into `LocaleNames.lua` (about 23 KB, loaded
  only by programs that ask for a display name). A display locale of another language than English is reported as unsupported
  (a runtime error when the locale is not a constant).
- `String.format(locale, ...)` and `"%,d".format(locale, ...)` use what `java.util.Formatter` takes from a locale: the decimal
  separator, the grouping separator and group size (the `,` flag) and the zero digit (so `ar_EG` and `fa` print Arabic-Indic digits,
  `de_CH` groups with `’`, `fr` with a narrow no-break space, `th_TH_TH` writes Thai digits). Like the JDK, the minus sign, `NaN` and
  `Infinity` stay ASCII. The table covers every locale the JDK has (`LocaleFormat.lua`, about 6 KB, generated by the same tool and loaded
  only when a call passes a locale other than `Locale.ROOT` or `en_US`). With `--strings utf16`, `%S`, `%C` and `%B` upper-case with
  Unicode rules (`ß` becomes `SS`) and with the locale's rules for Turkish, Azeri and Lithuanian; without it they upper-case ASCII.

Differences from the JVM in `utf16` mode: the final-sigma rule of `lowercase()` approximates Java's word-boundary check
(letters, digits, marks, `_` and `-` count as word characters); `ignoreCase` on a search for text with Unicode-only case pairs
(`contains`, `replace`, `startsWith` ...) uses simple case folding of single characters, while `Regex` with `IGNORE_CASE` compares
by the same folding as Java's `UNICODE_CASE` (so `ſ` matches `s`, and `straße` does not match `STRASSE`; the inline flag `(?i)` stays
ASCII only, `(?iu)` is Unicode, as in Java); two Strings holding the halves of a pair that are joined with `+` (no `Char`
involved) stay two 3-byte halves until a later `Char` operation normalizes them (a `Regex` pattern and `Regex` results are
normalized). Code point APIs without `--strings utf16` are reported as unsupported.

Like the JVM, with `--strings utf16`: `trimIndent`, `trimMargin` and `prependIndent` measure indents by `Char.isWhitespace` (no-break
and ideographic spaces count), `toInt()`, `toLong()`, `toUInt()`, `toIntOrNull(radix)`, `Integer.parseInt` ... accept Unicode decimal
digits (`"١٢٣".toInt()` is 123) and, above radix 10, the fullwidth Latin letters, `contains`, `replace`, `split`, `startsWith`,
`removePrefix`, `substringBefore` ... find one half of a surrogate pair inside a pair, and an empty regex match stops between
the two halves of a pair (so `"😀".split("")` and `replace(Regex(""), "-")` split the pair, as `java.util.regex` does).

### Streams

`java.util.stream` is available for `Stream<T>`, `IntStream`, `LongStream` and `DoubleStream`, with `Optional`, `OptionalInt`,
`OptionalLong`, `OptionalDouble`, `Collectors` and the summary statistics (`StreamMappings.kt`, `Streams.lua`, `SummaryStatistics.lua`,
loaded only by programs that use them):

- Sources: `Arrays.stream(array)` and `Arrays.stream(array, from, to)` (of an `IntArray`, `LongArray`, `DoubleArray` or object
  array), `collection.stream()` and `parallelStream()`, `String.chars()` and `codePoints()` (with `--strings utf16`), `Stream.of`,
  `empty`, `concat`, `iterate` (with or without `hasNext`) and `generate`, `IntStream.range`, `rangeClosed`, `of`, `iterate` ...,
  `LongStream.range`, `rangeClosed`, `of` ..., `DoubleStream.of`.
- Stages and terminal operations: `filter`, `map`, `mapToInt`, `mapToLong`, `mapToDouble`, `mapToObj`, `boxed`, `asLongStream`,
  `asDoubleStream`, `flatMap`, `flatMapToInt`/`Long`/`Double`, `distinct`, `sorted` (with or without a comparator), `limit`,
  `skip`, `peek`, `takeWhile`, `dropWhile`, `forEach`, `forEachOrdered`, `count`, `sum`, `average`, `min`, `max`, `reduce` (one or
  two arguments), `anyMatch`, `allMatch`, `noneMatch`, `findFirst`, `findAny`, `toArray`, `toList`, `iterator()` (a
  `PrimitiveIterator` with `nextInt()` and so on for the primitive streams; it pulls the elements one at a time as `hasNext()` asks
  for them), `summaryStatistics()`, `isParallel()`, `collect(collector)` and `collect(supplier, accumulator, combiner)`.
  `OptionalInt.asInt` (`getAsInt`), `isPresent`, `orElse`, `ifPresent`, `Optional.map`/`filter`/`flatMap`/`orElseThrow` and so on.
- Collectors: `toList`, `toSet`, `toCollection`, `joining` (0, 1 or 3 arguments), `counting`, `summingInt`, `summingLong`,
  `summingDouble`, `averagingInt`, `averagingLong`, `averagingDouble`, `summarizingInt`, `summarizingLong`, `summarizingDouble`,
  `mapping`, `collectingAndThen`, `minBy`, `maxBy`, `groupingBy` (with or without a downstream collector), `partitioningBy` and
  `toMap` (with or without a merge function). Maps are `HashMap`s with the JVM's iteration order.
- `IntSummaryStatistics`, `LongSummaryStatistics` and `DoubleSummaryStatistics` (also constructed directly): `count`, `sum` (a
  `Long` for `Int` values, compensated like the JDK's for doubles), `min`, `max` (`Int.MAX_VALUE`/`MIN_VALUE`, `Infinity` ...
  when empty), `average`, `accept`, `combine`, and `toString()` like the JDK's
  (`IntSummaryStatistics{count=3, sum=6, min=1, average=2.000000, max=3}`).

Streams are lazy like the JDK's: the stages run element by element in the JDK's order (the side effects of `peek` and of lambdas
interleave the same way), `sorted` waits for all the elements before it, `limit`, `findFirst` and `anyMatch` stop early, and
`count()` of a stream whose size is known (an array, a collection, a range, through `map`, `sorted`, `skip`, `limit`) does not run
the stages, as on JDK 9 and later. `DoubleStream.sum()` and `average()` use the JDK's compensated summation, `IntStream.sum()`
wraps to 32 bits and `LongStream.sum()` to 64 (exactly on Lua 5.3/5.4 and with `--long64 emulate`; on Lua 5.1, 5.2 and LuaJIT
without it, `Long` values above 2^53 lose precision as everywhere else). As in the JDK, a second operation on a stream throws
`IllegalStateException`.

Streams are sequential: `parallel()` and `parallelStream()` only mark the stream (`isParallel()` is true) and run it like a
sequential one. A deterministic pipeline (`map`, `filter`, `sum`, `reduce` with an associative operation, `collect`, `count`,
`forEachOrdered`, `findFirst`, ...) gives the JVM's result; operations whose order is unspecified on a parallel stream
(`forEach`, `findAny`, `peek` side effects, a non-associative `reduce`) see the elements in order here, which the JVM does not
promise.

## Lua targets

`--target 5.4` (the default) and `5.3` use integers, `//` and native bitwise operators. On `5.2`,
`5.1` and `JIT`, which have only floating-point numbers:

- `Double` values are printed from their static type (`2.0`, not `2`); an integral `Double` inside a
  collection prints (and hashes, which can change the iteration order of a `HashSet<Double>`) like an `Int`, since the two
  are the same Lua number at runtime. A `Double` property of a data class hashes as a `Double`.
- `Long` values above 2^53 lose precision, unless you ask for exact 64-bit arithmetic with `--long64 emulate` (see below).
  `Long` bitwise operations and bit counts work on the two 32-bit halves, so they are exact below 2^53
  (`x.toLong() and 0xFFFFFFFFL`, 40-bit masks).
- Bitwise operations use `bit32` (5.2), LuaJIT's `bit` library, or plain Lua (5.1).
- Lua 5.1 has no `goto`: `continue` breaks out of a one-iteration `repeat ... until true`, and
  labeled jumps use flags.

## Performance

Timings depend on the machine; compare runs on the same one. Lower is faster throughout.

**The generated code: the benchmark suite.** `./gradlew :compiler:bench` (see [Benchmarks](#benchmarks)) runs 17
programs on every target and compares the median times with `compiler/src/bench/baseline.json`, which was measured
before the optimization work of 0.2.0 (at commit `32a3468`; Linux, 16 cores, Lua 5.1.5, 5.2.4, 5.3.6, 5.4.9, LuaJIT 2.1).
Geometric mean over the programs:

| | Lua 5.1 | Lua 5.2 | Lua 5.3 | Lua 5.4 | LuaJIT |
|---|---:|---:|---:|---:|---:|
| baseline (median ms) | 1931 | 1503 | 1085 | 894 | 347 |
| 0.2.0, relative to the baseline | 0.46 | 0.55 | 0.55 | 0.54 | 0.50 |

The ratios are geometric means of the medians of 5 runs on an otherwise idle machine; they move by several percent
with load. The largest gains are in bit operations and `Long` arithmetic on Lua 5.1 (about 0.1), collections and
sorting with comparators (0.35 to 0.55) and `String.format` (about 0.4). The JSON and UTF-16 text programs gained
least (about 0.8 to 0.9). `compiler/src/bench/PROFILE.md` has the baseline of each
program and the measurements behind each change.

**The generated code: microbenchmarks.** Seconds, `lua5.4 / luajit`, from `benchmarks/rt.sh -c`. `benchmarks/hand.sh`
times hand-written Lua versions of some of them. Measured for 0.2.0 on a shared 16-core Linux machine:

| program | k2l 0.2.0 | hand-written Lua |
|---|---|---|
| n-body (500k steps) | 1.04 / 0.06 | 0.98 / 0.06 |
| binary trees (depth 15) | 0.57 / 0.31 | 0.36 / 0.25 |
| 200k-object collection pipeline (filter, groupBy, sortedBy, ...) | 1.18 / 0.46 | |
| `HashMap`/`HashSet` workload with removals | 1.43 / 0.18 | |
| plain classes and virtual calls | 0.27 / 0.02 | |
| delegated properties, 1M iterations | 0.25 / 0.01 | |
| string building and splitting | 0.38 / 0.24 | |

**The compiler.** The JVM starts slowly, so the start script keeps an AppCDS archive of the loaded classes in
`${XDG_CACHE_HOME:-~/.cache}/k2l` (set `K2L_CDS_DIR` to move it, `K2L_NO_CDS=1` to turn it off; it is skipped when the
directory is not writable). The first run writes it; later runs start about twice as fast. Compile times before and
after the 0.2.0 changes, on an 8-core Linux machine:

| | before | 0.2.0 |
|---|---|---|
| `examples/hello` | 2.0 s | 1.1 s |
| 40 synthetic files (about 8k lines) | 287 s | 16 s |
| 200 synthetic files (about 70k lines) | 19 min 41 s | 52 s |

Compile time is roughly linear in the number of files (about 0.2 s per 350-line file), dominated by the Kotlin
front end (type resolution and checks). `K2L_PROFILE=1` prints the time of each phase.

Tips:

- Use `--target JIT` and LuaJIT for CPU-bound programs: it is 2 to 18 times faster than Lua 5.4 on these workloads.
- Plain classes, loops and arithmetic compile to what you would write by hand. The costs are in the library: a `Map` or
  `Set` keeps insertion order, so `remove` is linear in the entries after the removed one (removing the most recently
  added entries is cheap); prefer `clear` or building a new map when dropping many entries.
- `--strings utf16` makes every string operation aware of UTF-16 code units and costs roughly 25% on string-heavy code.
  Leave it off unless the program depends on `length`, `charAt` or `substring` of non-ASCII text.
- `--int-overflow wrap` adds a mask per `Int` operation; it was within noise on the benchmarks above, but tight integer
  loops pay for it. It is only needed when the program relies on overflow (hashing, random number generators).
- `for (i in 0 until list.size) list[i]` on a `MutableList` is bounds-checked on every access (`list:get(i)`); iterate with
  `for (x in list)` or `indices` over a `List`/array, which compile to direct indexing.

### Exact 64-bit `Long` and `ULong`: `--long64 emulate`

`--long64 emulate` (`"long64": "emulate"` in k2l.json, `long64.set("emulate")` in Gradle, `long64=emulate` in a test case's
`options.txt`) makes `Long` and `ULong` exact two's complement 64-bit values on Lua 5.1, 5.2 and LuaJIT, with the JVM's
wrapping `+ - *`, truncating `/` and `%`, `shl`/`shr`/`ushr` (counts use their low 6 bits), `and`/`or`/`xor`/`inv`,
`toInt()`/`toDouble()`/`Double.toLong()` (saturating), `Long.toString(radix)`, `"...".toLong()`, `hashCode()`, bit counts and
rotations, `Math.*Exact`, `floorMod`/`floorDiv`, `Double.toBits()`/`fromBits()`, `BigInteger.valueOf(x)`/`toLong()`,
`Random.nextLong()` and `java.util.Random(seed).nextLong()`. The default, `double`, leaves the generated code as it is; the option is
ignored on 5.3 and 5.4, whose integers are already 64-bit.

A value is a plain Lua number while it is a safe integer (|v| < 2^53) and a box beyond. A value always has the same form, so
`==` and table lookups stay exact, and numbers produced elsewhere (`size`, `Int.toLong()`, `System.currentTimeMillis()`) are
already valid `Long`s. Operations on `Long`-typed operands call small lualib functions that return the canonical form:

| | Lua 5.1 / 5.2 | LuaJIT |
|---|---|---|
| a box | a table `{hi, lo}` (signed high and unsigned low 32 bits) with `__add`, `__eq`, `__lt`, `__tostring` and the `toString`/`equals`/`hashCode`/`compareTo` methods | an `int64_t` cdata |
| `big + 1` | `__K2L_LAdd(big, 1)` (`a + b`, then a check that the result is a safe integer) | the same call; the slow path is `(a + 0LL) + b` |
| `a < b` | `__K2L_LLt(a, b)` on 5.1 (a number cannot be compared with a table there), `a < b` on 5.2 | `a < b` |
| `5000000000000000000L` | `__K2L_LLit(1164153218, 1156841472)` | `5000000000000000000LL` |
| `a shl 3`, `a and b`, ... | `__K2L_LShl(a, 3)`, `__K2L_LAnd(a, b)`: 32-bit halves, no bit library needed | the `bit` library on `int64_t` |

A `ULong` is the bit pattern of the `Long` with the same bits (`ULong.MAX_VALUE` is `-1`), exactly as on Lua 5.3/5.4: division,
remainder, comparison, `shr`, `toString()` and `toDouble()` use the static type. Loops over `Long` ranges (`for (i in a..b)`,
`until`, `downTo`, `step`) count iterations, so they work at the ends of the range (`Long.MAX_VALUE - 2..Long.MAX_VALUE`), and
`x in a..b` compares with the emulated operators. `HashMap`, `HashSet`, `sorted()`, `groupBy`, string templates, `String.format`
(`%d`, `%x`, `%,d`), `when`, `data class` equality and `sum()`/`sumOf`/`fold` all take boxes (on LuaJIT the collections hash the
cdata, since a table would compare it by identity).

Costs and limits: emulation is slower. With small values (the common case) a `Long` operation is a function call plus a range check:
about 5 to 8 times slower than a bare double operation on Lua 5.1/5.2 (`i.toLong() * i % 1000003L` over 300 000 iterations:
11 ms, 80 ms with `emulate`), and nearly free on LuaJIT, whose tracer inlines the calls (4 ms either way). Operations on boxes
cost about 0.5 to 1 µs on 5.1/5.2 (add 0.45, multiply 0.7, division by a number below 2^32 0.8, `toString` 2, division of two big values
6), and a native instruction on LuaJIT. Code that does not use `Long` is unchanged. Values that lose their static type are told apart only by
shape: a small integral number in an `Any` is both an `Int` and a `Long` (`x is Long` is true for `5`), and `hashCode()` of a
negative `Long` between -2^31 and 0 inside a `HashMap` is that of the `Int`, so the iteration order of such keys can differ
from the JVM's. `LongRange` objects (`(a..b).toList()`, `.sum()`, `step`, `reversed()`, `contains`) are a lualib class that compares and adds with
the emulated operators, so boxed bounds work too; `ULongRange` objects are not supported (loops and `in` over a `ULong`
range literal are). Collections of `ULong` order and compare as signed numbers (`sorted()`, `max()`): the static type is lost there. Boxes passed to Lua code you call through `@LuaExternal` are tables or cdata.

## Not supported yet

Reflection beyond the basics above: type checks against the reflection interfaces (`p is KProperty1<*, *>`), references to
library functions with a `vararg` parameter (`::listOf`), to library constructors whose call is not mapped (`::AtomicInteger`;
references to mapped ones such as `::StringBuilder`, `::ArrayList` and `::Regex` work) and to library properties k2l does not map
(each an error; the members that need kotlin-reflect throw, see [Reflection](#reflection)), and Kotlin itself forbids references to
member extension functions. Library properties that are overridden with a custom accessor
(`Throwable.message`/`cause`, `Continuation.context`, `CoroutineContext.Element.key`) work: library code that reads the field reaches
the getter. Through `super`, only `Any`'s `toString`/`equals`/`hashCode`, `Throwable`'s `message`/`cause`/`toString`/
`printStackTrace`/`fillInStackTrace` and the members of an extended library collection are available. Of the library's collection
classes, the abstract ones, `ArrayList`, `HashMap`, `LinkedHashMap`, `HashSet`, `LinkedHashSet`, `TreeMap`, `TreeSet`,
`PriorityQueue`, `java.util.ArrayDeque` and `LinkedList` can be extended, not the others (`Vector`, `WeakHashMap`, `EnumMap`,
`ConcurrentHashMap`, ...; `kotlin.collections.ArrayDeque` is final). Classes of the program can implement and delegate the
collection interfaces, `Comparator`, `Runnable`, `Callable`, function types, `Iterator`, `CharSequence`, `Comparable` and
`Sequence`, also next to a base class; delegating other library interfaces (`: CoroutineContext by context`,
`: Executor by e`) is not supported. A class that extends `AbstractCoroutineContextElement` and another class cannot exist in
Kotlin (two superclasses). Index assignments through operators declared as member extensions (`x[i] = v`, `x[i] += v` with an
`operator fun Int.set(...)` in a class; reading with such a `get` works) are not supported. kotlinx.coroutines is out of scope.
Each of these is reported as an error rather than miscompiled.

### Standard library coverage

Besides the language constructs above, k2l maps the commonly used parts of the Kotlin standard library
and checks them against the JVM (see the `stdlib_*` test cases). [docs/stdlib-coverage.md](docs/stdlib-coverage.md) lists, per
package, every public function and property and whether k2l translates it; `./gradlew :compiler:stdlibCoverage` regenerates it
(see [Development](#development)).

- `kotlin.collections`: the usual `List`/`Set`/`Map`/`Array` operations (sorting with comparators, grouping,
  `windowed`/`chunked`/`zipWithNext`, folds and running folds, slicing, set operations, `buildList` ...),
  iterator `remove()`, `HashMap`/`HashSet` with the JVM's iteration order, `TreeMap`/`TreeSet`, `ArrayDeque`,
  `PriorityQueue`, `java.util.EnumMap` and `EnumSet` (`noneOf`, `allOf`, `of`, `copyOf`, `range`, `complementOf`; a `TreeMap`
  and `TreeSet` in ordinal order with the JDK's classes and messages), `filterIsInstance<T>()`/`filterIsInstanceTo`, `maxOfWith`/`minOfWith`(`OrNull`). Sorting with a comparator or `compareTo` (`sortedWith`, `sortBy`, `sorted()` of
  objects, `Collections.sort`, `Arrays.sort(array, comparator)`, ...) is a port of the JDK's TimSort, so comparators,
  `compareTo` and the selectors of `sortedBy`/`compareBy` run as often and in the same order as on the JVM (a comparator that
  breaks its contract gets "Comparison method violates its general contract!" where the JDK detects it). Numbers and strings in
  natural order, and selectors that only read fields (`sortedBy { it.price }`), are sorted without calling anything per
  comparison, which gives the same result.
  `+`, `-`, `+=` and `-=`
  take the overload Kotlin resolved, so `lists += listOf(1)` on a `MutableList<List<Int>>` adds one element and
  `map += pairs` puts each pair. `kotlin.sequences`: the terminal and intermediate operations of `Iterable` (the `...To`
  forms, `firstNotNullOf`, `indexOfLast`, `reduceOrNull`/`reduceIndexed`, `runningFoldIndexed`, `groupingBy`, `joinTo`,
  `shuffled`, `requireNoNulls`, ...) pull one element at a time, so their lambdas interleave with those of the sequence as
  on the JVM.
- `kotlin.text`: searching, splitting (several delimiters, `limit`, `ignoreCase`), `substring*`, trimming,
  `trimIndent`/`trimMargin`/`prependIndent`, padding, conversions (`toInt(radix)`, `toDoubleOrNull`, ...),
  `String.format` (a `java.util.Formatter` implementation, with the number symbols of a `Locale`: flags, widths, precisions,
  `%1$s`/`%<s`, `%h`, and the Formatter's exceptions and messages; `%x`/`%o` of an argument whose static type is `Byte`, `Short` or
  `Long` give the two's complement of its width; a conversion rejects an argument by the class of its static type with
  `IllegalFormatConversionException`, as `f != java.lang.Integer` for `"%f".format(1)`; `%f` of a `BigDecimal` is exact),
  `StringBuilder`, `Char`
  classification, and `toUInt()`/`toULong()`/`toUByte()`/`toUShort()` with their `OrNull` and `radix` variants (a leading `+` is
  accepted, `-` is not, and the error is `NumberFormatException: Invalid number format: '...'`, as in Kotlin).
  Also `toByte()`/`toShort()` (and `OrNull`), `replaceAfter`/`replaceBefore`/`replaceAfterLast`/`replaceBeforeLast`,
  `splitToSequence`, `windowedSequence`/`chunkedSequence`, the folds, scans and `...To` operations over a string's characters
  (`foldRight`, `runningFold`/`scan`, `mapIndexedNotNull`, `associateByTo`, `toHashSet`, ...), `Char.isISOControl`,
  `toHexString()`/`hexToInt()`/`hexToLong()`/`hexToByteArray()`... with the default `HexFormat`, `Charsets.UTF_8` with
  `toByteArray(charset)`, `String(bytes)`/`decodeToString()`, the `StringBuilder` extensions `deleteAt`/`deleteRange`/`setRange`,
  and `startsWith`/`endsWith`/`contains` with an `ignoreCase` that is a variable.
- `kotlin.time`: `Duration` (`5.seconds`, `1.5.hours`, `toDuration(unit)`, `ZERO`/`INFINITE`, arithmetic and comparison,
  `inWhole...`, `toLong`/`toInt`/`toDouble(unit)`, `toComponents`, `toString()` and `toString(unit, decimals)` exactly as the JVM
  formats them, `toIsoString`, `parse`/`parseIsoString` and their `OrNull` forms), `DurationUnit`, `measureTime`/
  `measureTimedValue` with `TimedValue`, and the time marks of `TimeSource.Monotonic` and `TestTimeSource` (`markNow`,
  `elapsedNow`, `hasPassedNow`, `+`/`-`, comparison). A `Duration` keeps its nanoseconds: exact within ±104 days without Lua
  integers, ±146 years with them. `TimeSource.Monotonic` reads `os.clock()`, the processor time, as plain Lua has no monotonic
  wall clock. Not translated with `--long64 emulate`; `Instant` and `Clock` are not supported.
- `kotlin.math`, `Int`/`Long`/`Double` operations (`coerceIn`, `mod`, `floorDiv`, bit counting,
  `roundToInt` ...), ranges and progressions, `Pair`/`Triple`, `require`/`check`/`error`, `Result`. `hypot`, `atan`, `atan2`,
  `asin`, `acos`, `cbrt`, `sinh`, `cosh`, `tanh`, `expm1`, `ln1p` and `IEEErem` are ports of fdlibm, the `StrictMath` code the
  JVM runs for them, so they return the JVM's bits on every target (`FdLibm.lua`; they cost more than C's, about 0.5 µs a
  `hypot` on Lua 5.4 and 0.05 µs on LuaJIT); `sqrt` and the rounding functions are exact. `sin`, `cos`, `tan`, `exp`, `pow`,
  `ln` and `log10` are C's, while the JVM computes them with intrinsics of its own: over 2000 random arguments `ln` (and
  `log2`, which divides it by `ln(2)`) always agreed, `log10` differed in the last bit for 147, the others for 3 to 7.
  These stay on Lua's `math` library: the JVM allows `Math.sin` and the rest to differ from the exact result by 1 ulp,
  and its own results vary with the CPU, so there is no single answer to match. `java.lang.StrictMath` is bit-exact:
  its `sin`, `cos`, `tan`, `exp`, `log`, `log10` and `pow` are fdlibm ports as well (`StrictMath.lua`; the trigonometric
  ones reduce huge arguments such as `1e300` by π/2 with fdlibm's 1584 bits of 2/π), with the JVM's bits over 200000
  random arguments on every target, and its other members are `Math`'s.
  `min`/`max` of Doubles follow `Math.min`/`max` (NaN wins, `-0.0 < 0.0`).
- `kotlin.random.Random`: Kotlin's XorWow generator, so a seeded `Random(seed)` produces the same numbers as on the JVM:
  `nextInt`, `nextBits`, `nextBoolean`, `nextDouble`, `nextFloat`, `nextBytes`, ranges, `shuffle`/`shuffled` and `random`
  on every target; `nextLong` and `nextULong` beyond 2^53 need 64-bit integers (5.3+) or `--long64 emulate`. Unseeded
  generators are seeded from the clock. `realworld_sim_montecarlo` and `realworld_sim_random_long` check the JVM's sequences.
  A class or object extending `Random()` overrides `nextBits(bitCount)`, and every other member draws from it as Kotlin's
  default implementations do (`nextInt()` is `nextBits(32)`, `nextLong()` two `nextInt()`s, `nextDouble()`
  `nextBits(26)` and `nextBits(27)`, ranges by the same rejection loops), so `nextInt(until)`, ranges, `nextLong`,
  `nextDouble`, `nextFloat`, `nextBoolean`, `nextBytes`, `nextUInt`/`nextULong` and the extensions taking a `Random`
  (`shuffled(rng)`, `shuffle(rng)`, `random(rng)`) give the JVM's numbers for the same `nextBits`. It may also override
  `nextBoolean` and `nextFloat`; overriding an overloaded member (`nextInt`, `nextLong`, `nextDouble`, `nextBytes`) is
  reported as unsupported, since their overloads share one Lua method.
- `Regex`: an own backtracking engine implementing the common `java.util.regex` syntax (classes, groups,
  named groups, back-references, lazy and possessive quantifiers, lookahead and lookbehind, `IGNORE_CASE`/`MULTILINE`/
  `DOT_MATCHES_ALL`); `find`, `findAll` (a lazy `Sequence`, as in Kotlin), `matches`, `replace` (with `$1` and lambdas), `split`,
  `destructured`, `matchAt`/`matchesAt`, class intersection (`[a-z&&[^aeiou]]`).
  Match indices are bytes (UTF-16 units with `--strings utf16`); classes such as `\w` are ASCII only, as in Java. Every general
  category Java accepts works, in each of Java's spellings: `\p{Lu}`, `\p{IsLu}`, `\p{gc=Lu}`, `\p{general_category=Lu}`,
  `\pL`, the groups `\p{L}`, `\p{LC}`, `\p{M}`, `\p{N}`, `\p{P}`, `\p{S}`, `\p{Z}` and `\p{C}`, negated as `\P{..}` or in
  classes (`[^\p{Lu}\p{Nd}]`); with `IGNORE_CASE` (or `(?i)`) `\p{Lu}`, `\p{Ll}` and `\p{Lt}` match all three, as in Java. So do
  the binary properties (`\p{IsAlphabetic}`, `\p{IsUppercase}`, in any case). They test non-ASCII characters with
  `--strings utf16` (see [Strings](#strings)); without it they are ASCII only: a non-ASCII character is in no category (and
  matches every `\P{..}`). In ASCII, `` $+<=>^`|~ `` are symbols and the other POSIX punctuation is `\p{P}`, while `\p{Punct}`
  is POSIX's ASCII punctuation, as in Java. Scripts and blocks (`\p{IsLatin}`, `\p{InGreek}`, `\p{sc=Greek}`) are not
  supported: such a pattern throws `PatternSyntaxException`'s message as an `IllegalArgumentException`.
  A lookbehind tries only the start positions its lengths allow, as Java's does: `(?<=ab{1,3})` looks back 2 to 4
  characters, not to the start of the input. Java's rules for its maximum length apply: a lookbehind with a
  back-reference, or with a repeated group whose body has alternatives or variable repetitions (`(?<=(a|bc){2})`,
  `(?<=(?:ab)*)`), throws Java's `PatternSyntaxException` ("Look-behind group does not have an obvious maximum length");
  the unbounded forms Java accepts (`(?<=a+)`, `(?<=x.*)`) look back to the start of the input, as in Java.

- Numbers: `Float` (single precision), `UByte`/`UShort`/`UInt`/`ULong` with literals, arithmetic, comparison, shifts, bit
  operations, conversions, ranges and `UIntArray`s, `Math.addExact`/`subtractExact`/`multiplyExact`/`negateExact`/
  `incrementExact`/`decrementExact`/`toIntExact`/`absExact`, `rotateLeft`/`rotateRight` (also of `Byte`, `Short`, `UByte`, `UShort`; `ULong.toString(radix)`), `takeHighestOneBit`/`takeLowestOneBit`,
  `Long` bit counts, `withSign`, `ulp`, `nextUp`/`nextDown`/`nextTowards`, `toBits`/`toRawBits`/`fromBits`,
  `Random.nextLong(bound)`, `nextLong(from, until)`, `nextUInt` and `nextULong` (seeded sequences match the JVM on 5.3+, and with `--long64 emulate` everywhere).
- `java.math`: `BigInteger` (sign and magnitude over base 10^7 limbs, 10^9 with the integers of Lua 5.3+, so every product is exact; Knuth division,
  `modPow`, `gcd`, `sqrt`, `isProbablePrime`, two's complement `and`/`or`/`xor`/shifts, JVM `hashCode`, `toInt`/`toLong` wrap
  like the JVM), `BigDecimal` (unscaled value plus scale; all `RoundingMode`s, `MathContext` division and rounding,
  scale-sensitive `equals`, JVM `toString`/`toPlainString`, `stripTrailingZeros`, and `sqrt(MathContext)`: the JDK's own Newton
  iteration, so the digits, the preferred scale `scale() / 2`, the rounding modes and the `ArithmeticException`s match), and Kotlin's operators and
  `toBigInteger()`/`toBigDecimal()` conversions. In Lua the Java keyword methods are `band`/`bor`/`bxor`/`bnot`.
- `java.util.stream`: see [Streams](#streams) below.
- `java.util.Collections` and `Arrays` helpers (`sort`, `reverse`, `shuffle`, `swap`, `max`/`min`, `frequency`, `nCopies`,
  `rotate`, `binarySearch`, `fill`, `copyOf`, `toString`, `deepToString`, `asList` ...) and `java.util.Random` (the JVM's
  48-bit generator: seeded sequences, `shuffle(list, Random(seed))` and `nextGaussian` match the JVM).
  `Map.withDefault { }` (`getValue` uses the default, `get` does not) and `listIterator()` with `hasPrevious`/`set`/`add`/`remove`.
  Arrays have `contentHashCode`, `contentDeepHashCode` and `contentDeepEquals`.
  `java.util.Stack` (a list with `push`/`pop`/`peek`/`empty`/`search`; an empty stack throws `EmptyStackException`),
  `StringJoiner` (`add`, `setEmptyValue`, `merge`, `length`, in UTF-16 units with `--strings utf16`) and
  `Objects.requireNonNull` (with a message or a supplier), `requireNonNullElse`, `isNull`/`nonNull`, `toString(o, default)`,
  `checkIndex` and `compare`. `Comparator.comparingInt`/`comparingLong`/`comparingDouble`, `thenComparingInt`/`Long`/`Double`
  and `Comparator.nullsFirst`/`nullsLast`.
  Collections and boxed arrays convert to every primitive array (`toCharArray()`, `toIntArray()`, `toLongArray()`,
  `toDoubleArray()`, `toFloatArray()`, `toBooleanArray()`, `toByteArray()`, `toShortArray()`), and back with `toList()`,
  `toTypedArray()`, `asList()`, ...
- `java.lang` statics: `Integer`/`Long` `bitCount`, `numberOfLeadingZeros`/`numberOfTrailingZeros`, `highestOneBit`/`lowestOneBit`,
  `rotateLeft`/`rotateRight`, `signum`, `max`/`min`, `Integer.reverse`, `toUnsignedString`, `toBinaryString`/`toHexString`/
  `toOctalString`, `Double.isNaN`/`isInfinite`/`valueOf`/`toString`, `Boolean.parseBoolean`, `Character.getNumericValue` (ASCII
  digits and letters), `String.valueOf` and `String.join`, `Boolean.compare`/`logicalAnd`/`logicalOr`/`logicalXor`/`valueOf`,
  `Character.digit`/`forDigit`, `Double.max`/`min`/`sum`, and the static `hashCode(x)` of each box.
- `kotlin`: also `Boolean.and`/`or` (both operands evaluated), `lazyOf`, `enumValues<E>()`/`enumValueOf<E>(name)` (of the
  program's enums, also with a reified `E`), `setOfNotNull` and `reduceRightOrNull`/`reduceRightIndexed(OrNull)` of lists and
  arrays.
- `Number`: `is Number` (Lua numbers, emulated Longs, `BigInteger`, `BigDecimal`) and `toInt()`/`toLong()`/`toDouble()`/... of a
  `Number`-typed value; an integral number converts like a `Long`, a fractional one like a `Double`.

`Collections.unmodifiableList/Set/Map/Collection` are live read-only views: a table that forwards every read to the collection
(so later changes show through, a `HashMap` keeps its order) and throws `UnsupportedOperationException` for the mutating methods and
for writes by index. Lua before 5.3 does not follow `__index` in `ipairs`, so when a program mentions `unmodifiableList`,
`unmodifiableCollection`, `subList` or `asList`, or declares a class extending `AbstractList` or implementing `List`, the generated loops over lists index
them (`for i = 1, xs.size do`) instead of using `ipairs`; spreading a view (`*view`) into `vararg` arguments is not supported on those
versions.

Big numbers and JDK helpers differ from the JVM in: `BigInteger.toLong()` and `Random.nextLong()` are exact only on Lua 5.3+ (above 2^53) or with `--long64 emulate`; `Float.toBigDecimal()` sees the float
as a double.

Not available: locale rules other than Turkish, Azeri and Lithuanian case mapping, display names in a language other than English,
code points without `--strings utf16`, `Stream.spliterator()`, `mapMulti` and the concurrent and `teeing` collectors.

Known differences: `Int` overflow is not wrapped unless `--int-overflow wrap` is given (`UInt` always wraps);
a `Float` or `ULong` among untyped values (a collection, `Any`, nullable) loses its static type: a number that is exactly a float
and has a long double representation prints as a `Float`, so a `Double` equal to `0.1f.toDouble()` in a list prints `0.1`, and a `ULong`
from 2^63 prints as a negative number; on Lua 5.1, 5.2 and LuaJIT an integral `Double` among untyped values prints like an
`Int` (`3` for `3.0`), except in a collection, map or pair whose static type makes every number in it a `Double`
(`List<Double>`, `Map<String, Double>`, `Pair<String, Double>`: these print `[3.0]`; a `Map<Int, Double>` or a `List<Any>` does not),
and `ULong` and `Long` are exact only up to 2^53 (unless
`--long64 emulate`, see [above](#exact-64-bit-long-and-ulong---long64-emulate)) and
`Double.toBits()` keeps 53 bits (`Float.toBits()` is exact); `Math.*Exact` of `Long` checks ±2^63 on doubles;
`x in a..b step s` over a `Long` range wider than `Long.MAX_VALUE` can be wrong, as `x - a` wraps;
`nextLong(bound)` there is JVM-exact only below 2^52; `Char.isLetter()` etc. are ASCII only unless `--strings utf16` (see [Strings](#strings));
removing a `TreeMap` key whose node has two children moves the next key into that node on the JVM, so an entry read
before for the next key is detached there (and one for the removed key shows the next key), while k2l's entries stay with
their keys; a `TreeSet` held in a `Collection` answers `first()`/`last()` with its own members (the JVM calls the stdlib's, which use `iterator()`).
Indexing of lists and arrays, `substring`, `subSequence`, `first()`/`last()` of an empty string, `repeat`, `padStart`, `/`, `%`,
`rem`, `mod` and `floorDiv` throw the same exception types and messages as the JVM. Doubles keep IEEE behaviour
(`x / 0.0` is Infinity, `x % 0.0` is NaN, `==` of two `Double`s is IEEE), and boxed Doubles (in collections, `Any`,
type parameters, `Pair`, data class properties) compare with `Double.equals` as on the JVM: NaN equals NaN and `0.0`
differs from `-0.0`. Where Lua has no integer subtype (5.1, 5.2, LuaJIT) an integral `Double` and the `Int` of the same
value are the same key of a `HashMap` or `HashSet` and are equal in an `Any` (on 5.3/5.4 too, `3.0` and `3` share a table
key), where the JVM keeps a `Double` and an `Int` apart.

`String.format` checks the conversions against the static types of the arguments; an argument held in an `Any` (or a collection)
is checked by its value, which cannot tell everything: `%f` of an `Int` held in an `Any` prints instead of throwing
`IllegalFormatConversionException` (and so does `%d` of an integral `Double` on Lua 5.1, 5.2 and LuaJIT, and `%c` of a one-character
`String`), `%s` of a `Double` prints like a number in an `Any` when the format is not a literal, and `%x` of a negative `Long` held
in an `Any` is 32-bit while it fits an `Int`.

#### Other semantic differences

Other semantic differences to be aware of: strings are byte strings (unless `--strings utf16`), so `length` and indexing count
UTF-8 bytes; a file's top-level properties whose initializers can be noticed wait for the first read or write of one of
them (see [Lazy initialization](#lazy-initialization)), while the JVM initializes the file's facade class on any first use,
so calling one of its functions that prints before it touches a property prints earlier on the JVM; Lua runtime errors are caught as
`RuntimeException`, except that an overflow of the Lua or the C stack is a `StackOverflowError` (so `catch (e: Exception)` lets
it through); a Unit returned by Lua code called through `@LuaExternal` is `nil`, so it prints as `null`. Each `try`
(and `use`, `runCatching`, ...) runs its block in a protected call (`__K2L_DeepPcall`), and Lua 5.1 to 5.4 allow only about 200
nested C calls, a `pcall` being one: on Lua 5.2 to 5.4 every hundredth nested protected call runs in a coroutine of its own,
resumed by a driver around `main` (`__K2L_DeepMain`) from the bottom of the C stack, so a recursion through `try` blocks goes some
20000 levels deep before it ends in a `StackOverflowError`. An error that ends `main` under the driver prints as an [uncaught exception](#uncaught-exceptions), with the traceback of the stack where it happened. That needs the driver: the protected calls of `try` blocks inside a
Kotlin coroutine or a `sequence { }` (which run in coroutines of their own), of top-level property initializers and of functions
called from Lua through `@LuaExternal` exports stay plain `pcall`s, and so do all of them
on Lua 5.1, where a recursion through a `try` block at every level fails with "C stack overflow" after roughly 190 levels (LuaJIT
goes much deeper by itself). That is a limit of Lua 5.1 that k2l cannot work around: there every protected call (`pcall`, `xpcall`,
and also `coroutine.resume`, since a coroutine starts from its resumer's count of nested C calls) counts against
`LUAI_MAXCCALLS` (200), so running a `try` body in a coroutine instead fails at the same depth; only a yield unwinds the C stack,
and 5.1 cannot yield across a `pcall`, nor across a `for ... in` iterator, a metamethod, a `table.sort` comparator or a `gsub`
callback. Running every `try` body as a coroutine of a driver would need to know that no such boundary lies between the `try`
and the driver, which Lua 5.1 has no way to test without a `pcall` (`debug.getinfo` cannot tell a metamethod frame or a call
after a tail call from a plain call), and would make every `try` cost a coroutine (some eight times a `pcall`). Unchecked casts (`x as T` of an erased `T`, `x as List<String>`) check nothing, as on
the JVM, whose erased generic code throws `ClassCastException` later, where Kotlin emits a CHECKCAST: k2l checks there the values
of the common sources, calls of functions and property getters of the program whose body casts to a type parameter and
returns it (`val s: String = unsafeCast(5)`, `box.get().length`, `slots[0]` with an `operator fun get`), and reads through a cast
to a generic type, a local `val` it initializes, or a property it initializes or is passed to (`l[0].length`, `l.first()`,
`m["a"]!!`, `for (s in l)`, `(x as List<String>)[0]`, `Box(l).items[0]` for `class Box(val items: List<String>)`, a property
assigned `l`), when they meet a concrete type (a variable, a parameter, a receiver of a member, a branch of an `if` of that type)
and not when they meet `Any` or a type parameter (`println(x)`, a template, `==`). A lambda literal passed to a call on such a
value or on a chain of calls from one (`l.map { it }`, `l.filter { true }`, `l.asSequence().map { }`) checks its arguments
against its concrete parameter types as it starts, used or not, as the JVM does. An unchecked value that reaches a concrete type
another way flows on unchecked: an element passed to a function value not written at the call (`l.map(f)`; the JVM checks in
`f`'s class, and checking every lambda's arguments would cost every call of every lambda), a value passed through a parameter
(`l.let { it.map { } }`, `fun f(xs: List<String>)`) or from one property to another (k2l follows only the cast's own local or
property). A `Double` read from an unchecked `Int` stays an integral number.

## Development

```sh
./gradlew test                     # transpile + run every test case on every Lua interpreter found
./gradlew test -PupdateGolden      # rewrite expected.lua files after an intended output change
./gradlew test -Ponly=casts,lazy_objects   # only these cases (also for kotlinOracle)
./gradlew :compiler:kotlinOracle   # check each stdout.txt against what Kotlin/JVM prints
./gradlew check                    # tests + Gradle plugin functional tests + ktlint (spotlessCheck) + detekt, as CI runs it
./gradlew :gradle-plugin:functionalTest   # only the TestKit tests of the Gradle plugin (about 15 s)
./gradlew spotlessApply            # reformat Kotlin sources with ktlint
./gradlew :compiler:distZip        # compiler/build/distributions/k2l-<version>.zip, the CLI distribution
./gradlew :compiler:stdlibCoverage # regenerate docs/stdlib-coverage.md (-PcoverageOnly=kotlin.time prints one area instead)
./gradlew publishToMavenLocal      # install compiler, lua-api and the plugin into ~/.m2 to try them in another project
```

The version of everything (including `k2l --version`) is the `version` in `gradle.properties`. See
[RELEASING.md](RELEASING.md) for cutting a release.

Kotlin code is formatted with ktlint (settings in `build.gradle.kts`) and analyzed with detekt
(overrides in `config/detekt.yml`); compiler warnings are errors.

Each directory in `compiler/src/test/cases` is a program: `main.kt` (plus any other `.kt` files),
`expected.lua` (the exact Lua output for 5.4), and `stdout.txt`. The tests also run each program on
Lua 5.1, 5.2, 5.3 and LuaJIT when those interpreters are installed (`lua5.1`, `lua5.2`, `lua5.3`,
`luajit`; override with `-Dk2l.lua51=...` etc.). Expected output isn't written by hand: the
`kotlinOracle` task compiles and runs each case with the real Kotlin compiler (`-PupdateOracle`
rewrites the files). A case with `errors.txt` instead checks the diagnostics; `targets-skip.txt`
lists documented differences on specific targets (`5.4:` skips the run of the golden Lua); `jvm-skip` marks cases that call hand-written Lua; `options.txt` sets compiler options for a case, one
`name=value` per line (`intOverflow=wrap`, `luaLibImport=inline`, `strings=utf16`, `long64=emulate`).

Layout:

- `compiler/src/main/kotlin/dev/k2l/frontend`: the standalone Analysis API session.
- `.../transform`: Kotlin PSI and types to a Lua syntax tree (`FileTransformer`, plus the
  stdlib and collection mappings).
- `.../codegen`: the Lua syntax tree, its printer and the lualib loader.
- `compiler/src/main/resources/dev/k2l/lualib`: the runtime, as plain Lua; `Name.float.lua` and
  similar files are target-specific variants.
- `lua-api`: the `dev.k2l.lua` interop declarations.
- `gradle-plugin`: the `dev.k2l` Gradle plugin and its TestKit tests (`src/functionalTest`).
- `compiler/src/bench`: the benchmark harness (`kotlin`) and its programs (`programs`), see below.
- `compiler/src/coverage`: the standard library audit behind `stdlibCoverage`, see below.

### Standard library coverage report

`./gradlew :compiler:stdlibCoverage` writes [docs/stdlib-coverage.md](docs/stdlib-coverage.md) (about a minute). It lists the
public functions, properties and constructors of `kotlin`, `kotlin.collections`, `kotlin.text`, `kotlin.sequences`,
`kotlin.ranges`, `kotlin.comparisons`, `kotlin.time`, `kotlin.properties`, the commonly used `java.util` classes,
`java.lang.Math`, `StringBuilder` and the `java.lang` box statics with the Analysis API, writes a small probe function per
overload (receiver and arguments as parameters, operators and infix calls in their syntax, trailing lambdas, once with only the
required arguments and once with all), and transpiles the probes in-process, 150 to a file. A probe that does not compile as
Kotlin, or that resolves to another overload, is set aside; a file k2l crashes on is split up to find the probe. Probes that
need `--strings utf16` are run again with it. Deprecated and experimental APIs are listed but not counted. `check` only compiles
the audit; rerun it after adding a mapping and commit the report. `-PcoverageOnly=kotlin.text,java.util` prints the
unsupported names of some areas instead of writing the report.

### Benchmarks

`compiler/src/bench/programs` holds 17 programs adapted from the `realworld_*` test cases and scaled up (a `SIZE` constant at
the top of each) to run for roughly 0.5 to 2.5 s on Lua 5.4: collections (`coll_*`), strings (`str_*`), classes and lambdas
(`oop_*`), numbers (`num_*`, including `--int-overflow wrap` and `--long64 emulate`) and `--strings utf16` text. Each one
prints a small checksum; its `stdout.txt` comes from Kotlin/JVM, like a test case's (`options.txt` works the same way).

```sh
./gradlew :compiler:bench                          # every program x every Lua found, 5 runs, compared with the baseline
./gradlew :compiler:bench -PbenchRuns=3 -PbenchOnly=coll_grid,str_parse -PbenchTargets=5.4,JIT
./gradlew :compiler:bench -PbenchSave              # also write compiler/src/bench/baseline.json (or -PbenchSave=other.json)
./gradlew :compiler:bench -PbenchCompare=other.json   # compare with another file (-PbenchCompare=none: no comparison)
./gradlew :compiler:bench -PbenchProfile           # sampling profile on 5.4 and LuaJIT instead of timings (-PbenchTargets=...)
./gradlew :compiler:benchOracle -PupdateOracle     # rewrite the programs' stdout.txt from Kotlin/JVM
```

Each run transpiles the programs with the current compiler, runs each on each target and fails a cell whose output differs
from `stdout.txt`. It prints the median and minimum wall time per program and target, writes them to
`compiler/build/bench/results.json` and `results.csv`, and, when `compiler/src/bench/baseline.json` exists, prints the
ratio of each median to the baseline's and the geometric mean per target (below 1.00 is faster). Wall times depend on
the machine, so compare runs from the same one, and keep the baseline in step with the code it measures.

With `-PbenchProfile` each program runs once (ten times on LuaJIT) under `compiler/src/bench/resources/.../profiler.lua`
and `compiler/build/bench/profile/<target>/` gets a report per program plus `summary.txt`: functions by self and inclusive
samples, the hottest lines, and the Kotlin lines that call the hottest lualib functions. Program lines are mapped back
to Kotlin through the source map, and lines of `lualib_bundle.lua` to the lualib file and function they come from
(`Collections.lua:3886 siftDown`). On PUC Lua the profiler is a count hook every 1000 VM instructions
(`-PbenchInterval=...`), which does not see time spent inside C functions such as `string.format` or `table.concat`;
on LuaJIT it is `jit.profile` (1 ms), which keeps the JIT compiler on and also reports the VM states (compiled,
interpreted, GC). `compiler/src/bench/PROFILE.md` is the latest analysis of these profiles.

The harness is not part of `check` (only `BenchProgramsTest`, which checks that the programs transpile on every target).
The older shell scripts in `benchmarks/` time the compiler itself and a few runtime microbenchmarks.

The Analysis API artifacts come from JetBrains' `intellij-dependencies` repository and must match the
Kotlin version exactly; see the comments in `gradle/libs.versions.toml` before upgrading.
