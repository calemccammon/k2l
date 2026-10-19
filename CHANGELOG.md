# Changelog

All notable changes to k2l. The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/). The version lives in `gradle.properties`.

## [Unreleased] (0.2.0)

### Added
- Release engineering: the version is defined once (`gradle.properties`) and `k2l --version` reports it; the CLI
  distribution (`./gradlew :compiler:distZip`) now includes the README (and a LICENSE once the repository has one);
  a tag-triggered GitHub Release workflow; Maven Central (Central Portal) and Gradle Plugin Portal publishing
  configuration for `dev.k2l:compiler`, `dev.k2l:lua-api` and the `dev.k2l` plugin; `RELEASING.md`.
- The compiler publishes `compiler-<version>-runtime-libs.zip`, a self-contained archive of its runtime classpath that
  the Gradle plugin resolves, so the plugin works from Maven Central without the JetBrains-only Analysis API
  repositories.
- References to library properties (`String::length`, `"abc"::length`, `List<*>::size`, `Pair<*, *>::first`,
  `Map.Entry<*, *>::key`, `String::lastIndex`, `CharSequence::indices`, `Int.Companion::MAX_VALUE`, ...) are property references
  with `name`, `get` and `invoke`; `map(String::length)` still passes a plain function.
- References print and compare like the JVM's without kotlin-reflect (`function twice (Kotlin reflection is not available)`,
  `==` and `hashCode()` between references to the same callable and receiver), also references to library functions.
- The members of references that need kotlin-reflect (`KFunction.parameters`, `returnType`, `isSuspend`, `call`, `visibility`,
  `KProperty.getter`, `isConst`, `isLateinit`, `annotations`, ...) throw `KotlinReflectionNotSupportedError`, as on the JVM.
- The `KProperty` passed to delegates is a property reference: it prints like the JVM's and is `==` to `Holder::x`.
- A companion object's value has the companion's class (`Outer.Companion`, `simpleName` `Companion`).
- `KClass` prints like the JVM's without kotlin-reflect (`class app.Dog (Kotlin reflection is not available)`), and `javaClass`
  and `KClass.java` are a `Class` object of their own that prints like `java.lang.Class`.
- References to delegated properties (`Holder::x`, `::delegated`).
- Standard library: `String.toUInt()`, `toULong()`, `toUByte()`, `toUShort()` with their `OrNull` and `radix` variants (Kotlin's
  rules and `NumberFormatException` message) and `ULong.toString(radix)`; `rotateLeft`/`rotateRight` of `Byte`, `Short`, `UByte` and
  `UShort`; `BigDecimal.sqrt(MathContext)` as the JDK computes it (precision, rounding modes, preferred scale, exceptions).
- `java.util.stream`: `Stream`, `IntStream` and `DoubleStream` (lazy like the JDK's, `Arrays.stream`, `collection.stream()`,
  `IntStream.range`, the common stages and terminal operations), `Optional`, `OptionalInt`, `OptionalDouble` and the common
  `Collectors`; `String.chars()`/`codePoints()` are the same `IntStream`. `Integer.valueOf(String)` and `Long.valueOf(String)` parse.
- Locales: English display names (`displayLanguage`, `displayCountry`, `displayName`, `getDisplayLanguage(Locale)` ...) generated
  from the JDK by `compiler/tools/GenLocale.java`, and `String.format(locale, ...)` with the decimal separator, grouping separator,
  group size and digits of every locale the JDK has (`%S` follows the locale's case rules with `--strings utf16`). More `Locale`
  constants (`KOREA`, `CHINESE`, `TAIWAN` ...).
- `--strings utf16`: `trimIndent`/`trimMargin`/`prependIndent` measure indents by `Char.isWhitespace`; `toInt()`, `toLong()`, the
  unsigned conversions and `Integer.parseInt` accept Unicode digits (and fullwidth letters above radix 10, as `digitToInt` does);
  empty regex matches stop between the halves of a surrogate pair like `java.util.regex`; `contains`, `replace`, `split`,
  `startsWith`, `removePrefix`, `substringBefore` ... find one half of a pair inside a pair. Regex patterns accept `\x{1F600}` and
  `\uD83D\uDE00`.
- Classes can extend `AbstractList`, `AbstractMutableList`, `AbstractCollection`, `AbstractMutableCollection`,
  `AbstractSet`, `AbstractMutableSet`, `AbstractMap`, `AbstractMutableMap`, `AbstractIterator`, `ArrayList`, `HashMap`,
  `LinkedHashMap`, `HashSet` and `LinkedHashSet`, and implement `List`, `Set`, `Map`, `Collection`, `Iterable`,
  `MutableIterator`, `ListIterator` and `Map.Entry`: every inherited operation (`contains`, `toString`,
  `equals`/`hashCode`, iteration, `for` loops, the extension functions) works on instances, built on the members the
  class overrides as the JDK and the Kotlin stdlib do, and `super.add(x)` and the like call the library member.
- Classes implementing `Comparator`, `Runnable`, `Callable` and function types (their objects are callable, so they work
  wherever a lambda does), `CharSequence`, `Iterator`, `Iterable` and the collection interfaces; `Runnable { }` and
  `Callable { }` SAM constructors; `fun interface` SAM constructors and conversions of lambdas passed for them; `is
  Comparator`; `coerceAtLeast`/`coerceAtMost` of `Comparable` values.
- `LinkedHashMap(capacity, loadFactor, accessOrder = true)` keeps the access order, and `removeEldestEntry` is honored.
- `sortedArrayWith`.
- Language gaps: companion objects implementing interfaces or extending classes (`Foo.Companion`, usable as a value of
  those types); multi-index operators (`m[i, j]`, `m[i, j] += v`, `m[i, j]++`, also extension operators); `x in a..b step s`
  (and `downTo`/`until`, `!in`, `when` branches) matching the progression's elements; references to library constructors
  (`::ArrayList`, `::Pair`, `::StringBuilder`, `::IllegalStateException`, `::Regex`, ...); labels on expressions other
  than loops; interface delegation (`class C(impl: I) : I by impl`, several and generic interfaces, objects and
  companions, default methods and properties forwarded); stepped `in` for `UInt`/`ULong` ranges; object expressions
  (`object : I { }`, with a base class, anonymous types, captured locals and `this`, JVM class names).
- Non-local `return`, `break` and `continue` (labeled too) out of a lambda passed to any inline library function,
  also those k2l does not expand into a loop (`trim { }`, `mapCatching`, `recoverCatching`, `List(n) { }`, `Array(n) { }`,
  `zipWithNext { }`, the terminal functions of a `Sequence`, ...): the lambda raises a token that the call, run in a
  `pcall`, turns into the jump. `catch` blocks and `runCatching` never see it; `finally` blocks and `use` still run.
- A lambda parameter of an expanded `inline fun` can be passed on to a library function (`s.trim(predicate)`).
- `Unit` is a value: `println(u())`, `"${u()}"`, `listOf(Unit)`, `val a: Any = Unit`, `runCatching { u() }`,
  `runCatching(::u)` and `map { u() }` print `kotlin.Unit` like the JVM, and `is Unit` works (the runtime object
  `__K2L_Unit`). Calls of Unit functions as statements generate the same code as before.

### Changed
- Collections have the JVM's classes: `listOf()`/`emptyList()` are Kotlin's `EmptyList`, `listOf(x)` a
  `Collections$SingletonList`, `listOf(a, b, ...)`, `asList()` and the `sorted*()` results an `Arrays$ArrayList`, and the
  `setOf`/`mapOf`/`emptySet`/`emptyMap` variants and `java.util.Collections`' own likewise; `toList()`, `toSet()`, `toMap()`,
  `take`, `drop`, `distinct`, ... return them for zero and one element as Kotlin does. `::class`, `javaClass.name`,
  `simpleName`, index messages ("Index: 1, Size: 1", "Empty list doesn't contain element at index 0.") and the read-only
  behavior (`UnsupportedOperationException`) match.
- `Arrays$ArrayList` and arrays throw `ArrayIndexOutOfBoundsException` (a subclass of `IndexOutOfBoundsException`, which
  can be caught by name); `elementAt` of a non-list says "Collection doesn't contain element at index i.".
- `removeFirst()`/`removeLast()` of an empty list throw `NoSuchElementException` without a message, like the JDK 21 methods
  Kotlin 2.4 calls.
- Sorting with comparators and `compareTo` is a port of the JDK's TimSort: comparators, `compareTo`, and the selectors of
  `sortedBy`/`sortedByDescending`/`sortBy`/`compareBy` (now called per comparison, as on the JVM) run in the same order and as
  often as on the JVM, and broken comparators get "Comparison method violates its general contract!". Selectors that only
  read fields keep computing each key once. `maxWith`/`minWith`/`maxBy`/`max` compare in the JVM's argument order, and
  `compareBy` treats identical values as equal without calling `compareTo`, like `compareValues`.
- `Double` natural order (`sorted()`, `compareTo`, `compareValues`) puts `-0.0` before `0.0` and `NaN` last.
- `TreeSet`/`TreeMap` with a comparator treat elements it calls equal as the same, as the JDK does.
- `ArrayList.addAll`/`remove`, `HashMap.putAll` and the copy constructors no longer call methods a subclass overrides.

### Fixed
- References to library properties compiled but failed at run time ("attempt to index a function value").
- `::Constructor.name` is `<init>`.
- `String.lastIndexOf("")` starts at the last index like Kotlin, `trimMargin` rejects a blank margin prefix, and string members
  called on a platform-typed `String!` (the elements of a Java stream) are mapped.
- `for (c in 'a'..'z' step 2)` (the step was converted like a `Char`); a non-constant `step` that is not positive throws
  `IllegalArgumentException` instead of looping forever on Lua 5.1; `x in a..f()` always evaluates `f()`, and before `x`.
- Interface delegation compiled to a class without the delegated members; delegating a library interface is now
  reported. `x in a..b` on `ULong`s above 2^63 compares unsigned on Lua 5.3/5.4.
- `toString()` of a class without its own prints `app.P@1f` like `Any.toString()` instead of Lua's `table: 0x...`; Lua class
  names are JVM binary names (`app.Outer$Inner`), so exceptions of the program print `app.MyError: message` like the JVM;
  `nullableString + x` prints `null` for a null left side.
- `break` and `continue` in a lambda expanded into a loop (`forEach`, `map`, `filter`, ...) left the expansion's loop
  instead of the loop around the call; on Lua 5.1 they, and a `return@outer` out of nested `run { }`s or out of a loop in
  one, were compile errors or broke the wrong loop.
- A lambda parameter of an expanded `inline fun` passed on to a function was an undefined Lua variable.
- `Result.map { }` expanded in place (because of a `return`) with a lambda returning Unit kept the old value.
- A `return` out of a lambda that crosses a closure to an enclosing `run { }` (`return@run`) generated an invalid `goto`.
- `+`, `-`, `+=` and `-=` on collections and maps chose between the element and the collection overload by the
  argument's type, so `rows += listOf(1, 2)` on a `MutableList<List<Int>>` added two elements; they now follow the overload
  Kotlin resolved (also `Set`, `MutableCollection`, `map += pair` / `map += pairs` / `map += sequence`).
- `list += x` (and other `plusAssign`/`minusAssign` calls) on a parameter was rejected as an unsupported assignment.
- `range.first { }` / `last { }` with a predicate called the range's `first`/`last` field; `range.first()` of an empty
  range now throws like the JVM.
- A `zip`, `zipWithNext`, `windowed`, `chunked`, `groupBy`/`associateBy` transform returning `false`, or a Boolean key of
  `maxBy`/`minBy`, was replaced by the default (a `Pair`, the window, the element).
- Missing APIs: `maxOfWith`, `minOfWith` (`OrNull`) on collections, arrays, maps, strings and sequences, and the rest of the
  `Sequence` API next to `Iterable` (`mapTo`, `filterTo` and the other `...To` forms, `flatMapIndexed`, `firstNotNullOf`,
  `indexOfLast`, `lastIndexOf`, `elementAtOrElse`, `reduceOrNull`, `reduceIndexed`(`OrNull`), `runningFoldIndexed`/`scanIndexed`,
  `runningReduceIndexed`, `sumBy`, `sumByDouble`, `maxWith`/`minWith`, `groupingBy`, `joinTo`, `shuffled`, `requireNoNulls`,
  `orEmpty`, `toSortedSet`, a `HashSet` from `toHashSet`), plus `filterIsInstanceTo`, `filterNotNullTo`,
  `mapIndexedNotNullTo`, `flatMapIndexedTo`, `reduceIndexedOrNull`, `runningFoldIndexed` and `joinTo` on collections.

## Work before the first release

Merged pull requests, oldest first (there has been no tagged release yet).

### PR #7: Semantics, numbers and Unicode
- UTF-16 strings (`--strings utf16`) so `String` and `Char` behave like the JVM's.
- `Float32`, unsigned integer types and big numbers; checked casts.
- Lazy objects (`object` initialization on first use) and more language features.

### PR #6: Correctness, reflection and tooling
- `--int-overflow wrap` to make `Int` arithmetic wrap to 32 bits; array/list bounds checks.
- Reflection support, jumps out of `try` blocks.
- Source maps (`--source-map`) with Kotlin positions in Lua errors and tracebacks.
- Watch mode (`--watch`).
- The `dev.k2l` Gradle plugin with `compileKotlinToLua` and TestKit functional tests.
- Fixes for compiler hangs on CI (package clash with `lua-api`, exit on crashes, AWT work queued before disposing
  the Analysis API session).

### PR #5: Coroutines, stdlib and language gaps
- Coroutines, lazy sequences, wider standard library coverage and more language features.

### PR #4: Everyday Kotlin
- Inner classes, enum entry bodies, extension and delegated properties, open accessors.

### PR #3: Static analysis
- ktlint (via Spotless) and detekt, with all findings fixed.

### PR #2 and #1: Clean Code refactors
- The transformer was split by language area.

### Before the pull requests (milestones 1 to 8)
- Analysis API based frontend; core expressions, control flow and functions.
- Classes, interfaces, objects, enums and data classes; null safety, lambdas, extensions, default arguments,
  overloads and exceptions.
- Collections, ranges and strings with a shared `lualib_bundle.lua`; multi-file programs linked with `require`.
- Lua interop (`@LuaExternal` declarations, `LuaTable`, multiple returns).
- Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT targets, with a CI matrix.
- CLI distribution, `k2l.json` projects and the README.
