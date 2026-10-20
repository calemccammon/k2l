# Changelog

All notable changes to k2l. The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/). The version lives in `gradle.properties`.

## [Unreleased]

## [0.2.0] - YYYY-MM-DD

The first tagged release. It covers pull requests #8 to #14; earlier work, built as the untagged version 0.1.0, is
listed under [Work before the first release](#work-before-the-first-release).

### Highlights

- **About twice as fast generated code.** Geometric mean over the 17 benchmark programs, relative to the baseline measured
  before the optimization work (`compiler/src/bench/baseline.json`; lower is faster): **0.45** on Lua 5.1, **0.55** on 5.2,
  **0.54** on 5.3, **0.53** on 5.4 and **0.49** on LuaJIT. See [Performance](README.md#performance).
- **Much faster compilation.** Compile time is now linear in the number of files: 200 files (about 70k lines) take 52 s
  instead of 19 min 41 s, and `examples/hello` takes 1.1 s instead of 2.0 s, helped by an AppCDS archive of the
  compiler's classes.
- **Behavior checked against the JVM.** 51 realistic programs (an interpreter, a JSON parser, a Markdown converter, a
  dependency-injection container, a small ORM, Rosetta Code and Advent of Code ports, ...) join the test suite. Like every
  test case, each runs on every Lua target and must print what Kotlin/JVM prints. Fixing what they found gave the JVM's
  collection classes and messages, the JDK's TimSort call order for comparators, `ConcurrentModificationException`,
  `java.util.Formatter`'s exceptions and reflection output that matches a JVM program without kotlin-reflect.
- **Live collection views.** A map's `keys`, `values` and `entries` (and the entries themselves), `subList`, `asList`, and
  `TreeMap`/`TreeSet` range and descending views see later changes and write through, as on the JVM.
- **Library types as base classes and delegates.** Classes can extend the abstract collections, `ArrayList`, `HashMap`,
  `TreeMap`, `PriorityQueue`, `LinkedList` and more, with the library calling their overrides where the JDK does. They can
  also implement or delegate (`by`) the collection interfaces, `Comparator`, `CharSequence`, `Sequence` and function types.
- **Exact 64-bit `Long` and `ULong` on every target** with `--long64 emulate` (Lua 5.1, 5.2 and LuaJIT).
- **More of the language and library:** interface delegation, object expressions, non-local `return`/`break`/`continue`
  out of any inline lambda, `Unit` as a value, `java.util.stream`, locale-aware formatting and display names.
- **A benchmark harness** (`./gradlew :compiler:bench`) with a sampling profiler that maps samples back to Kotlin lines.
- **Release packaging:** one version for every artifact, a CLI zip with the README, and publishing configuration for
  Maven Central and the Gradle Plugin Portal.

### Added

#### Tooling and packaging

- The Kotlin/JVM oracle (`./gradlew :compiler:kotlinOracle`) compiles every case in one JVM, with cases spread over a
  thread pool (`-PoracleThreads=N`); it went from about 12.5 minutes to about 30 seconds. CI runs it as its own `oracle` job
  next to `test`.
- `--long64 emulate` (`"long64": "emulate"` in k2l.json, `long64.set("emulate")` in Gradle): exact two's complement 64-bit
  `Long` and `ULong` on Lua 5.1, 5.2 (table boxes) and LuaJIT (`int64_t` cdata). Values stay plain numbers while
  |v| < 2^53. The emulation was fuzzed against native Lua 5.4 integers and the JVM. The test cases no longer skip targets
  for `Long` precision.
- A benchmark harness for the generated code. `./gradlew :compiler:bench` runs 17 programs (`compiler/src/bench/programs`,
  checked against Kotlin/JVM) on every Lua it finds and compares them with a committed baseline. `-PbenchProfile` reports
  the hottest functions of each program with a sampling profiler (a count hook on PUC Lua, `jit.profile` on LuaJIT),
  mapped back to Kotlin lines and lualib files. `compiler/src/bench/PROFILE.md` ranks the optimization opportunities found.
  The older scripts in `benchmarks/` time the compiler and some runtime microbenchmarks. `K2L_PROFILE=1` prints the
  time of each compiler phase.
- Release engineering:
  - the version is defined once (`gradle.properties`), and `k2l --version` reports it;
  - the CLI distribution (`./gradlew :compiler:distZip`) includes the README, and will include a LICENSE once the
    repository has one;
  - a GitHub Release workflow runs on `v*` tags (check, zip/tar, smoke test, `SHA256SUMS`);
  - Maven Central (Central Portal) and Gradle Plugin Portal publishing is configured for `dev.k2l:compiler`,
    `dev.k2l:lua-api` and the `dev.k2l` plugin, with credentials taken only from the environment;
  - `RELEASING.md`.
- The compiler publishes `compiler-<version>-runtime-libs.zip`, a self-contained archive of its runtime classpath. The
  Gradle plugin resolves it, so the plugin works from Maven Central without the JetBrains-only Analysis API repositories.
- The start script keeps an AppCDS archive of the loaded classes (`K2L_CDS_DIR` moves it, `K2L_NO_CDS=1` turns it off).
- 51 realistic programs as test cases, checked against the JVM on every Lua target:
  - `realworld_*`: an interpreter, builder DSLs, a state machine, a bank, generic containers, a text adventure, a
    generator-based scheduler, a multi-package lending library, a spreadsheet, a warehouse, grid puzzles with BFS and
    Dijkstra, a register machine, dynamic programming, CSV reports, sequences, big numbers, an inventory, graph
    algorithms, text tools, a simulation, linear algebra, a library catalogue, a dependency resolver, timesheets,
    compression and bit puzzles;
  - `realworld_app_*`: a dependency-injection container with an event bus, generic repositories with variance and query
    specs, a plugin host, a rules engine DSL, a middleware pipeline, an undo/redo editor, a parser-combinator library, an
    entity-component system, a units library on value classes, a tiny ORM with delegated columns, a payroll over a class
    hierarchy and a toolkit of inline helpers;
  - `realworld_text_*` and `realworld_port_*`: a JSON parser and pretty printer, a text formatter with tables and
    `String.format` reports, a Pratt parser with positioned errors, a Markdown-to-HTML converter, string algorithms (KMP,
    Rabin-Karp, suffix arrays, Manacher, Levenshtein), a regex log analyzer, a templating engine, a TOML-like config
    parser, a CSV dialect sniffer, Unicode text processing, number formatting and parsing, Rosetta Code tasks and Advent
    of Code text puzzles.

#### Language

- Interface delegation: `class C(impl: I) : I by impl`, with several and generic interfaces, on objects and companions,
  and with default methods and properties forwarded. Library interfaces can be delegated too: `: Comparator<T> by cmp`,
  `: MutableList<T> by inner`, `Set`, `Map`, `MutableMap`, `Collection`, `Iterable`, `Iterator`, `ListIterator`,
  `Map.Entry`, `Comparable`, `CharSequence`, `Sequence`, `Runnable`, `Callable` and function types (`: (Int) -> Int by f`),
  also on objects and object expressions. The members Kotlin delegates are forwarded, and the class's overrides win. The
  library's functions, `for` loops, `toString`/`equals` (Any's, as on the JVM) and Java's default methods (`removeIf`,
  `sort`, `getOrDefault`, ...) work on instances through them.
- Object expressions (`object : I { }`, with a base class, anonymous types, captured locals and `this`, JVM class names).
- Companion objects that implement interfaces or extend classes (`Foo.Companion`, usable as a value of those types). A
  companion with a member named like a member of the class's instances (`fun ok()` next to `val ok`, `toString`, `copy`)
  gets a table of its own instead of being an error.
- Non-local `return`, `break` and `continue` (labeled too) out of a lambda passed to any inline library function, also
  one that k2l does not expand into a loop (`trim { }`, `mapCatching`, `recoverCatching`, `List(n) { }`, `Array(n) { }`,
  `zipWithNext { }`, the terminal functions of a `Sequence`, ...). The lambda raises a token that the call, run in a
  `pcall`, turns into the jump. `catch` blocks and `runCatching` never see it, while `finally` blocks and `use` still run.
  Also non-local `return` from the `...To` collectors, `getOrPut`/`getOrElse`/`ifEmpty`, String lambdas, `Result`
  functions, `use`, `synchronized`, `runCatching` and `measureTimeMillis`.
- `Unit` is a value: `println(u())`, `"${u()}"`, `listOf(Unit)`, `val a: Any = Unit`, `runCatching { u() }`,
  `runCatching(::u)` and `map { u() }` print `kotlin.Unit` like the JVM, and `is Unit` works (the runtime object
  `__K2L_Unit`). Calls of Unit functions as statements generate the same code as before.
- Multi-index operators (`m[i, j]`, `m[i, j] += v`, `m[i, j]++`, also as extension operators).
- `x in a..b step s` (and `downTo`/`until`, `!in`, `when` branches) matches only the progression's elements, also for
  `UInt`/`ULong` ranges. `when (x) { in collection -> }` and `in "aeiou" ->` call `contains`.
- `vararg` parameters that are not the last one (`fun row(vararg cells: String, width: Int = 5)`), in functions, methods,
  constructors and inline functions. Spreads that are not the last argument (`listOf(*xs, y)`, `f(*a, *b)`), also of an
  `inline fun` expanded at the call site (`countOf<Int>(*xs, 2)`).
- Labels on expressions other than loops.
- `lateinit` properties throw `UninitializedPropertyAccessException` when read before their first assignment, and
  `this::x.isInitialized` works.
- A lambda parameter of an expanded `inline fun` can be passed on to a library function (`s.trim(predicate)`).
- Unchecked casts are checked where the JVM's CHECKCAST would throw: results of functions and getters of the program that
  cast to a type parameter, and reads through a local `val` cast to a generic type, when they meet a concrete type. The
  `ClassCastException` has the JVM's message (`java.lang.Number` for numbers).
- Recursion through `try` blocks on Lua 5.2 to 5.4 goes some 20000 levels deep instead of failing with "C stack overflow"
  after about 190: every hundredth nested protected call runs in a coroutine resumed by a driver around `main`
  (`DeepPcall.lua`). An overflow of the Lua or the C stack is caught as `StackOverflowError` (an `Error`) rather than
  `RuntimeException`. Lua 5.1 keeps its limit of about 190 levels; the README's "Other semantic differences" explains why.

#### Classes built on library types

- Classes can extend `AbstractList`, `AbstractMutableList`, `AbstractCollection`, `AbstractMutableCollection`,
  `AbstractSet`, `AbstractMutableSet`, `AbstractMap`, `AbstractMutableMap`, `AbstractIterator`, `ArrayList`, `HashMap`,
  `LinkedHashMap`, `HashSet`, `LinkedHashSet`, `TreeMap`, `TreeSet`, `PriorityQueue`, `java.util.ArrayDeque` and
  `LinkedList`, with `super` calls (`super.add(x)` calls the library member). Every inherited operation (`contains`,
  `toString`, `equals`/`hashCode`, iteration, `for` loops, the extension functions) works on instances. It is built on the
  members the class overrides, and the library calls the overridable ones exactly where the JDK and the stdlib do
  (`PriorityQueue.add` calls `offer`, `ArrayDeque.add` calls `addLast`, `TreeMap.putAll` calls `put`, `toString` and `for`
  call an overridden `iterator()`, `map` calls `size`, ...; see `CollectionOverrides.lua`). Classes without such
  overrides keep the direct paths.
- Classes can implement `List`, `Set`, `Map`, `Collection`, `Iterable`, `Iterator`, `MutableIterator`, `ListIterator`,
  `Map.Entry`, `CharSequence`, `Comparator`, `Runnable`, `Callable`, `ClosedRange<T>` and function types. Their objects of
  callable interfaces are callable, so they work wherever a lambda does. A collection interface can be implemented (or
  delegated) next to a base class that is not a collection. `contains`/`isEmpty` of a `ClosedRange` class come from the
  interface, and `start`/`endInclusive` read through a `ClosedRange` value reach the class's properties.
- `Runnable { }` and `Callable { }` SAM constructors, `fun interface` SAM constructors and conversions of lambdas passed
  for them, `is Comparator`, and `coerceAtLeast`/`coerceAtMost` of `Comparable` values.
- `LinkedHashMap(capacity, loadFactor, accessOrder = true)` keeps the access order, and `removeEldestEntry` is honored, so
  an LRU cache works.

#### Collections

- `ConcurrentModificationException` as on the JVM. `ArrayList`, `LinkedList`, `kotlin.collections.ArrayDeque`, `HashMap`,
  `LinkedHashMap`, `HashSet`, `TreeMap`, `TreeSet` and `PriorityQueue` count structural changes (`____modCount`), and
  `for` loops, `forEach`, iterators and `subList` views check the count where the JDK's iterators do. The JDK's quirks are
  kept: removing the second-to-last element during a loop ends it quietly, and `Map.forEach { k, v -> }` throws after the
  whole map. `java.util.ArrayDeque` checks no count, as in the JDK: its iterators throw only on reaching an emptied slot of
  its circular array. Loop bodies that cannot change a collection, and loops over arrays or a fresh `listOf(...)`, are not
  checked.
- `kotlin.collections.ArrayDeque`, `java.util.ArrayDeque` and `java.util.LinkedList` are classes of their own, with the
  JVM's class names, messages ("ArrayDeque is empty.", "Index: 0, Size: 0"), `element()`, `getFirst()`/`getLast()` and
  `descendingIterator()`. `java.util.ArrayDeque` also has identity `equals` and throws `NullPointerException` for null
  elements.
- `TreeMap.navigableKeySet()`, `descendingKeySet()` (navigable: `floor`, `ceiling`, `pollFirst`, `descendingSet`, ...) and
  `descendingMap()`; `IntRange.EMPTY`, `LongRange.EMPTY` and `CharRange.EMPTY`.
- Collection, array and view classes as on the JVM. This covers map views (`LinkedHashMap$LinkedKeySet`,
  `HashMap$Values`, `TreeMap$EntrySet` and their entries), iterators (`ArrayList$Itr`, `Arrays$ArrayItr`,
  `HashMap$KeyIterator`, ...) and `subList` views (`ArrayList$SubList`, `AbstractList$RandomAccessSubList`). Arrays know
  their JVM class at run time: an `IntArray` held in an `Any` is `[I`, `Array<String>` is `[Ljava.lang.String;`,
  `is IntArray`/`is Array<*>` tell arrays apart, and `toString()` is `[I@hash`. `is Queue`, `is Deque`, `is TreeSet`,
  `is TreeMap`, `is PriorityQueue`, `is java.util.ArrayDeque` and `is LinkedList` test the class itself.
- `is Number`, `is Comparable<*>` and `is CharSequence` (also in `filterIsInstance` and `as`), and `Number.toInt()`,
  `toLong()`, `toDouble()`, `toFloat()`, `toShort()` and `toByte()` on a value typed `Number`.
- `sortedArrayWith`, `contentHashCode()`, `contentDeepHashCode()` and `contentDeepEquals()` of arrays.

#### Standard library

- `java.util.stream`: `Stream`, `IntStream`, `LongStream` and `DoubleStream`, lazy like the JDK's. Sources include
  `Arrays.stream`, `collection.stream()`, `parallelStream()` (sequential; `isParallel()` is true), `IntStream.range` and
  `LongStream.range`/`rangeClosed`/`of`/`iterate`. The common stages and terminal operations are there, plus
  `flatMapToInt`/`Long`/`Double` and a lazy `Stream.iterator()`. Also `Optional`, `OptionalInt`, `OptionalLong`,
  `OptionalDouble`, the common `Collectors` (with `summingLong`, `averagingLong` and the `summarizing...` collectors) and
  `IntSummaryStatistics`/`LongSummaryStatistics`/`DoubleSummaryStatistics`, printed like the JDK's. `LongStream` is exact
  with `--long64 emulate`. `String.chars()`/`codePoints()` return the same `IntStream`.
- `String.format`: `%<s` (the previous specifier's argument), `%h`/`%H`, `%c` of any code point, precision on `%b`/`%h`,
  and `java.util.Formatter`'s exceptions with the JDK's messages. These are `MissingFormatArgumentException`,
  `UnknownFormatConversionException`, `IllegalFormatConversionException`, `IllegalFormatPrecisionException`,
  `MissingFormatWidthException`, `FormatFlagsConversionMismatchException` and the other `IllegalFormatException`s, and
  they can be caught by name.
- Locales:
  - English display names (`displayLanguage`, `displayCountry`, `displayName`, `getDisplayLanguage(Locale)`, ...),
    generated from the JDK by `compiler/tools/GenLocale.java`;
  - `String.format(locale, ...)` with the decimal separator, grouping separator, group size and digits of every locale
    the JDK has (`%S` follows the locale's case rules with `--strings utf16`);
  - the case rules of Turkish, Azeri and Lithuanian with `--strings utf16`;
  - more `Locale` constants (`KOREA`, `CHINESE`, `TAIWAN`, ...).
- Regex:
  - `Regex.matchAt(input, index)` and `matchesAt`, and class intersection (`[a-z&&[^aeiou]]`, `[\w&&\D]`);
  - with `--strings utf16`, the Unicode properties `\p{L}`, `\p{Lu}`, `\p{Ll}`, `\p{Lt}`, `\p{N}`/`\p{Nd}`, `\p{M}`,
    `\p{Z}`/`\p{Zs}`, `\p{IsWhite_Space}`, `\p{javaWhitespace}`, `\p{javaLetterOrDigit}` and their `Is`/`java` aliases
    (the POSIX classes such as `\p{Alpha}` stay ASCII, as in Java), Unicode `IGNORE_CASE` and non-ASCII class ranges;
  - `\p{S}`/`\p{IsS}`, Unicode's symbol category;
  - patterns accept `\x{1F600}` and `😀`.
- `--strings utf16` behaves like the JVM in more places:
  - `trimIndent`/`trimMargin`/`prependIndent` measure indents by `Char.isWhitespace`;
  - `toInt()`, `toLong()`, the unsigned conversions and `Integer.parseInt` accept Unicode digits, and fullwidth letters
    above radix 10, as `digitToInt` does;
  - empty regex matches stop between the halves of a surrogate pair, like `java.util.regex`;
  - `contains`, `replace`, `split`, `startsWith`, `removePrefix`, `substringBefore`, ... find one half of a pair inside a
    pair.
- Numbers: `String.toUInt()`, `toULong()`, `toUByte()` and `toUShort()` with their `OrNull` and `radix` variants (Kotlin's
  rules and `NumberFormatException` message), and `ULong.toString(radix)`. `rotateLeft`/`rotateRight` of `Byte`, `Short`,
  `UByte` and `UShort`. `BigDecimal.sqrt(MathContext)` as the JDK computes it (precision, rounding modes, preferred scale,
  exceptions). Hexadecimal floats in `toDouble()` (`"0x1.8p3"`) and `Boolean.xor`/`not()`.
- The `java.lang` statics that ported code uses:
  - `Integer`/`Long` `bitCount`, `numberOfLeadingZeros`/`TrailingZeros`, `highestOneBit`/`lowestOneBit`,
    `rotateLeft`/`Right`, `signum` and `max`/`min`;
  - `Integer.reverse`, `Integer.toUnsignedString`, `Integer.valueOf(String)` and `Long.valueOf(String)`;
  - `Long.toBinaryString`/`toHexString`/`toOctalString`;
  - `Double.isNaN`/`isInfinite`/`isFinite`/`valueOf`/`toString`;
  - `Boolean.parseBoolean`, `Character.getNumericValue`, `String.valueOf` and `String.join`.
- Text:
  - `for (c in s)` over a `CharSequence` (a parameter, a property, a `StringBuilder` typed as one) or a `StringBuilder`,
    in bytes mode and with `--strings utf16`. It reads the chars of a string, or the value's `get(i)` while
    `i < length`, like the JVM's iterator;
  - `length`, `s[i]`, `lastIndex` and `indices` of a `CharSequence` call the members of a `StringBuilder` or a class of
    the program;
  - `Char.equals(other, ignoreCase)` without `--strings utf16`;
  - `codePointAt`/`codePointBefore`/`codePointCount`/`offsetByCodePoints` of a `StringBuilder`.
- `Sequence.asIterable()`, and classes extending `Sequence` next to a base class.

#### Reflection

- References to library properties (`String::length`, `"abc"::length`, `List<*>::size`, `Pair<*, *>::first`,
  `Map.Entry<*, *>::key`, `String::lastIndex`, `CharSequence::indices`, `Int.Companion::MAX_VALUE`, ...) are property
  references with `name`, `get` and `invoke`; `map(String::length)` still passes a plain function. Also references to
  extension properties and to delegated properties (`Holder::x`, `::delegated`).
- References to library constructors (`::ArrayList`, `::Pair`, `::StringBuilder`, `::IllegalStateException`, `::Regex`,
  ...). `.name` of function references held in variables.
- References print and compare like the JVM's without kotlin-reflect (`function twice (Kotlin reflection is not
  available)`, `==` and `hashCode()` between references to the same callable and receiver), also references to library
  functions. The members that need kotlin-reflect (`KFunction.parameters`, `returnType`, `isSuspend`, `call`,
  `visibility`, `KProperty.getter`, `isConst`, `isLateinit`, `annotations`, ...) throw
  `KotlinReflectionNotSupportedError`, as on the JVM.
- The `KProperty` passed to delegates is a property reference: it prints like the JVM's and is `==` to `Holder::x`.
- `KClass` prints like the JVM's without kotlin-reflect (`class app.Dog (Kotlin reflection is not available)`), and
  `javaClass` and `KClass.java` are a `Class` object of their own that prints like `java.lang.Class`. A companion
  object's value has the companion's class (`Outer.Companion`, `simpleName` `Companion`).

### Changed

- **Performance of the generated code and the runtime**, in two rounds. Benchmark geomean relative to the baseline, lower
  is faster:

  | | 5.1 | 5.2 | 5.3 | 5.4 | LuaJIT |
  |---|---:|---:|---:|---:|---:|
  | after round 1 (PR #12) | 0.51 | 0.63 | 0.62 | 0.60 | 0.56 |
  | after round 2 (PR #14, this release) | 0.45 | 0.55 | 0.54 | 0.53 | 0.49 |

  (The round 1 figures were later restated as 0.51/0.64/0.62/0.61/0.53 when round 2 was measured.)
  - Generated code:
    - `is`/`when` on final classes compare metatables;
    - `map`/`filter`/`sumOf`/`any`/... with a lambda literal on lists, arrays and sets compile to loops, and so does
      `List(n) { }`;
    - `for (x in list)` is a numeric loop (faster than `ipairs` on PUC Lua), and loops over a map's keys, values or
      entries read the map's arrays without copying;
    - `entries[i]` and loops over `entries` read the enum's values without copying;
    - primitive arrays, `Array<T>` of non-null elements and string `s[i]` are indexed directly, with an inline bounds
      check;
    - `%` and `/` by positive literals, constant shifts and masks use operators;
    - plain constructors build the instance with one table constructor;
    - non-capturing single-expression lambdas are hoisted;
    - `compareBy {}.thenBy {}` chains with lambda selectors compile to one comparator function;
    - in bytes mode, `isDigit`/`isLetter`/`isWhitespace`/... of a `Char` look the char up in tables, `for (c in s)`
      reads bytes when the body only uses `c.code` or compares with ASCII literals, and `s[i] == 'x'` compares bytes;
    - data-class `hashCode` calls a data-class field's own `hashCode`;
    - `Int` wrapping uses `bit.tobit` on LuaJIT.
  - Runtime:
    - table-driven bitwise operations on Lua 5.1 (up to 8 times faster) and faster 5.1/5.2 bit operations;
    - faster emulated `Long`;
    - SWAR bit counts;
    - BigInteger with base 10^9 limbs on Lua 5.3/5.4, and single-limb fast paths;
    - comparator and hash map fast paths, counting-sort `HashMap` normalization, and string hashing four bytes at a
      time without a pattern search;
    - `Map`/`Set` removal no longer rehashes everything;
    - keyed sorts compute each key once;
    - delegated properties pass a per-class constant property table;
    - cached `String.format` specs and conversion details, and a shorter search for the digits of a double;
    - a regex engine without per-step tables or closures;
    - incremental UTF-16 `StringBuilder` length, and ASCII fast paths for UTF-16 `first`/`last`;
    - leaner `Sequence` operations;
    - `joinToString` with one `table.concat`.
- **Compile time** is linear in the number of files. The class lookup and the property-family scan used to walk the whole
  module again for every file; both now run once per module.
- **Collection views are live** (they were copies):
  - A map's `keys`, `values` and `entries` see later changes and track the map's size. `remove`, `removeIf`,
    `retainAll`, `clear`, their iterators' `remove()` and `setValue` write through. `values` is a `Collection`, not a
    `List`, and the views cannot be added to (`UnsupportedOperationException`).
  - Map entries are live, like the JVM's nodes. An entry from `map.entries` (a loop, `entries.first()`, `toList()`, an
    iterator, `removeEldestEntry`'s argument) sees a later `put`, `merge`, `compute` or `replaceAll` of its key in a
    `HashMap`, `LinkedHashMap` (also in access order), `TreeMap` or `buildMap`. Two reads give the same entry. A removed
    key's entry keeps its last value, and its `setValue` no longer writes to the map. `TreeMap.firstEntry()`,
    `floorEntry()`, `pollFirstEntry()` and the like return `AbstractMap$SimpleImmutableEntry` copies, whose `setValue`
    throws `UnsupportedOperationException`.
  - `subList` writes, additions and removals go through to the list (`list.subList(a, b).clear()` removes a range).
    `Array.asList()` is a fixed-size view of the array that writes through both ways, and a primitive array's `asList()`
    is a read-only view.
  - `TreeMap.headMap`, `tailMap`, `subMap` (also with inclusive flags), `TreeSet.headSet`, `tailSet`, `subSet` and
    `descendingSet()` are `TreeMap$AscendingSubMap`, `TreeMap$DescendingSubMap` and `TreeSet` views that hold their range.
    They see later changes, write through and count their `size` live. A write outside the range throws
    `IllegalArgumentException("key out of range")`, views of views narrow the range (`fromKey out of range`,
    `toKey out of range`, `fromKey > toKey`), and loops throw `ConcurrentModificationException` after a change of the map
    or set. `descendingMap().descendingMap()` is an `AscendingSubMap`, the views' `keys`, `values`, `entries` and
    iterators have the JVM's classes, `navigableKeySet().headSet()` and the like work, and
    `TreeSet.descendingIterator()` is the descending set's iterator.
  - `Collections.unmodifiableList/Set/Map/Collection` are live read-only views. `unmodifiableMap(m).keys` (and
    `values`, `entries`) are unmodifiable views, and `unmodifiableCollection` of a collection that is not a list is a
    `Collections$UnmodifiableCollection`.
- **Collections have the JVM's classes.** `listOf()`/`emptyList()` are Kotlin's `EmptyList`, `listOf(x)` a
  `Collections$SingletonList`, and `listOf(a, b, ...)`, `asList()` and the `sorted*()` results an `Arrays$ArrayList`. The
  `setOf`/`mapOf`/`emptySet`/`emptyMap` variants and `java.util.Collections`' own collections follow the same rule.
  `toList()`, `toSet()`, `toMap()`, `take`, `drop`, `distinct`, ... return them for zero and one element, as Kotlin
  does. `::class`, `javaClass.name`, `simpleName`, index messages ("Index: 1, Size: 1", "Empty list doesn't contain
  element at index 0.") and the read-only behavior (`UnsupportedOperationException`) match. `buildList { }`,
  `buildSet { }` and `buildMap { }` return the stdlib's `ListBuilder`, `SetBuilder` and `MapBuilder`, read-only after the
  block (they were an `ArrayList`, `LinkedHashSet` and `LinkedHashMap`).
- `Arrays$ArrayList` and arrays throw `ArrayIndexOutOfBoundsException`, a subclass of `IndexOutOfBoundsException` that can
  be caught by name. `elementAt` of a non-list says "Collection doesn't contain element at index i.". `first()`, `last()`
  and `single()` of an empty collection that is not a list say "Collection is empty.". `removeFirst()`/`removeLast()` of
  an empty list throw `NoSuchElementException` without a message, like the JDK 21 methods Kotlin 2.4 calls.
- Casting `emptyList()`, `emptySet()`, `emptyMap()`, a primitive array's `asList()`, or an object of a class implementing
  only read-only collection interfaces, to `MutableList` (`MutableSet`, ...) throws `ClassCastException` with the JVM's
  message, and `is MutableList` is false for them, as on the JVM.
- `java.util.ArrayDeque` is not a `List`: `is List` is false, `as List` throws `ClassCastException`, and `==` a list is
  false. `for` loops and `forEach` over a value that may be one (a `Deque`, `Queue`, `Collection` or `Iterable`), when the
  body may change a collection, read it through `__K2L_LoopItems`, which uses its iterator.
  `java.util.ArrayDeque(numElements)` passes the capacity on, since it decides when the array grows.
- Library collections call the overridable methods only where the JDK does:
  - `ArrayList.addAll`/`remove`, `HashMap.putAll` and the copy constructors no longer call methods a subclass overrides;
  - `HashMap`'s and `LinkedHashMap`'s `putIfAbsent`, `merge` and `compute*` no longer call an overriding `get`/`put`;
  - `ArrayList.contains` calls `indexOf`;
  - `getOrPut` and `getValue` of a map read it with `get` (and `containsKey`);
  - `AbstractSet`'s `equals` and `removeAll` call `contains`/`remove`;
  - `PriorityQueue.removeIf`/`removeAll` heapify without calling `add`.
- A `for` loop over an object of a class implementing (or delegating) `List` uses its `iterator()`, as on the JVM.
- `size` of a `Collection` is its field (it was `count()`).
- Sorting with comparators and `compareTo` is a port of the JDK's TimSort. Comparators, `compareTo` and the selectors of
  `sortedBy`/`sortedByDescending`/`sortBy`/`compareBy` (now called per comparison, as on the JVM) run in the same order and
  as often as on the JVM, and broken comparators get "Comparison method violates its general contract!". Selectors that
  only read fields still compute each key once. `maxWith`/`minWith`/`maxBy`/`max` compare in the JVM's argument order, and
  `compareBy` treats identical values as equal without calling `compareTo`, like `compareValues`.
- `Double` natural order (`sorted()`, `compareTo`, `compareValues`) puts `-0.0` before `0.0` and `NaN` last.
- `TreeSet`/`TreeMap` with a comparator treat elements that it calls equal as the same, as the JDK does.
- `Long` bitwise operations (`and`, `or`, `xor`, `inv`, shifts, bit counts, `takeHighestOneBit`/`takeLowestOneBit`) are
  exact for values below 2^53 on Lua 5.1, 5.2 and LuaJIT without `--long64 emulate` (they were 32-bit), so
  `x.toLong() and 0xFFFFFFFFL` and masks over 32 bits work.
- `Regex.findAll` returns a lazy `Sequence`, as in Kotlin: matches are searched for as they are pulled.
- `is Comparable<*>` is exact for classes of the program. Objects (`object Version : Comparable<Version>`), implementations
  through superclasses and interfaces, and enums are Comparable (a class table records it in `____comparable`); a class
  with only an `operator fun compareTo` is not.
- `println(x)` and `print(x)` of a platform-typed primitive (`treeMap.higherKey(k)` is `Int!`) throw
  `NullPointerException` for null, as the JVM's unboxing for `println(Int)` does (`__K2L_NotNull(x)`).

### Fixed

#### Language

- Guard conditions in `when` (`is Int if x < 0 ->`, `else if ready ->`) were ignored: the branch was taken whenever its
  condition matched.
- `break` and `continue` in a lambda expanded into a loop (`forEach`, `map`, `filter`, ...) left the expansion's loop
  instead of the loop around the call. On Lua 5.1 they, and a `return@outer` out of nested `run { }`s or out of a loop
  in one, were compile errors or broke the wrong loop.
- A `return` out of a lambda that crosses a closure to an enclosing `run { }` (`return@run`) generated an invalid `goto`.
- `x.let { throw ... }` dropped the `throw`.
- Interface delegation compiled to a class without the delegated members. Delegating a library interface that k2l has no
  implementation for (`CoroutineContext`, `Executor`, ...) is now reported as an error.
- An override did not apply the default arguments it inherits from the function it overrides (`ceo.report()` with
  `fun report(indent: String = "")` declared in an interface passed `nil` on).
- A property read during construction before its initializer ran, through a method called by an earlier initializer or
  by a superclass constructor (`val x = compute()` before `val y = 5`), was nil in Lua ("attempt to perform arithmetic on
  a nil value"). It now reads the JVM's `0`/`false`/`null`.
- `is T`/`as T?` with a reified `T` ignored the `?` (`null.isA<String?>()` was false, `firstOrNull { } as T?` threw
  `NullPointerException` for null), and `is String?`/`when` branches `is Int?` did not hold for null.
- `null as T` of a reified `T` and `null as String` say `null cannot be cast to non-null type kotlin.String`, with the
  Kotlin name.
- `data object`s printed like plain objects (`app.Cmd$Look@1`) and failed on `hashCode()`/`toString()` calls. Value
  classes compared and hashed by identity (`Ref(Col(0), 1) != Ref(Col(0), 1)`, so map lookups missed) and printed as
  `Col@1`.
- `toString()` of a class without its own printed Lua's `table: 0x...`; it now prints `app.P@1f` like `Any.toString()`.
  Lua class names are JVM binary names (`app.Outer$Inner`), so exceptions of the program print `app.MyError: message`
  like the JVM. `nullableString + x` prints `null` for a null left side.
- `vararg` parameters of constructors received only their first element.
- A reference to a function with a `vararg` parameter used as a function taking the Array (`val f: (IntArray) -> Int =
  ::sum`) passed the Array as one element.
- Comparing enums (`<`, `compareTo`, `sorted()`, `max()`, `sortedBy { it.level }`, `TreeSet`) failed at run time: enum
  classes now have `compareTo` (the difference of the ordinals).
- `x in a..b` over Comparable objects (enums, classes of the program) compared the tables with Lua's `<` and failed.
- `entries`, `values()` and `valueOf` called from an enum's companion object were rejected ("This receiver").
- Name clashes:
  - a function sharing its name with a property of its class hierarchy (`private val items` and `fun items()`) was
    rejected; it now gets its own Lua name. Before, a subclass's property could also hide a superclass's method of the
    same name;
  - a private property named like a method of its class (`private var next` next to `fun next()` in an iterator) was
    rejected;
  - a local or parameter named like a top-level function (`val total = total(xs)`) hid the function in its scope;
  - a top-level function named like a top-level property (`val label`, `fun label(n)`) overwrote it; it is now
    `label__1`.
- Reassigning a variable declared with `var (a, b) = ...` was rejected.
- `list += x` (and other `plusAssign`/`minusAssign` calls) on a parameter was rejected as an unsupported assignment.
- `+`, `-`, `+=` and `-=` on collections and maps chose between the element and the collection overload by the
  argument's type, so `rows += listOf(1, 2)` on a `MutableList<List<Int>>` added two elements. They now follow the
  overload Kotlin resolved (also for `Set`, `MutableCollection`, `map += pair`, `map += pairs` and `map += sequence`).
- Members of arrays read from an `out`-projected container (`rows[0].size` with `vararg rows: DoubleArray`, an
  `Array<out IntArray>`) were rejected.
- Block-bodied getters with `return`.
- A lambda parameter of an expanded `inline fun` passed on to a function was an undefined Lua variable.
- `Result.map { }` expanded in place (because of a `return`) with a lambda returning Unit kept the old value.
- A single-expression lambda whose value caches an operand (`{ it * 37 % 41 }`) referred to an undefined local.
- A function reference or `() -> Unit` value converted to a function type with a result, other than as an argument
  (`val h: () -> Any = ::work`, `return ::work`, `listOf<() -> Any>(::work)`), returned `nil` instead of `kotlin.Unit`.
- A bound reference to a member of a companion (`Registry.register(Widget::create)`) did not initialize the companion
  when the reference was made, and an object qualifier cached before arguments that need statements was initialized
  after them.
- A top-level property whose initializer refers to the property itself in a lambda (`val json: Parser = lazyParser {
  ... json ... }`) read an undefined global.
- String templates:
  - a template ran an expanded inline call (or another entry needing statements) before the entries to its left
    (`"${counter} ${get<T>()}"` printed the counter after the call);
  - each entry is now turned into text where the JVM appends it, so a later entry with a safe call
    (`"$list ${list.removeLastOrNull()?.x}"`) no longer changes what an earlier object prints;
  - a null platform-typed value (`"${treeMap.higherKey(k)}"`, an `Int!` from a Java method) in a template or
    concatenation failed with "attempt to concatenate a nil value" instead of printing `null`.

#### Reflection

- References to library properties compiled but failed at run time ("attempt to index a function value").
- `::method` and `::property` without a receiver inside a class were compiled as unbound references (a crash when
  called).
- `::Constructor.name` is `<init>`.
- Two objects made by the same object expression (or local class) in different runs had different `KClass`es and
  `javaClass`es.

#### Collections and sequences

- `java.util.ArrayDeque`'s iterators, descending iterator, `for` loops and `forEach` never threw
  `ConcurrentModificationException`. They now throw exactly where the JDK's do (on reaching an emptied slot of the
  circular array, for example after `removeLast()` or an `addLast` that grows the array), and they read the right
  elements after `poll()` or `addFirst` while iterating. `kotlin.collections.ArrayDeque` no longer counts adding no
  elements, clearing an empty deque, sorting or `replaceAll` as a change, and its iterator's `next()` past the end has
  the JVM's message.
- `yieldAll` of another `sequence { }` or `iterator { }` (a recursive tree walk) ended in "C stack overflow" after some
  200 nested levels on PUC Lua. The generator now keeps a stack of the builders' coroutines and resumes the innermost
  directly instead of nesting resumes, which is also about 25% faster per element. As on the JVM, an exception that the
  inner block throws after its first element now reaches the consumer past the `try` blocks around the `yieldAll`; one
  thrown before its first element still comes out of the `yieldAll`.
- `super.iterator()` in a class extending a library collection recursed forever.
- A `TreeSet`'s `descendingSet()` was a `LinkedHashSet`.
- `nullMap.orEmpty()` crashed ("attempt to index a nil value"), `nullSet.orEmpty()` gave a list and `nullList.orEmpty()`
  an `ArrayList`. They are now `EmptyMap`, `EmptySet` and `EmptyList`, as on the JVM.
- Reading a still-null element of an `Array<T>` (`arrayOfNulls<T>(n) as Array<T>`) gives null instead of throwing.
- `toCharArray()`, `toFloatArray()`, `toByteArray()` and `toShortArray()` of a collection (`List<Char>.toCharArray()`,
  `Set<Float>`, `map.keys`, ...) were reported as unsupported.
- `range.first { }` / `last { }` with a predicate called the range's `first`/`last` field, and `range.first()` of an empty
  range now throws like the JVM.
- A `zip`, `zipWithNext`, `windowed`, `chunked` or `groupBy`/`associateBy` transform returning `false`, or a Boolean key
  of `maxBy`/`minBy`, was replaced by the default (a `Pair`, the window, the element).
- `Regex.findAll(...).forEach { }` and `for (m in regex.findAll(...))` failed at run time.
- Ranges: `for (c in 'a'..'z' step 2)` converted the step like a `Char`; a non-constant `step` that is not positive
  throws `IllegalArgumentException` instead of looping forever on Lua 5.1; `x in a..f()` always evaluates `f()`, and
  before `x`; `x in a..b` on `ULong`s above 2^63 compares unsigned on Lua 5.3/5.4.
- Missing APIs:
  - `maxOfWith` and `minOfWith` (`OrNull`) on collections, arrays, maps, strings and sequences;
  - the rest of the `Sequence` API next to `Iterable`: `mapTo`, `filterTo` and the other `...To` forms,
    `flatMapIndexed`, `firstNotNullOf`, `indexOfLast`, `lastIndexOf`, `elementAtOrElse`, `reduceOrNull`,
    `reduceIndexed`(`OrNull`), `runningFoldIndexed`/`scanIndexed`, `runningReduceIndexed`, `sumBy`, `sumByDouble`,
    `maxWith`/`minWith`, `groupingBy`, `joinTo`, `shuffled`, `requireNoNulls`, `orEmpty`, `toSortedSet`, and a `HashSet`
    from `toHashSet`;
  - on collections: `filterIsInstanceTo`, `filterNotNullTo`, `mapIndexedNotNullTo`, `flatMapIndexedTo`,
    `reduceIndexedOrNull`, `runningFoldIndexed` and `joinTo`.

#### Text and numbers

- `String.format`:
  - it throws `IllegalFormatConversionException` (`f != java.lang.Integer`, `d != java.lang.Double`, `c != java.lang.Long`,
    `c != java.lang.String`, `x != java.lang.Character`, `d != kotlin.UInt`, ...) by the class of an argument's static
    type, as `java.util.Formatter` does. Arguments held in an `Any` are checked by their value where it tells (booleans,
    objects, `BigInteger`/`BigDecimal`, fractional numbers). Only the arguments a literal format rejects are wrapped, so
    correct formats run as before;
  - `%f` of a `BigDecimal` is exact (it failed), and `%s` of a `Double` prints `2.0` on Lua 5.1, 5.2 and LuaJIT;
  - `%g` picks fixed or scientific notation after rounding (`999.9999` is `1000.00`), and `%#010x` puts the zeros after
    `0x`;
  - `%x`/`%o` of a negative `Byte`, `Short` or `Long` give the two's complement of the type's width (`ff`, `ffff`,
    sixteen `f`s; they were 32-bit);
  - `%0s` and the like are rejected, and an unknown conversion is reported before a missing argument;
  - `%e`/`%g` of subnormal doubles keep two significant digits like Java (`4.900e-324`);
  - `"%s %s".format(null, x)` and `"%s".format(null)` resolve to the `Locale` overload, as in Kotlin, so they throw
    `MissingFormatArgumentException` like the JVM instead of printing `null`.
- Regex `\p{P}` and `\p{IsPunctuation}` are Unicode's punctuation category, with non-ASCII characters under
  `--strings utf16`. They were POSIX `\p{Punct}`, which also holds the ASCII symbols `` $+<=>^`|~ ``.
- `CharSequence` and `StringBuilder`:
  - `length`, `s[i]` and the String functions of a `StringBuilder` held as a `CharSequence` read the table as a string;
  - a `StringBuilder` passed to a String function that takes a `CharSequence` (`"abc".contains(sb)`) failed;
  - `kotlin.text` functions of `CharSequence` called on a `StringBuilder` (`sb.removeSuffix(", ")`, `sb.lines()`,
    `sb.split(...)`, `sb.trim()`) were rejected; they work on its text;
  - an object of a class implementing `CharSequence` stays an object where a library parameter is not text
    (`listOf(letters)` made a list of its `toString()`), and the String functions read its chars through `length` and
    `get`, as the JVM does;
  - `StringBuilder` is `Comparable` (`is Comparable<*>`, natural order), as it is since Java 11.
- `String.lastIndexOf("")` starts at the last index, like Kotlin. `trimMargin` rejects a blank margin prefix. String
  members called on a platform-typed `String!` (the elements of a Java stream) are mapped.
- `println` of a string containing a NUL character stopped at it on Lua 5.1.
- The literal `-2147483648` compiled to `-(-2147483648)`, which is `2147483648`.
- Negative zero:
  - `"-0.0".toDouble()` and `"-0".toDouble()` gave `0.0`;
  - `(-0.5).toLong()`, `(-0.2).roundToInt()` and the like printed `-0` on Lua 5.1, 5.2 and LuaJIT;
  - `Int` division by a constant on Lua 5.1 printed `-0` for a zero quotient of a negative dividend;
  - `-0.0` literals were wrong on Lua 5.1.
- On Lua 5.1, 5.2 and LuaJIT:
  - a `Double?` or `Float?` printed like an `Int` (`2` for `2.0`); it now prints by its static type;
  - a range of Doubles printed integral bounds as integers (`30..50` for `30.0..50.0`);
  - a data class with a `Double` property holding an integral value (`3.0`) hashed it like an `Int`, so `HashMap` and
    `HashSet` of such keys iterated in another order than on the JVM.
- `RuntimeException(message, cause, false, false)` passed a Boolean as the cause.

## Work before the first release

Merged pull requests, oldest first. These were built as the untagged version 0.1.0.

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

[Unreleased]: https://github.com/calemccammon/k2l/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/calemccammon/k2l/releases/tag/v0.2.0
