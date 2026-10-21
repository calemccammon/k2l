# Changelog

All notable changes to k2l. The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/). The version lives in `gradle.properties`.

## [Unreleased]

### Added
- `Class.enumConstants` (also through `KClass.java` and `javaClass`): a fresh array of the entries of an enum class, in
  declaration order, or `null` for any other class, including the class of an entry with a body, as on the JVM. And
  `Enum.declaringJavaClass`, the enum class of an entry.
- `k2l --check` analyzes the sources and reports every Kotlin error and every construct k2l cannot translate, without
  writing any files. It ends with a count (`k2l: checked 4 file(s): 2 errors, 0 warnings`) and exits with status 1 when
  there are errors. The Gradle plugin has a matching `k2lCheck` task.
- Diagnostics show the source line with the problem underlined, as kotlinc does. Where a cheap and correct workaround
  exists they add a one-line hint, such as `--strings utf16`, a newer Lua target for `goto`, or a lambda in place of a
  callable reference k2l can't translate. When several diagnostics share a hint, only the first one prints it.
- `--watch` turns on source maps by default, so Lua errors in the development loop show Kotlin positions.
  `--no-source-map` or `"sourceMap": false` in k2l.json turns them off. Builds without `--watch`, the Gradle plugin and
  the golden tests are unchanged.
- `--no-source-map`, and examples in `--help`.
- A standard library coverage report, [docs/stdlib-coverage.md](docs/stdlib-coverage.md): every public function, property and
  constructor of the main `kotlin.*` packages and the commonly used `java.util`/`java.lang` classes, probed by transpiling a
  generated call, with the supported, partly supported and unsupported names and a percentage per package.
  `./gradlew :compiler:stdlibCoverage` regenerates it; `check` only compiles it.
- `kotlin.time`: `Duration` (construction from `Int`/`Long`/`Double` units and `toDuration`, `ZERO`/`INFINITE`, arithmetic,
  comparison, `inWhole...`, `toLong`/`toInt`/`toDouble`, `toComponents`, `toString` and `toString(unit, decimals)` as the JVM
  formats them, `toIsoString`, `parse`/`parseOrNull`/`parseIsoString`/`parseIsoStringOrNull`), `DurationUnit`, `measureTime`,
  `measureTimedValue` and `TimedValue`, `TimeSource.Monotonic` (on `os.clock()`) and `TestTimeSource` with their time marks
  (`markNow`, `elapsedNow`, `hasPassedNow`/`hasNotPassedNow`, `+`/`-`, comparison). Tested by `stdlib_time_duration`,
  `stdlib_time_sources` and `stdlib_time_parse`.
- `java.util.Stack` (`pop()`/`peek()` of an empty stack throw `java.util.EmptyStackException`, which `catch` and `is`
  name), `java.util.StringJoiner` (`length()` counts UTF-16 units with `--strings utf16`), `Objects.requireNonNull`/`requireNonNullElse`/`isNull`/`nonNull`/`toString`/
  `checkIndex`/`compare`, `Boolean.compare`/`logicalAnd`/`logicalOr`/`logicalXor`/`valueOf`, `Character.digit`/`forDigit`,
  `Double.max`/`min`/`sum` and the boxes' static `hashCode`. Tested by `stdlib_java_util_extras` and
  `stdlib_java_util_utf16`. `Comparator.comparingInt`/
  `comparingLong`/`comparingDouble`, `thenComparingInt`/`Long`/`Double` and the static `Comparator.nullsFirst`/`nullsLast`
  (`stdlib_java_comparators`).
- `kotlin.text`: `replaceAfter`/`replaceBefore`/`replaceAfterLast`/`replaceBeforeLast`, `toByte`/`toShort` (and `OrNull`),
  `splitToSequence` (also `Regex.splitToSequence`), `windowedSequence`/`chunkedSequence`, `Char.isISOControl`, `Charsets.UTF_8`
  and decoding a `ByteArray` (`decodeToString()`, `toString(charset)`), the folds, scans and `...To` operations over a string's
  characters (`foldRight`, `reduceRight`, `runningFold`/`scan`, `mapIndexedNotNull`, `associateByTo`, `toHashSet`,
  `firstNotNullOf`, `randomOrNull`, ...), `toHexString()`/`hexToInt()`/`hexToLong()`/`hexToShort()`/`hexToByte()`/
  `hexToByteArray()` with the default `HexFormat`, the `StringBuilder` extensions `deleteAt`/`deleteRange`/`setRange`, and
  `startsWith`/`endsWith`/`contains` with a non-literal `ignoreCase`. Tested by `stdlib_text_extras`, `stdlib_text_chars` and
  `stdlib_text_hex`.
- `kotlin`: `Boolean.and`/`or` (both operands are evaluated), `lazyOf`, `enumValues<E>()`/`enumValueOf<E>()` of the program's
  enums (a reified `E` included), `setOfNotNull`, and `reduceRightOrNull`/`reduceRightIndexed`/`reduceRightIndexedOrNull` of
  lists and arrays.
- Classes and objects extending `kotlin.random.Random()`: only `nextBits(bitCount)` is abstract, and `nextInt`
  (with bounds and ranges), `nextLong`, `nextDouble`, `nextFloat`, `nextBoolean`, `nextBytes`, `nextUInt`/`nextULong` and
  the extensions taking a `Random` (`shuffled`, `shuffle`, `random`) draw from it as Kotlin's default implementations
  do. The lualib's `__K2L_RandomBase` holds them; XorWow (`Random(seed)`) extends it and gives the same numbers as
  before. Overriding an overloaded member (`nextInt()`) is reported, with a hint to override `nextBits`. Tested by
  `stdlib_random_subclass` and `stdlib_random_subclass_long64` (with `--long64 emulate`) on every target.
- `java.lang.StrictMath`, bit for bit the JVM's: `sin`, `cos` and `tan` (with fdlibm's argument reduction,
  `__ieee754_rem_pio2`, and `__kernel_rem_pio2` for huge arguments), `log`, `log10` and `pow` are new ports of fdlibm
  (`StrictMath.lua`, from the JDK's `FdLibm.java`), `exp`, `asin`, `acos`, `atan`, `atan2`, `cbrt`, `hypot`, `sinh`,
  `cosh`, `tanh`, `expm1`, `log1p` and `IEEEremainder` the existing ones of `FdLibm.lua`, and every other member
  (`sqrt`, `floor`, `ceil`, `rint`, `abs`, `max`, `round`, `floorMod`, ...) is `Math`'s. Over 200000 random arguments
  (random bit patterns, multiples of π/2, wide magnitudes) none of `sin`, `cos`, `tan`, `log`, `log10`, `pow` and `exp`
  differed from the JVM on any target. `kotlin.math.sin` and `Math.sin` stay on Lua's `math` library. Tested by
  `stdlib_strictmath`.

### Changed
- An uncaught exception prints like on the JVM on every target: `Exception in thread "main" <toString()>` and a
  `Caused by:` line per cause on stderr, then the Lua traceback of where it was raised (Kotlin positions with
  `--source-map`), and the program exits with status 1. Before, Lua 5.1 printed `(error object is not a string)`, 5.2
  to 5.4 the `toString()` alone and LuaJIT the `toString()` with a traceback, all before the program's buffered
  output. `main` runs under `xpcall` (`__K2L_Main`) or the coroutine driver of `try` blocks; a Lua error that is not an
  exception prints its message and traceback. With `--source-map`, programs using `try` now run under that driver as
  well (they used plain `pcall`s, `__K2L_RunMain` is gone). On Lua 5.1 the `xpcall` takes one of the 200 nested C
  calls, so a recursion through a `try` block at every level fails one level earlier (194 instead of 195 levels).
- `Random.nextBits(bitCount)`, `nextBytes(size)`, `nextBytes(array, fromIndex, toIndex)` and `nextLong(LongRange)`, with the
  JVM's numbers for a seeded `Random` (four bytes per draw, low byte first, then one draw for the rest), and
  `Double.IEEErem` / `Math.IEEEremainder` (exact, as fdlibm computes it). Found by `realworld_sim_montecarlo` and
  `realworld_sim_boids`.
- **`kotlin.math` gives the JVM's bits.** `hypot`, `atan`, `atan2`, `asin`, `acos`, `cbrt`, `sinh`, `cosh`, `tanh`, `expm1`
  and `ln1p` (and their `Math` forms) are ports of fdlibm, the `StrictMath` code these JVM functions run (`FdLibm.lua`).
  C's libm rounds differently in the last bit: over 2000 random arguments, `hypot` differed from the JVM 225 times,
  `atan2` 349, `cbrt` 271, `asin` 124, `ln1p` 356, `tanh` 1238 (k2l's own formulas for the hyperbolic functions were off
  by up to 14000 units in the last place). Now none differ, on every target. `hypot` also no longer overflows
  (`hypot(1e300, 1e300)` was Infinity) and is Infinity when one argument is infinite and the other NaN. Tested by
  `stdlib_math_strict`.
- The Kotlin/JVM oracle runs at most 4 cases at a time by default (it used one per processor, which could exhaust the
  memory of a large machine); `-PoracleThreads=N` still sets it.
- A diagnostic on a call in a chain points at the call's name: for `list.stream().spliterator()` it points at
  `spliterator`, not at `list`. Kotlin compile errors use the position kotlinc reports. For
  example, a mistyped `val` initializer is reported at the initializer rather than at `val`.
- Library names in diagnostics are written with dots (`Library API 'java.util.stream.Stream.spliterator'`, previously
  `Kotlin library API 'java/util/stream/Stream.spliterator'`).
- Two diagnostics with the same position and message are reported once. Before, a compound index assignment such as
  `x[1] += 2` through a member-extension operator reported its error twice.
- A failed build ends with a count (`k2l: 3 errors, 0 warnings; no files written`). Argument and k2l.json errors print a
  pointer to `--help` instead of the whole usage text.
- k2l.json: an unknown key suggests the nearest valid one (`'srcDir' (did you mean 'srcDirs'?)`). A value of the wrong
  type is an error; before, `"sourceMap": "yes"` or `"luaTarget": 5.4` was silently ignored. Comments and trailing
  commas are allowed, and invalid JSON is reported in one line.
- A source directory that doesn't exist is an error, and a build that finds no `.kt` files prints a warning. Before,
  both reported `wrote 0 file(s)` and succeeded.
- An unknown option suggests the nearest valid one (`--sourcemap` gives `did you mean --source-map?`), and `--out=x`
  explains that the value goes after a space.
- `java.util.EnumMap` and `java.util.EnumSet` (`noneOf`, `allOf`, `of`, `copyOf`, `range`, `complementOf`): ordinal order,
  the JDK's class names, `is` tests and `IllegalArgumentException` messages for empty copies and reversed ranges. Found by
  the `realworld_parse_connection` state machine; tested by `jdk_enum_collections`.
- The top-level properties of a file are initialized on its first use, as the JVM initializes a file's facade class, when
  their initializers can be noticed (they call code or read mutable state) and the file has no `main`. These properties
  live in the file's exports table, and `__K2L_LazyFile` runs their initializers on the first read or write of one of them.
  Before, they ran when the program started. Files whose initializers are constants or collection factories, and the
  entry file, are unchanged.
- **Faster UTF-16 match indices.** With `--strings utf16`, each `MatchResult.range`, group range and start index of
  `find(input, startIndex)`/`matchAt` was converted by decoding the text up to it again (and cached the prefix, which
  pushed the text itself out of the cache), so the indices of many matches in a long non-ASCII text took quadratic time.
  The byte offset of every UTF-16 unit is now computed once per text and looked up. A program reading the ranges of
  6000 matches in a 28000-unit text runs in 1.0 s instead of 60 s on Lua 5.1; 20000 matches in 120000 units take 1.2 s
  instead of more than 5 minutes on 5.4. Results are unchanged.
- **Faster `HashMap` creation.** A `HashMap` holds nine fields once it has a key; set one by one, the ninth (the live
  entries added in 0.2.0) made Lua rehash the object from 8 to 16 slots, on top of the rehashes at 1, 2 and 4.
  `HashMap()` now builds the object with one table constructor that has room for all of them. Creating a map is about
  3x faster on LuaJIT and 25% faster on Lua 5.4, and `oop_interpreter` (a `HashMap` per scope) is back to its speed
  before 0.2.0, or slightly faster. `LinkedHashMap` (`mutableMapOf()`), `LinkedHashSet` (`mutableSetOf()`) and `HashSet`
  do the same for their seven, five and seven fields (four rehashes each before): creating one and adding two keys is
  about 2x faster on LuaJIT, 17-19% faster on Lua 5.4 and 6-10% faster on 5.1; the benchmark programs, which make few
  small maps, are unchanged.
- **Bounded lookbehind.** A lookbehind tried every start position back to the start of the input, at every position,
  so `(?<!a)b` or `(?<=x|yz)c` over a long text took quadratic time. Like Java's `Pattern`, the regex compiler now
  computes the minimum and maximum length of the lookbehind's body and tries only the starts in between: three
  lookbehind searches over a 40000-character text take 85 ms instead of 268 s on Lua 5.4. A lookbehind Java rejects
  (a back-reference, or a repeated group whose body has alternatives or variable repetitions, such as `(?<=(a|bc){2})`
  or `(?<=(?:ab)*)`) throws Java's `PatternSyntaxException` with its message, index and caret line; the unbounded forms
  Java accepts (`(?<=a+)`, `(?<=x.*)`) still look back to the start. Tested by `regex_lookbehind` and
  `regex_lookbehind_utf16`.

### Fixed
- Boxed Doubles compare with `Double.equals`, as on the JVM: in collections (`contains`, `indexOf`, `lastIndexOf`,
  `remove`, `distinct`, `toSet`, `groupBy`, `==` of lists, sets and maps), in an `Any` or a type parameter (`a == b`),
  `Pair`/`Triple`, `Objects.equals`, `x.equals(y)` and a data class's Double and Float properties (`Double.compare`):
  NaN equals NaN and `0.0` differs from `-0.0`. `listOf(Double.NaN).contains(Double.NaN)` was false, `-0.0` and `0.0`
  were one key of a `HashMap` or `HashSet`, and a NaN key threw `table index is NaN`. `HashMap` and `HashSet` keep NaN
  and `-0.0` keys in their hashCode buckets (`Double.hashCode`); other number keys keep their raw lookup, which tests
  two more comparisons. `==` of two values whose static types are `Double` (or `Double?`, also after a smart cast) stays
  IEEE (`NaN == NaN` is false), exactly where Kotlin uses IEEE. `Double.hashCode()` of NaN is the JVM's on Lua 5.3/5.4
  (Lua's NaN can have the sign bit set), and of `-0.0` on 5.1, 5.2 and LuaJIT. Tested by `collection_double_equality`.
- On Lua 5.1, 5.2 and LuaJIT, `Int` and `Long` arithmetic no longer makes `-0`, which printed as `-0` and which
  `Double.equals` would now tell from `0`: `-x` is `0 - x`, a product is `x * y + 0` unless a factor is a positive
  literal (an enclosing `+` or `-` drops the `+ 0` again), and `/` and `floorDiv` of a zero dividend by a negative
  divisor give `0`, and so do `Math.negateExact(0)` and `Math.multiplyExact(0, -1)`.
- `floor(-0.0)` and `Math.floor(-0.0)` are `-0.0`; they were `0.0` (`math.floor(x) + 0.0`). Tested, with `ceil`, `round`,
  `Math.rint`, `truncate`, `abs`, `sign`, `withSign` and `Math.copySign` of `±0.0`, NaN and the infinities, by
  `stdlib_math_signed_zero`.
- `Double.toString` of a power of two whose nearest 16 digits do not read back printed 17 digits where 16 do:
  `2.0.pow(710)` printed `5.3863791631855345E213`, the JVM `5.386379163185535E213` (46 of the 2098 doubles that are
  powers of two printed differently). A subnormal prints at least two digits, the nearest two, as on the JVM:
  `9.9E-324`, not `1.0E-323`. Now every power of two, its neighbors and their negations print as on the JVM.
- A reference to a Java static function (`StrictMath::sin`, `Math::sqrt`) took a receiver as its first parameter, so
  `listOf(4.0).map(Math::sqrt)` passed the element as that receiver and `nil` as the argument.
- `Random(seed).nextInt(from, until)` over exactly 2^31 values (`nextInt(Int.MIN_VALUE, 0)`) drew like the JVM's
  rejection loop for ranges wider than an `Int`; Kotlin's `until - from` is `Int.MIN_VALUE` there, a power of two, so it
  takes `nextBits(31)`. Now the same numbers as the JVM.
- An endless recursion that ends `main` prints `Exception in thread "main" java.lang.StackOverflowError`, then Lua's
  message with its position and the traceback, on every target (Lua 5.1 to 5.4 printed the message and traceback without
  the header). On LuaJIT it printed only `stack overflow`: the overflow happens in a compiled trace, and LuaJIT then
  unwinds without calling the `xpcall` handler that captures the traceback (with `-joff` the handler runs). `main` now
  runs in a coroutine on LuaJIT, whose stack stays readable after the error. Tested by `UncaughtTest`.
- A lookbehind no longer starts inside a multi-byte UTF-8 character: `(?<![^é])b` failed after `é`, because `[^é]` matched
  the last byte of `é` on its own.
- `\p{IsAlphabetic}` and `\p{javaAlphabetic}` under `--strings utf16` match what `Character.isAlphabetic` does: the
  letters plus `Nl` (such as `Ⅻ`) and `Other_Alphabetic` (such as the circled letters `Ⓐ`, combining vowel signs). They
  matched the letters only. `Unicode.lua` grows by 1.3 KB.
- `byteArrayOf(-128)` and `shortArrayOf(-32768)` (a `Byte` or `Short` minimum written as a negative literal) produced 128 and
  32768: the literal after the minus wraps to the negative value, which was negated again. Found by `stdlib_text_hex`.
- `String(bytes)` of a `ByteArray` joined the byte values (`"104105"`); it now decodes the bytes (as UTF-8).
- `maxOfOrNull`/`minOfOrNull` of a string's characters, when empty, passed no value at all as the last argument of a call
  (`listOf(x, "".minOfOrNull { ... })` lost the `null`).
- `main(args: Array<String>)` receives an `Array` (`args.isEmpty()`, `args.size`, `in args` work); it was a plain Lua table.
- An invalid regex pattern threw a plain `IllegalArgumentException`; it is now a `java.util.regex.PatternSyntaxException`
  (a subclass, so existing catches still work), which `catch` and `is` can name. A pattern defining the same group name
  twice (`(?<n>x)(?<n>y)`) is now rejected, as by `java.util.regex`. Found by `realworld_parse_logs`.
- On Lua 5.1, 5.2 and LuaJIT, printing a `List<Double>`, `Set<Double>`, `Map<String, Double>`, `Pair<String, Double>` (or
  nestings of them) showed integral elements as Ints (`[1.5, 3]`); where the static type makes every number a `Double`, they
  now print as on the JVM (`[1.5, 3.0]`). Found by `realworld_parse_ini`; tested by `collection_double_strings`.
- `buildString(capacity) { ... }` called the capacity as the builder function and dropped the lambda ("attempt to call a
  number value"); the capacity is now a hint, as for `buildList`. Found by `realworld_parse_markdown`; tested by
  `string_builder_text`.
- `typeOf<T>()`: a `KType` that prints like the JVM's without kotlin-reflect, compares by type (usable as a map key), and has
  `isMarkedNullable`, `classifier` and `arguments`. `Map.Entry::class`, `Iterator::class`, `Comparable::class` and the
  function types' classes print their JVM names.
- Unchecked casts: the elements of an unchecked `x as List<String>` passed to a lambda literal (`l.map { it }`,
  `l.filter { true }`, `l.asSequence().map { }`, a lambda of a function of the program) are checked against the lambda's
  parameter types as it starts, and throw `ClassCastException` where the JVM does. So are reads through a cast used in
  place (`(x as List<String>)[0].length`) and through a property the cast initializes, is passed to as a constructor
  argument or is assigned to (`Box(l).items[0].length`).
- The SAM constructor `ReadOnlyProperty { thisRef, property -> }` was rejected as an unsupported library API; it makes a
  delegate object now.
- `@LuaName("on_load")` on a top-level function or plain property of the program names its local and its field in the
  module table, so a Lua host calls `require("mods.Greeter").on_load(host)`. Before, the annotation only applied to
  external declarations and was ignored elsewhere.
- Lua's `tostring()` and `print()` of an object of a class of the program give its Kotlin `toString()`. Before, Lua code
  printing a Kotlin object got `table: 0x...`.
- Six multi-file test programs (`realworld_project_*`): a five-package inventory tool with cross-file state and init order,
  an import cycle through `main.kt`, name clashes across packages and aliases, a plugin host, and two interop programs
  where hand-written Lua and Kotlin call each other. There is also a Gradle plugin functional test of a multi-package
  project.
- `main` did not run when another file imported the entry file (an import cycle through `main.kt`). It now runs unless the
  chunk is loaded with `require`.
- A top-level initializer on an import cycle that read another file of the cycle could find that file half loaded
  (`attempt to index a nil value`), depending on the order of the `require`s, even where the JVM's order was fine.
- A file whose name has a dot (`Style.common.kt`, as in multiplatform projects) was written as `Style.common.lua`, which
  `require("ui.Style.common")` cannot find. It is now `Style_common.lua`, and its facade class name in reflection output
  is `Style_commonKt`, as with kotlinc.
- A member of an external interface or class with a Lua keyword as its `@LuaName` (`@LuaName("repeat")`) was called as
  `s:repeat(n)`, which is a Lua syntax error. It is now `s["repeat"](s, n)`.
- **Every Unicode general category in regexes.** `\p{Lu}`, `\p{Ll}`, `\p{Lt}`, `\p{Lm}`, `\p{Lo}`, `\p{Mn}`, `\p{Mc}`,
  `\p{Me}`, `\p{Nd}`, `\p{Nl}`, `\p{No}`, `\p{Pd}`, `\p{Ps}`, `\p{Pe}`, `\p{Pc}`, `\p{Po}`, `\p{Pi}`, `\p{Pf}`, `\p{Sm}`,
  `\p{Sc}`, `\p{Sk}`, `\p{So}`, `\p{Zs}`, `\p{Zl}`, `\p{Zp}`, `\p{Cc}`, `\p{Cf}`, `\p{Co}`, `\p{Cs}`, `\p{Cn}` and the groups
  `\p{L}`, `\p{LC}`, `\p{M}`, `\p{N}`, `\p{P}`, `\p{S}`, `\p{Z}`, `\p{C}`, also spelled `\p{IsLu}`, `\p{gc=Lu}` and
  `\p{general_category=Lu}`, and negated with `\P`. With `--strings utf16` they test non-ASCII characters by a table of
  the JDK's `Character.getType` (`UnicodeCategories.lua`, 7 KB, loaded only by a regex that may use `\p`); in the default
  bytes mode they are ASCII only, like the other properties. Binary properties (`\p{IsUppercase}`, ...) accept any case, and
  with `IGNORE_CASE` `\p{Lu}`, `\p{Ll}` and `\p{Lt}` match all three cased categories, as in Java.
- **`\p{Lu}`, `\p{Ll}` and `\p{N}` with `--strings utf16`.** `\p{Lu}` and `\p{Ll}` were `Character.isUpperCase` and
  `isLowerCase` (so `Ⓐ`, a symbol, was in `\p{Lu}`), and `\p{N}` was `\p{Nd}` (without `Ⅻ` or `½`); they are now the general
  categories, as in Java (`\p{IsUppercase}` and `\p{IsLowercase}` keep the old meaning).
- **Tracebacks of uncaught Lua errors in programs with a `try`.** On Lua 5.2 to 5.4 such a program runs `main` in the
  deep-try driver (`__K2L_DeepMain`), which raised an uncaught Lua error again from the driver, so the traceback showed
  only the driver. It now raises it with the traceback of the coroutine where it happened (the driver's frames follow).
  Uncaught exceptions print as before, as without a `try`, and the exit status stays 1.
- **A seeded `Random` drifted from the JVM's sequence after `nextInt(1)`.** Kotlin's XorWow `nextBits(0)` still draws a
  number, so `nextInt(1)`, `nextLong(1)` and `list.random(rng)` of a one-element list consume one; k2l returned 0
  without drawing, so every later number differed. Found by `realworld_sim_rpg` (a battle picking among the last
  enemy); tested by `realworld_sim_montecarlo`.
- `IntRange.random(rng)`, `nextInt(IntRange)` and `LongRange.random(rng)` draw as Kotlin does at the bounds
  (`0..Int.MAX_VALUE`, `Long.MIN_VALUE..Long.MAX_VALUE`) and for Long ranges (which draw Longs, not an index); an empty
  range throws `Cannot get random in empty range: 1..0` (`NoSuchElementException` from `random`, `IllegalArgumentException`
  from `nextInt`). `nextDouble(from, until)` handles a range wider than `Double.MAX_VALUE`, returns `until.nextDown()` when
  rounding reaches `until`, and prints the bounds of an empty range as Doubles (`[2.0, 1.0)`) on every target.
- `min`, `max`, `minOf`, `maxOf` and `Math.min`/`max` of Doubles: NaN wins whatever its position, and `-0.0` is below `0.0`
  (`min(0.0, -0.0)` is `-0.0`); `math.min` and `math.max` told neither. Integers still use `math.min`/`math.max`.
- `x.pow(y)` and `Math.pow` with a `Double` exponent: `1.0.pow(NaN)` and `(-1.0).pow(Infinity)` are NaN, as on the JVM (C
  gives 1). A literal or `Int` exponent still compiles to `^`.
- `truncate(-0.5)` is `-0.0`, and on Lua 5.1 `ceil(-0.5)`, `round(-0.4)` and `truncate(-0.5)` are `-0.0` too: Lua 5.1
  merges a function's constants `0` and `-0.0`, so the library's `return -0.0` returned `0.0` (also in `Float` rounding).
- On Lua 5.1, 5.2 and LuaJIT, an integer division whose quotient is between -1 and 0 (`-5L / d` with `d = 10L`) gave
  `-0.0`, printed as `-0`. Found by `realworld_sim_fixedpoint` (banker's rounding of money in cents).
- `joinToString()` of a `List<Double>`, `DoubleArray`, `List<Float>` or `FloatArray` without a transform prints each element
  by its type: on Lua 5.1, 5.2 and LuaJIT integral Doubles printed as Ints (`2, -3`), and in a program that uses `Float` a
  Double that is exactly a float printed as a Float (`2.220446E-16` for `1.0.ulp`).
- A program that uses `Float` (or `nextFloat()`) printed the Floats in a collection with Double digits
  (`[0.40338701009750366]` for `[0.403387]`) unless it also converted a `Float` to a string directly.
- A call of an extension of a basic type's companion (`fun Long.Companion.sign(v: Long)`, called as `Long.sign(x)`) was
  rejected as an unresolved call. Found by `realworld_sim_fixedpoint`.

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
