# Standard library

k2l translates the parts of the Kotlin standard library that map onto Lua. Everything is built on Lua's own values and
library. Anything else is a compile error.

- [What works](#what-works)
- [Regex](#regex)
- [Coroutines and sequences](#coroutines-and-sequences)
- [Not supported](#not-supported)

## What works

| Area | What you get | Built on |
|---|---|---|
| Collections | `List`, `MutableList`, `Set`, `Map`, `ArrayList`, `HashMap`, `LinkedHashMap`, `HashSet`, `LinkedHashSet`, `ArrayDeque`, arrays and primitive arrays, `Pair`, `Triple`, and almost all their extension functions | Lua tables |
| Sorted collections | `sortedMapOf`, `toSortedMap`, `sortedSetOf`, `toSortedSet`, with the `Map` and `Set` operations only | Lua tables |
| Sequences | `Sequence`, lazy, with its operations; `sequence { }`, `iterator { }` | Lua coroutines |
| Text | `String`, `StringBuilder`, `Char`: searching, splitting, trimming, padding, case and number conversions, templates | Lua strings and `string` |
| `Regex` | the subset below | Lua patterns |
| `String.format` | the common specifiers, checked at compile time when the format is a literal | `string.format` |
| Math | `kotlin.math`, `java.lang.Math`, numbers, conversions, bit operations | Lua's `math`, plus short formulas for `hypot`, `cbrt`, `expm1`, `ln1p`, `sinh`, `cosh`, `tanh` |
| Random | `kotlin.random.Random`: `Random.Default` and `Random(seed)` | `math.random`, and k2l's own seeded generator |
| Coroutines | `kotlin.coroutines`: `suspend`, `startCoroutine`, `suspendCoroutine`, contexts, interceptors, intrinsics | Lua coroutines |
| The rest of `kotlin` | ranges and progressions, `Result`, `runCatching`, exceptions, `require`/`check`/`error`, `repeat`, `TODO`, `lazy`, property delegates, `println`/`print`/`readln`, `measureTimeMillis` | Lua |

Collection notes:

- A list keeps its elements in the table's array part (1-based) with a `size` field.
- Maps and sets keep insertion order.
- Your classes can extend the abstract collections, `ArrayList`, `HashMap`, `LinkedHashMap`, `HashSet` and
  `LinkedHashSet`, or implement the collection interfaces.

A few Java-named APIs also work:

- the `java.lang.Math` statics (but not the `*Exact` functions);
- `System.currentTimeMillis`, `System.nanoTime` and `System.lineSeparator`;
- `Charsets.UTF_8`;
- `Closeable` and `AutoCloseable` (with `use`);
- `Comparator`, `Runnable` and `Callable` as SAM interfaces.

See [Caveats](caveats.md) for how all of these differ from the JVM.

## Regex

`Regex` is Kotlin's API on Lua patterns. The compiler translates each pattern to a Lua pattern, so:

- The pattern must be a compile-time constant: `Regex("[a-z]+")`, `"\\d+".toRegex()`. The options must be constants
  too.
- A pattern built at run time is a compile error.
- `Regex.fromLiteral(text)`, `Regex.escape(text)` and `Regex.escapeReplacement(text)` work with any run-time `text`.

Supported syntax:

- literal characters; `\t \n \r \f \a \e \0oo \xhh \uhhhh`; `\Q...\E`;
- `.`, classes `[a-z_]` and `[^...]`, and `\d \D \s \S \w \W` (also inside classes, except `\W`);
- `^` at the start and `$` at the end of the pattern;
- `*`, `+`, `?`, lazy `*?` and `+?`, on one character or class;
- `{n}`, `{n,}` and `{n,m}` up to 20;
- groups `(...)` without a quantifier, and back-references `\1` to `\9` to a group closed before them;
- `\b` before or after a word character;
- the options `IGNORE_CASE` (or a leading `(?i)`), `LITERAL`, `DOT_MATCHES_ALL` and `UNIX_LINES`.

Not supported (each a compile error that names the construct):

- alternation `|`;
- quantified groups `(ab)+`;
- non-capturing, named, atomic and empty groups;
- lookahead and lookbehind;
- `??`, possessive quantifiers, and lazy `{n,m}?`;
- `\p{...}`, `\B`, `\G`, class intersections `&&`;
- non-ASCII characters in a class or under a quantifier;
- other inline flags, and the options `MULTILINE`, `COMMENTS` and `CANON_EQ`;
- `MatchGroup.range`, and looking up a group by name.

The API:

- `matches`, `containsMatchIn`, `find`, `findAll` (lazy), `matchEntire`, `matchAt`, `matchesAt`;
- `replace` with a replacement string (`$1`) or a transform, `replaceFirst`, `split`, `splitToSequence`;
- the `String` functions that take a `Regex`;
- `MatchResult`: `value`, `range`, `groupValues`, `groups` (values only), `destructured`, `next()`.

`split` and `replace` with a `String` argument search for the plain text, with no pattern.

## Coroutines and sequences

- A `suspend` function compiles to an ordinary Lua function. `suspend fun main` works.
- `block.startCoroutine(completion)` runs `block` in a new Lua coroutine until it first suspends.
- `suspendCoroutine { cont -> }` suspends the coroutine until something calls `cont.resume(x)` or
  `cont.resumeWithException(e)`.
- Contexts, `ContinuationInterceptor` and `kotlin.coroutines.intrinsics` work, so you can write a scheduler in plain
  Kotlin.
- `sequence { }` and `iterator { }` yield at each `yield(x)`. Elements are computed on demand, and infinite generators
  work.
- `kotlinx.coroutines` is not supported.

## Not supported

Each of these is a compile error:

- the unsigned types (`UInt`, `ULong`, `UByte`, `UShort`, their arrays and ranges);
- `java.math`: `BigInteger`, `BigDecimal`;
- `kotlin.time`: `Duration`, `Instant`, `Clock`, `measureTime`, time sources;
- reflection beyond `::class.simpleName` and the `name` of a callable reference (`KClass`, `javaClass`, `typeOf`,
  `qualifiedName`, `KProperty`, `KFunction`);
- the JDK collections and helpers: `TreeMap`, `TreeSet`, `PriorityQueue`, `LinkedList`, `java.util.ArrayDeque`,
  `EnumMap`, `BitSet`, `Collections.*`, `Arrays.*`, streams, `Optional`, `Objects`, the `Comparator` statics;
- the statics of the boxed types (`Integer.toHexString`, `Long.parseLong`, `Character.isDigit`, ...);
- `Math`'s `*Exact` functions, and `StrictMath`;
- `java.util.Locale` and the `Locale` overloads;
- code point and surrogate APIs, and the Unicode character categories;
- the IEEE bit APIs of `Double`/`Float` (`toBits`, `toRawBits`, `fromBits`, `ulp`, `nextUp`, `nextDown`, `nextTowards`);
- `DeepRecursiveFunction`;
- `kotlinx.*` libraries.

When you need one of these, write it in Kotlin, or bind a Lua library with [`@LuaExternal`](lua-interop.md).
