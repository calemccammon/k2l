# Changelog

All notable changes to k2l. The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/). The version lives in `gradle.properties`.

## [Unreleased] (0.2.0)

The first release. Nothing has been tagged yet; earlier work was built as the untagged version 0.1.0, and git history
keeps its details.

### The rescoping

k2l used to emulate the JVM in Lua: 32-bit `Int` and exact 64-bit `Long` arithmetic, UTF-16 strings, the JDK's
collections and their iteration order, `java.util.Formatter`, a Java regex engine, reflection and JVM-format stack
traces. It now follows [TypeScriptToLua](https://typescripttolua.github.io/): Kotlin's compile-time checks, plain Lua at
run time, and a short list of documented differences ([Caveats](README.md#caveats)) instead of emulation. A library API
k2l does not translate is a compile error. The generated code needs nothing third-party.

### What k2l supports

- **Targets:** Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT.
- **Language:** functions, classes, interfaces, objects, companion objects, enums, data, sealed, inner, local and
  anonymous classes, value classes; null safety and smart casts; `when` with subjects, ranges and guards; extension
  functions and properties; generics; `inline` functions with `reified` type parameters and non-local `return`, `break`
  and `continue`; named and default arguments; `vararg`; operator overloading and destructuring; lambdas, function
  references and `fun interface`; delegated properties and interface delegation; `lateinit`; exceptions with
  `try`/`catch`/`finally`; multi-file programs with import cycles.
- **Standard library:** the core of `kotlin.collections`, `kotlin.sequences`, `kotlin.comparisons`, `kotlin.text`,
  `kotlin.ranges`, `kotlin.math` and `kotlin.random` on Lua numbers, byte strings and tables; `StringBuilder`;
  `String.format` on `string.format`; `Result`, `lazy`, and the property delegates.
- **Coroutines:** `suspend` functions, `startCoroutine`, `suspendCoroutine`, contexts, interceptors and the intrinsics on
  Lua coroutines; `sequence { }` and `iterator { }`.
- **Regex** on Lua patterns: a documented subset of the syntax, translated at compile time. Patterns must be
  compile-time constants, and a construct Lua patterns lack is a compile error.
- **Lua interop:** `@LuaExternal`, `@LuaName`, `@LuaRequire`, `@NoSelf`, `LuaTable` and `LuaMultiReturn2`/`3` in
  `dev.k2l.lua` (`lua-api`); every file is a Lua module that hand-written Lua can `require`.
- **Tooling:** the `k2l` CLI and `k2l.json` projects, `k2l --check`, `--watch`, source maps with Kotlin positions in Lua
  errors and tracebacks, diagnostics with the source line and hints, and the `dev.k2l` Gradle plugin
  (`compileKotlinToLua`, `k2lCheck`).
- **Development:** golden tests recorded from Lua 5.4 with per-target `stdout.<target>.txt` overrides, CI shards per Lua
  target, and the `./gradlew :compiler:bench` benchmark harness with a sampling profiler.
- **Packaging:** one version for every artifact, a CLI zip with the README, and publishing configuration for Maven
  Central and the Gradle Plugin Portal.

### Removed in the rescoping

- The JVM number semantics: `--int-overflow wrap`, `--long64 emulate`, exact `Long` bit operations on double-only
  targets, single-precision `Float`, and the JVM's number printing, rounding and `-0.0`/NaN rules.
- The unsigned types, `java.math` (`BigInteger`, `BigDecimal`) and `kotlin.time`: now compile errors.
- `--strings utf16`, code points and surrogates, `java.util.Locale`, the Unicode character categories, and the
  `java.util.Formatter` emulation.
- The JDK's collections and helpers (`TreeMap`, `TreeSet`, `PriorityQueue`, `LinkedList`, `java.util.ArrayDeque`,
  `Collections.*`, `Arrays.*`, streams, `Optional`, ...) and the `java.lang` statics of the boxed types.
- The JVM collection behaviour: live views, `ConcurrentModificationException`, read-only collection classes, `HashMap`
  bucket order and the JDK's TimSort call order.
- Reflection beyond `::class.simpleName`, and unchecked-cast checks.
- Kotlin's `Random(seed)` sequences (XorWow) and `java.util.Random`.
- The Java regex engine, and patterns built at run time.
- The JVM-format uncaught-exception output (`Caused by:`) and the deep-`try` driver.
- `DeepRecursiveFunction`, the IEEE bit APIs of `Double`/`Float` (`toBits`, `ulp`, `nextUp`, ...), and the per-element-type
  array classes (`is IntArray`; arrays now print their elements).
- All third-party code and data: the ports of the JDK's TimSort and of fdlibm/StrictMath, and the tables generated from the
  JDK's Unicode and CLDR data.
- The Kotlin/JVM oracle that recorded expected output from the JVM, the snapshot test, the standard library coverage
  report, the porting reports, the shell-script benchmarks and the old benchmark profile notes.

[Unreleased]: https://github.com/calemccammon/k2l/commits/main
