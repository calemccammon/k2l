# Caveats

k2l keeps Kotlin's compile-time semantics, but at run time it uses Lua's values and library. It does not emulate the
JVM. These are the differences a program can see.

## Numbers

- `Int`, `Long`, `Short`, `Byte`, `Float` and `Double` are all Lua numbers, with Lua arithmetic.
- Arithmetic does not wrap to 32 bits: `Int.MAX_VALUE + 1` is `2147483648`. On Lua 5.3 and 5.4, integers wrap at 64 bits.
- Before Lua 5.3 (5.1, 5.2, LuaJIT), every number is a double. A `Long` is exact only up to 2^53.
- `Float` is not rounded to single precision.
- `Int / Int` is floor division: `-7 / 2` is `-4`.
- `%`, `rem` and `mod` are Lua's `%`, whose result has the sign of the divisor: `-7 % 3` is `2`.
- Integer division by zero is an error on 5.3 and 5.4, and `inf` or `nan` before.
- `toInt()` and `toLong()` of a `Double` truncate toward zero. `toByte()`, `toShort()` and `toInt()` of an integer
  return it unchanged.
- `Int` bitwise operations wrap to 32 bits. Shift distances outside `0..31` differ between LuaJIT and the other targets.
- On 5.1, 5.2 and LuaJIT, `Long`'s `and`, `or` and `xor` are 32-bit, and its shifts are exact only below 2^53.
- Numbers print with Lua's `tostring`: 14 significant digits, `1e+20`, `inf`, `nan`.
- An integral `Double` prints `2.0` on 5.3 and 5.4, and `2` before. A large `Long` prints `9.2233720368548e+18` before
  5.3.
- `String.toDouble()` is `tonumber`. `"1.5f"` never parses. `"NaN"` and `"Infinity"` parse only on LuaJIT.
- `==` of numbers is Lua's `==`, also through `Any` and `equals`: `-0.0` equals `0.0`, and NaN equals nothing, so it
  cannot be a map key.
- `kotlin.math` is Lua's `math` plus short formulas. Results can differ from the JVM's in the last digits.

## Strings

- Strings are Lua byte strings. `length`, indexes and ranges count UTF-8 bytes: `"héllo".length` is 6.
- A `Char` is a one-byte string, so a `Char` held as `Any` passes `is String`.
- `uppercase()`, `lowercase()` and the `Char` predicates (`isLetter()`, `isDigit()`, ...) are ASCII only.
- Strings compare and hash by bytes.
- A lone surrogate in a string literal becomes `?`.

## Collections

- `HashMap` and `HashSet` keep insertion order, like `LinkedHashMap` and `LinkedHashSet`.
- `keys`, `values` and `entries` are snapshots: a later change to the map does not show in them.
- Removing from `keys`, `values` or `entries` does remove from the map.
- `x in map.keys` is `containsKey`, and `for (k in map.keys)` reads the map directly.
- `subList` and `asList` return copies, not views.
- Read-only collections are mutable at run time: `listOf(1, 2) is MutableList<*>` is `true`.
- There is no `ConcurrentModificationException`. A `for` loop runs up to the size the collection had when it started.
- Sorted maps and sets (`sortedMapOf`, `toSortedMap`, `sortedSetOf`, `toSortedSet`) have only the `Map` and `Set`
  operations.

## Hash codes

`hashCode()` is not the JVM's:

- Numbers hash by value. An integral `Double` hashes like the equal `Int`. NaN hashes to `0`.
- Strings hash with the 31-polynomial over their bytes.
- `true` and `false` hash to `1231` and `1237`.

## Sorting

- Sorting (`sorted`, `sortedBy`, `sortWith`, ...) is a stable merge sort.
- It calls comparators in a different order from the JDK.

## Random

- `Random.Default` is `math.random`. Lua 5.4 seeds it randomly at startup. On the other targets, call
  `math.randomseed` (bound with `@LuaExternal`) for different numbers on every run.
- `Random(seed)` is k2l's own generator. Its numbers are the same on every target, but not the JVM's.

## `String.format`

- `String.format` is Lua's `string.format`.
- A literal format is checked at compile time. `%n`, `%s`/`%S`, `%b`, `%c` and the `,` flag of `%d` and `%f` are
  translated. Argument indexes (`%1$s`), `%<s`, `%(d`, `%h` and date formats are compile errors.
- A format built at run time is translated at run time, where those specifiers are errors.
- Rounding is the C library's, not Java's `HALF_UP`: `"%.1f".format(2.25)` is `2.2`.
- A value exactly halfway (`"%.2f".format(0.125)`, `"%.0f".format(2.5)`) can round differently between LuaJIT builds
  and PUC Lua.

## Regex

- Only a [subset](library.md#regex) is supported, and patterns must be compile-time constants.
- Indexes (`range`, `find(input, startIndex)`) count bytes. Classes and `IGNORE_CASE` are ASCII only.
- `$` matches only at the very end of the input, not before a final line break.

## Exceptions

- Library exceptions keep their `java.lang.*` names: `java.lang.IllegalStateException: bad`. Messages can differ from
  the JVM's.
- A Lua runtime error is caught as a `RuntimeException` with Lua's message.
- A Lua or C stack overflow is a `StackOverflowError`, which `catch (e: Exception)` does not catch.
- An uncaught exception prints its `tostring` and a Lua traceback on stderr, and the program exits with status 1.
- There are no `Caused by:` lines, and `printStackTrace()` prints only the `toString()`.
- Every `try` (and `use`, `runCatching`, ...) runs in a `pcall`. PUC Lua allows about 200 nested C calls, so a recursion
  with a `try` at each level fails after some 190 levels. LuaJIT goes deeper.

## Types and reflection

- Generics are erased, and so are unchecked casts: `x as List<String>` accepts any list.
- The only reflection is `::class.simpleName` and the `name` of a callable reference (`::greet.name`).
- `toString()` of a class without its own is the class name and a counter in hex (`app.P@1f`), not an identity hash.
- A value class is not unboxed: it is a table holding the value.
- A `Unit` returned by Lua code is `nil`, so it prints as `null`.

## Arrays

- All arrays are one Lua class, whatever their element type.
- `is IntArray` (or any primitive array type) is a compile error. `as IntArray` only checks that the value is an array.
- An array prints its elements like a list (`[1, 2, 3]`). `==` of two arrays is still identity.

## Lua versions

- Numbers: see [above](#numbers). Before 5.3 every number is a double, and `Long` bitwise operations are 32-bit.
- Lua 5.1 has no `goto`. A few jumps are compile errors there (see [Lua targets](language.md#lua-targets)).
- Lua 5.1 cannot yield across `pcall`, so a `try` that can suspend runs in a coroutine of its own there. A yield through
  a C function, such as a Lua library function that calls back into Kotlin, still fails on 5.1.
