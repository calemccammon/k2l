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
- Delegating library interfaces: `: Comparator<T> by cmp`, `: List<T> by list`, `: MutableList<T> by inner`, `Set`, `Map`,
  `MutableMap`, `Collection`, `Iterable`, `Iterator`, `ListIterator`, `Map.Entry`, `Comparable`, `CharSequence`, `Sequence`,
  `Runnable`, `Callable` and function types (`: (Int) -> Int by f`), also on objects and object expressions. The members Kotlin
  delegates are forwarded (the class's overrides win), and the library's functions, `for` loops, `toString`/`equals` (Any's,
  as on the JVM) and Java's default methods (`removeIf`, `sort`, `getOrDefault`, ...) work on instances through them.
- Classes can extend `TreeMap`, `TreeSet`, `PriorityQueue`, `java.util.ArrayDeque` and `LinkedList`, with `super` calls; the
  library's own methods call the overridable ones as the JDK does (`PriorityQueue.add` calls `offer` and `addAll` calls `add`,
  `ArrayDeque.add`/`offer`/`addAll` and its constructor call `addLast`, `LinkedList.addAll(c)` calls `addAll(index, c)`,
  `TreeMap.putAll` and `TreeMap(map)` call `put`, `TreeSet.addAll` and `TreeSet(c)` call `add`, TreeMap's `putIfAbsent`/`merge`/
  `compute*` do not). A collection interface can be implemented (or delegated) next to a base class that is not a collection.
- `kotlin.collections.ArrayDeque`, `java.util.ArrayDeque` and `java.util.LinkedList` are classes of their own, with the JVM's
  class names, messages ("ArrayDeque is empty.", "Index: 0, Size: 0"), `element()`, `getFirst()`/`getLast()`,
  `descendingIterator()` and, for `java.util.ArrayDeque`, identity `equals` and `NullPointerException` for null elements.
- `subList` is a live view (writes, additions and removals go through to the list, `list.subList(a, b).clear()` removes a
  range), and `Array.asList()` a fixed-size view of the array that writes through both ways; a primitive array's `asList()`
  is a read-only view.
- The JVM's classes for map views (`LinkedHashMap$LinkedKeySet`, `HashMap$Values`, `TreeMap$EntrySet`, their entries),
  iterators (`ArrayList$Itr`, `Arrays$ArrayItr`, `HashMap$KeyIterator`, ...), `subList` views (`ArrayList$SubList`,
  `AbstractList$RandomAccessSubList`) and, from the static type, arrays (`IntArray` is `[I`/`int[]`, `Array<String>`
  `[Ljava.lang.String;`/`String[]`). The keys, values and entries of a map cannot be added to, and values compare by identity.
- `LongStream` (`range`, `rangeClosed`, `of`, `iterate`, `sum`, `average`, `min`, `max`, `mapToLong`, `asLongStream`, `Arrays.stream`
  of a `LongArray`, `OptionalLong`; exact with `--long64 emulate`), `flatMapToInt`/`Long`/`Double`, `parallelStream()` (sequential),
  `isParallel()`, `Stream.iterator()` (lazy), `IntSummaryStatistics`/`LongSummaryStatistics`/`DoubleSummaryStatistics`
  (`summaryStatistics()`, `Collectors.summarizingInt`/`Long`/`Double`, `accept`, `combine`, printed like the JDK's) and
  `Collectors.summingLong`/`averagingLong`.
- `is Number`, `is Comparable<*>` and `is CharSequence` (also `filterIsInstance` and `as`), and `Number.toInt()`, `toLong()`,
  `toDouble()`, `toFloat()`, `toShort()`, `toByte()` on a value typed `Number`.
- `lateinit` properties throw `UninitializedPropertyAccessException` when read before their first assignment, and
  `this::x.isInitialized` works.
- A spread argument that is not the last one (`listOf(*xs, y)`, `f(*a, *b)`).
- Classes implementing `ClosedRange<T>` (`class DateRange(...) : ClosedRange<Date>, Iterable<Date>`): `contains`/`isEmpty` come
  from the interface (and win over the Iterable operations), and `start`/`endInclusive` read through a `ClosedRange` value reach
  the class's properties as well as the library ranges' bounds.
- The `java.lang` statics ported code uses: `Integer`/`Long` `bitCount`, `numberOfLeadingZeros`/`TrailingZeros`,
  `highestOneBit`/`lowestOneBit`, `rotateLeft`/`Right`, `signum`, `max`/`min`, `Integer.reverse`, `Integer.toUnsignedString`,
  `Long.toBinaryString`/`toHexString`/`toOctalString`, `Double.isNaN`/`isInfinite`/`isFinite`/`valueOf`/`toString`,
  `Boolean.parseBoolean`, `Character.getNumericValue`, `String.valueOf` and `String.join`.
- `contentHashCode()`, `contentDeepHashCode()` and `contentDeepEquals()` of arrays.
- Realistic programs as test cases, checked on every Lua target (`realworld_*`): an interpreter, builder DSLs, a state
  machine, a bank, generic containers, a text adventure, a generator-based scheduler, a multi-package lending library, a
  spreadsheet, a warehouse, grid puzzles with BFS/Dijkstra, a register machine, dynamic programming, CSV reports, sequences,
  big numbers, an inventory, graph algorithms, text tools, a simulation, linear algebra, a library catalogue, a dependency
  resolver, timesheets, compression and bit puzzles. Generic-heavy and multi-package applications (`realworld_app_*`): a
  dependency-injection container with an event bus, generic repositories with variance and query specs, a plugin host, a rules
  engine DSL, a middleware pipeline, an undo/redo editor, a parser-combinator library, an entity-component system, a units
  library on value classes, a tiny ORM with delegated columns, a payroll over a class hierarchy and a toolkit of inline helpers.
- Text-heavy realistic programs and ports as test cases (`realworld_text_*`, `realworld_port_*`): a JSON parser and pretty
  printer, a text formatter with tables and `String.format` reports, a Pratt parser with positioned errors, a Markdown-to-HTML
  converter, string algorithms (KMP, Rabin-Karp, suffix arrays, Manacher, Levenshtein), a regex log analyzer, a templating engine,
  a TOML-ish config parser, a CSV dialect sniffer, Unicode text processing, number formatting and parsing, Rosetta Code tasks and
  Advent of Code text puzzles.
- `String.format`: `%<s` (the previous specifier's argument), `%h`/`%H`, `%c` of any code point, precision on `%b`/`%h`, and
  java.util.Formatter's exceptions (`MissingFormatArgumentException`, `UnknownFormatConversionException`,
  `IllegalFormatConversionException`, `IllegalFormatPrecisionException`, `MissingFormatWidthException`,
  `FormatFlagsConversionMismatchException`, all `IllegalFormatException`s) with the JDK's messages; they can be caught by name.
- `Regex.matchAt(input, index)` and `matchesAt`, class intersection (`[a-z&&[^aeiou]]`, `[\w&&\D]`), and with `--strings utf16`
  the Unicode properties `\p{L}`, `\p{Lu}`, `\p{Ll}`, `\p{Lt}`, `\p{N}`/`\p{Nd}`, `\p{M}`, `\p{Z}`/`\p{Zs}`, `\p{IsWhite_Space}`,
  `\p{javaWhitespace}`, `\p{javaLetterOrDigit}` and their `Is`/`java` aliases (the POSIX classes such as `\p{Alpha}` stay ASCII, as in
  Java).
- `when (x) { in collection -> }` and `in "aeiou" ->`: `in` conditions that are not ranges call `contains`.
- `Char.equals(other, ignoreCase)` without `--strings utf16`, `codePointAt`/`codePointBefore`/`codePointCount`/
  `offsetByCodePoints` of a `StringBuilder`, hexadecimal floats in `toDouble()` (`"0x1.8p3"`), and `Boolean.xor`/`not()`.
- `vararg` parameters that are not the last one (`fun row(vararg cells: String, width: Int = 5)`, `fun total(vararg xs: Int,
  f: (Int) -> Int)`), in functions, methods, constructors and inline functions, and spreads that are not the last argument of
  an `inline fun` expanded at the call site (`countOf<Int>(*xs, 2)`).
- A companion object with a member named like a member of the class's instances (`fun ok()` next to `val ok`, `toString`,
  `copy`) gets a table of its own instead of being an error.

- `ConcurrentModificationException` as on the JVM: `ArrayList`, `LinkedList`, `HashMap`, `LinkedHashMap`, `HashSet`,
  `TreeMap`, `TreeSet` and `PriorityQueue` count structural changes (`____modCount`), and `for` loops, `forEach`, iterators and
  `subList` views check it where the JDK's iterators do (removing the second-to-last element during a loop ends it quietly;
  `Map.forEach { k, v -> }` throws after the whole map). Loop bodies that cannot change a collection (locals, literals,
  operators, plain property reads, `println`) and loops over arrays or fresh `listOf(...)` are not checked.
- A class extending a library collection and overriding `size`, `iterator()`, `get`, `contains`, `isEmpty`, `indexOf`,
  `listIterator`, `entries`, `keys`, `values` or `containsKey` has the overrides called by the library's operations where the
  JDK and the stdlib call them (`toString`, `for`, `map`, `first()`, `contains`, `equals`, `toList`, `HashSet(c)`, a map's
  `toString`, loops, `putAll`, ...), see `CollectionOverrides.lua`; other collections keep their direct paths.
- `TreeMap.navigableKeySet()`, `descendingKeySet()` (navigable: `floor`, `ceiling`, `pollFirst`, `descendingSet`, ...),
  `descendingMap()` as a live `TreeMap$DescendingSubMap`; `IntRange.EMPTY`, `LongRange.EMPTY`, `CharRange.EMPTY`.
- Arrays know their JVM class at run time: an `IntArray` or `Array<String>` held in an `Any` has its class (`[I`,
  `[Ljava.lang.String;`), `is IntArray`/`is Array<*>` tell arrays apart, and `toString()` is `[I@hash`.
- `is Queue`, `is Deque`, `is TreeSet`, `is TreeMap`, `is PriorityQueue`, `is java.util.ArrayDeque` and `is LinkedList`
  test the class itself.

### Changed
- `println(x)` and `print(x)` of a platform-typed primitive (`treeMap.higherKey(k)` is `Int!`) throw `NullPointerException` for
  null, as the JVM's unboxing for `println(Int)` does (`__K2L_NotNull(x)`).
- A map's `keys`, `values` and `entries` are live views (they were copies that only wrote removals back): they see later
  changes, track the map's size, and `remove`, `removeIf`, `retainAll`, `clear`, their iterators' `remove()` and `setValue`
  write through; `values` is a `Collection`, not a `List`. Loops over a map's keys, values or entries read the map's arrays
  without copying (much faster on PUC Lua), and `for (x in list)` is a numeric loop (faster than `ipairs` on PUC Lua).
- `buildList { }`, `buildSet { }` and `buildMap { }` return the stdlib's `ListBuilder`, `SetBuilder` and `MapBuilder`, read-only
  after the block (they were an `ArrayList`, `LinkedHashSet` and `LinkedHashMap`).
- `java.util.ArrayDeque` is not a `List` (`is List` is false, `as List` throws `ClassCastException`, `==` a list is false).
- `HashMap`'s and `LinkedHashMap`'s `putIfAbsent`, `merge` and `compute*` no longer call an overriding `get`/`put`, and
  `ArrayList.contains` calls `indexOf`, as in the JDK.
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
- Casting `emptyList()`, `emptySet()`, `emptyMap()`, a primitive array's `asList()` or an object of a class implementing only
  read-only collection interfaces to `MutableList` (`MutableSet`, ...) throws `ClassCastException` with the JVM's message, and
  `is MutableList` is false for them, as on the JVM.
- `getOrPut` and `getValue` of a map read it with `get` (and `containsKey`), `AbstractSet`'s `equals` and `removeAll` call
  `contains`/`remove`, and `PriorityQueue.removeIf`/`removeAll` heapify without calling `add`, as the JDK and Kotlin's stdlib do.
- A `for` loop over an object of a class implementing `List` (or delegating it) uses its `iterator()`, as on the JVM.
- `first()`, `last()` and `single()` of an empty collection that is not a list say "Collection is empty.".
- `size` of a `Collection` is its field (it was `count()`).
- `Long` bitwise operations (`and`, `or`, `xor`, `inv`, shifts, bit counts, `takeHighestOneBit`/`takeLowestOneBit`) are exact
  for values below 2^53 on Lua 5.1, 5.2 and LuaJIT without `--long64 emulate` (they were 32-bit), so
  `x.toLong() and 0xFFFFFFFFL` and masks over 32 bits work.
- `Regex.findAll` returns a lazy `Sequence`, as in Kotlin: matches are searched for as they are pulled.
- `is Comparable<*>` is exact for classes of the program: objects (`object Version : Comparable<Version>`), implementations
  through superclasses and interfaces and enums are Comparable (a class table records it in `____comparable`), a class with only
  an `operator fun compareTo` is not.

### Fixed
- `"%s %s".format(null, x)` and `"%s".format(null)` resolve to the `Locale` overload, as in Kotlin, so they throw
  `MissingFormatArgumentException` like the JVM instead of printing `null`.
- `String.format`: `%g` picks fixed or scientific notation after rounding (`999.9999` is `1000.00`), `%#010x` puts the zeros after
  `0x`, `%x`/`%o` of a negative `Byte`, `Short` or `Long` give the two's complement of the type's width (`ff`, `ffff`, sixteen `f`s;
  they were 32-bit), `%0s` and the like are rejected, and an unknown conversion is reported before a missing argument.
  `%e`/`%g` of subnormal doubles keep two significant digits like Java (`4.900e-324`).
- The literal `-2147483648` compiled to `-(-2147483648)`, which is `2147483648`.
- `"-0.0".toDouble()` and `"-0".toDouble()` gave `0.0`; `(-0.5).toLong()`, `(-0.2).roundToInt()` and the like printed `-0` on
  Lua 5.1, 5.2 and LuaJIT.
- A `Double?` or `Float?` printed like an `Int` (`2` for `2.0`) on Lua 5.1, 5.2 and LuaJIT; it now prints by its static type.
- A range of Doubles printed integral bounds as integers on Lua 5.1, 5.2 and LuaJIT (`30..50` for `30.0..50.0`).
- `nullMap.orEmpty()` crashed ("attempt to index a nil value"); `nullSet.orEmpty()` gave a list, `nullList.orEmpty()` an
  `ArrayList` (now `EmptyMap`, `EmptySet`, `EmptyList` as on the JVM).
- `super.iterator()` in a class extending a library collection recursed forever.
- A `TreeSet`'s `descendingSet()` was a `LinkedHashSet`.
- `unmodifiableMap(m).keys` (and `values`, `entries`) are unmodifiable views, and `unmodifiableCollection` of a collection that
  is not a list is a `Collections$UnmodifiableCollection`.
- References to library properties compiled but failed at run time ("attempt to index a function value").
- `::Constructor.name` is `<init>`.
- `String.lastIndexOf("")` starts at the last index like Kotlin, `trimMargin` rejects a blank margin prefix, and string members
  called on a platform-typed `String!` (the elements of a Java stream) are mapped.
- `for (c in 'a'..'z' step 2)` (the step was converted like a `Char`); a non-constant `step` that is not positive throws
  `IllegalArgumentException` instead of looping forever on Lua 5.1; `x in a..f()` always evaluates `f()`, and before `x`.
- Interface delegation compiled to a class without the delegated members; delegating a library interface k2l has no
  implementation for (`CoroutineContext`, `Executor`, ...) is now reported. `x in a..b` on `ULong`s above 2^63 compares unsigned on Lua 5.3/5.4.
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
- Comparing enums (`<`, `compareTo`, `sorted()`, `max()`, `sortedBy { it.level }`, `TreeSet`) failed at run time: enum classes
  now have `compareTo` (the difference of the ordinals).
- A function sharing its name with a property of its class hierarchy (`private val items` and `fun items()`) was rejected;
  it now gets its own Lua name. Before, a subclass's property could also hide a superclass's method of the same name.
- `::method` and `::property` without a receiver inside a class were compiled as unbound references (a crash when called).
- `data object`s printed like plain objects (`app.Cmd$Look@1`) and failed on `hashCode()`/`toString()` calls; value classes
  compared and hashed by identity (`Ref(Col(0), 1) != Ref(Col(0), 1)`, map lookups missed) and printed as `Col@1`.
- `vararg` parameters of constructors received only their first element.
- `RuntimeException(message, cause, false, false)` passed a Boolean as the cause.
- `entries`, `values()` and `valueOf` called from an enum's companion object were rejected ("This receiver").
- Reassigning a variable declared with `var (a, b) = ...` was rejected.
- A function reference or `() -> Unit` value converted to a function type with a result other than as an argument
  (`val h: () -> Any = ::work`, `return ::work`, `listOf<() -> Any>(::work)`) returned `nil` instead of `kotlin.Unit`.
- Two objects made by the same object expression (or local class) in different runs had different `KClass`es and `javaClass`es.
- `x in a..b` over Comparable objects (enums, classes of the program) compared the tables with Lua's `<` and failed.
- Members of arrays read from an `out`-projected container (`rows[0].size` with `vararg rows: DoubleArray`, an
  `Array<out IntArray>`) were rejected.
- `Regex.findAll(...).forEach { }` and `for (m in regex.findAll(...))` failed at run time.
- A private property named like a method of its class (`private var next` next to `fun next()` in an iterator) was rejected.
- `println` of a string containing a NUL character stopped at it on Lua 5.1.
- Guard conditions in `when` (`is Int if x < 0 ->`, `else if ready ->`) were ignored: the branch was taken whenever its
  condition matched.
- On Lua 5.1, 5.2 and LuaJIT, a data class with a `Double` property holding an integral value (`3.0`) hashed it like an `Int`,
  so `HashMap`/`HashSet` of such keys iterated in another order than on the JVM.
- `kotlin.text` functions of `CharSequence` called on a `StringBuilder` (`sb.removeSuffix(", ")`, `sb.lines()`, `sb.split(...)`,
  `sb.trim()`) were rejected; they work on its text.
- A null platform-typed value (`"${treeMap.higherKey(k)}"`, an `Int!` from a Java method) in a string template or
  concatenation failed with "attempt to concatenate a nil value" instead of printing `null`.
- A string template ran an expanded inline call (or another entry needing statements) before the entries to its left
  (`"${counter} ${get<T>()}"` printed the counter after the call).
- A bound reference to a member of a companion (`Registry.register(Widget::create)`) did not initialize the companion when the
  reference was made, and an object qualifier cached before arguments that need statements was initialized after them.
- A top-level property whose initializer refers to the property itself in a lambda (`val json: Parser = lazyParser { ... json
  ... }`) read an undefined global.
- An override did not apply the default arguments it inherits from the function it overrides (`ceo.report()` with
  `fun report(indent: String = "")` declared in an interface passed `nil` on).
- A reference to a function with a `vararg` parameter used as a function taking the Array (`val f: (IntArray) -> Int = ::sum`)
  passed the Array as one element.
- `is T`/`as T?` with a reified `T` ignored the `?` (`null.isA<String?>()` was false, `firstOrNull { } as T?` threw
  `NullPointerException` for null), and `is String?`/`when` branches `is Int?` did not hold for null.
- A property read during construction before its initializer ran, through a method called by an earlier initializer or by a
  superclass constructor (`val x = compute()` before `val y = 5`), was nil in Lua ("attempt to perform arithmetic on a nil
  value"); it reads the JVM's `0`/`false`/`null`.

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
