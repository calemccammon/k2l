# Language

Almost all of the Kotlin language compiles to the Lua you would write by hand.

## Supported

| Kotlin | Lua |
|---|---|
| functions, top-level `val`/`var` | `local function`, `local`; public declarations are also in the file's module table |
| `if`, `when`, `try` as expressions; `when` with subjects, ranges and guards | `if` chains, or `a and b or c` where that is safe |
| `for` over ranges, `downTo`, `step`, `until`; `while`, `do`/`while` | numeric `for`, `while`, `repeat` |
| `break`, `continue`, labels | `break` and `goto` (on Lua 5.1: flags) |
| classes, interfaces, `object`, companion objects, `enum class`, `data class`, `sealed` | metatable classes: `Point.new(1, 2)`, `p:distance(q)` |
| data classes | `toString`, `equals` and `hashCode` from one runtime function, `__K2L_DataClass(Point, {"x", "y"})`; `copy` and destructuring read the fields where they are used |
| private members of classes and objects | locals of the file: `local function f(self, a)`, called `f(p, a)`; an object's private properties are locals too |
| inheritance, abstract and open members, `super` calls, interface default methods | the superclass table in the `__index` chain |
| inner, nested, local and anonymous classes (`object : Greeter { }`) | classes; captured locals are upvalues |
| `x?.y`, `x ?: y`, `x!!`, smart casts | `x and x.y`, `x or y` where safe; `!!` throws `NullPointerException` |
| `is`, `as`, `as?` | metatable checks; a failed `as` throws `ClassCastException` |
| lambdas, function references, function types, `fun interface` | Lua closures |
| extension functions and properties | plain functions that take the receiver first |
| default and named arguments | `if x == nil then x = default end` in the callee |
| `vararg` and `*spread` | Lua varargs |
| overloads | `describe`, `describe__1`, ... |
| operator overloading, `get`/`set`/`invoke`/`contains`/`compareTo`, destructuring | method calls; `componentN` |
| `inline fun`, `reified`, non-local `return`/`break`/`continue` from lambdas | expanded at the call site where needed |
| `let`, `apply`, `also`, `run`, `with`, `use`, `buildString`, `buildList`, ... | inlined |
| common collection operations with a lambda literal (`filter`, `map`, ...) | loops |
| generics, variance, type aliases, contracts | erased |
| `lateinit`, `by lazy`, `Delegates.observable`, `by map`, your own `getValue`/`setValue` | fields and small runtime objects |
| interface delegation (`class C(impl: I) : I by impl`) | forwarding methods |
| value classes | a table holding the value (not unboxed) |
| `throw`, `try`/`catch`/`finally` | `error(exception)` and `pcall` |
| `suspend` functions, `sequence { }`, `iterator { }` | Lua coroutines (see [Standard library](library.md#coroutines-and-sequences)) |
| several files and packages | one Lua module per file, linked with `require`; import cycles work. Or [globals](usage.md#global-modules). |

Initialization:

- Objects, companion objects and enum classes are created on first use when their initializer could have visible
  effects, and where they are declared otherwise.
- A file's top-level properties with such initializers are initialized on their first read or write. With
  `--modules global`, at the end of the file.

## Lua targets

| Target | Numbers | Bitwise operations | `goto` |
|---|---|---|---|
| `5.4` (default), `5.3` | 64-bit integers and doubles | native operators | yes |
| `5.2` | doubles only | `bit32` | yes |
| `5.1` | doubles only | plain Lua | no |
| `JIT` (LuaJIT 2.1) | doubles only | the `bit` library | yes |

A program behaves the same on every target except for [numbers](caveats.md#numbers).

On Lua 5.1, which has no `goto`:

- `continue` and labeled jumps use flags.
- A few jumps cannot, such as some `continue`s to an outer loop. They are compile errors with a hint to pick another
  target.
- A `try` that can suspend runs its block in a coroutine of its own.

## Not supported

Each of these is a compile error:

- references to library functions with a `vararg` parameter (`::listOf`), and to library constructors or properties
  k2l does not map (use a lambda);
- delegating (`by`) a library interface other than the collections, `Comparator`, `CharSequence`, `Sequence`,
  `Iterator`, `Comparable`, `Runnable`, `Callable` and function types;
- the unsigned types (`UInt`, `ULong`, `UByte`, `UShort`, their arrays and ranges);
- reflection beyond `::class.simpleName` and the `name` of a callable reference;
- type tests against a primitive array type (`is IntArray`).

The library APIs that are not supported are listed in [Standard library](library.md#not-supported).
