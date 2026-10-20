# Where the time goes: profile of the benchmark suite

Measured on 2026-10-19 with the compiler at `32a3468` plus the harness (Linux, 16 cores, Lua 5.1.5, 5.2.4, 5.3.6, 5.4.9,
LuaJIT 2.1.1791988261). Reproduce with:

```sh
./gradlew :compiler:bench                                        # timings, compared with baseline.json
./gradlew :compiler:bench -PbenchProfile -PbenchTargets=5.4,JIT,5.1   # reports in compiler/build/bench/profile/<target>/
```

## Baseline (median wall ms of 5 runs, `baseline.json`)

| program | 5.1 | 5.2 | 5.3 | 5.4 | JIT |
|---|---:|---:|---:|---:|---:|
| coll_dijkstra | 1676 | 1471 | 1320 | 1212 | 457 |
| coll_grid | 1822 | 1846 | 1709 | 1384 | 3688 |
| coll_pipeline | 2105 | 1963 | 1811 | 2072 | 986 |
| coll_sort | 1606 | 1614 | 1411 | 1093 | 547 |
| num_bigint | 1861 | 2071 | 1966 | 1354 | 453 |
| num_double | 1303 | 1349 | 1269 | 966 | 26 |
| num_hash_wrap | 14516 | 2155 | 1142 | 784 | 332 |
| num_long | 27030 | 2916 | 556 | 430 | 145 |
| num_long64 | 8951 | 6389 | 660 | 488 | 430 |
| oop_interpreter | 787 | 829 | 780 | 673 | 209 |
| oop_sequences | 967 | 1078 | 928 | 787 | 256 |
| oop_shapes | 989 | 900 | 841 | 732 | 161 |
| str_builder | 797 | 864 | 802 | 702 | 282 |
| str_format | 1167 | 1204 | 1077 | 926 | 550 |
| str_json | 1078 | 1085 | 1084 | 930 | 321 |
| str_parse | 1056 | 1079 | 1107 | 853 | 527 |
| text_utf16 | 1029 | 1081 | 1058 | 919 | 306 |
| geomean | 1931 | 1503 | 1085 | 894 | 347 |

Outliers worth a look on their own: `num_long` and `num_hash_wrap` on 5.1 (27 s and 14.5 s: plain-Lua bitwise operations,
item 1), `num_long64` on 5.1/5.2 (9 s / 6.4 s, emulated 64-bit logic), and `coll_grid` on LuaJIT, the only program where
LuaJIT is slower than 5.4 (3.7 s vs 1.4 s: `Dir.entries` copies a list through a vararg call, item 17, plus closure
allocation that aborts traces, item 5).

## How to read the numbers

- PUC Lua (5.1, 5.4): a count hook every 1000 VM instructions, so percentages are shares of *executed Lua bytecode*. Time
  spent inside C functions (`string.format`, `string.find`/`match`/`gsub`, `table.concat`, `table.sort`, GC) is not seen,
  which under-reports string-heavy code (items 4, 10, 11). The profiler slows programs 3-7x (it walks the stack per sample).
- LuaJIT: `jit.profile` every 1 ms with the JIT on, 10 runs per program (2,000-7,000 samples), including the VM state
  (compiled / interpreted / C / GC). Trace aborts were counted separately with `luajit -jv`.
- "self" is the function on top of the stack; "sites" (in the per-program reports) attribute lualib samples to the nearest
  Kotlin line on the stack. Lualib lines are given as `File.lua:line` of `compiler/src/main/resources/dev/k2l/lualib`.
- Micro-measurements quoted below (`ns/op`) come from a stand-alone Lua script reproducing each pattern (5.4 / 5.1 / JIT).

Share of samples spent in the lualib (the rest is generated program code), 5.4: coll_dijkstra 91%, coll_sort 91%,
num_bigint 98%, str_parse 96%, text_utf16 93%, str_format 87%, coll_pipeline 76%, oop_interpreter 72%, oop_sequences 72%,
coll_grid 72%, num_long64 69%, num_double 66%, str_json 54%, oop_shapes 52%, num_hash_wrap 48%, num_long 37%,
str_builder 36%.

## Ranked opportunities

Estimated impact = how much of the suite's time the item covers (share of samples x number of programs x targets), and
how much of that a fix can plausibly remove. (A) = generated code (`compiler/src/main/kotlin/dev/k2l/transform`,
`codegen`), (B) = lualib (`compiler/src/main/resources/dev/k2l/lualib`).

### 1. (B) Bitwise operations on Lua 5.1 loop over all 32 bits and allocate a closure per call

`Bit.51.lua`:

```lua
local function __K2L_BitOp(a, b, keep)
    a, b = a % 4294967296, b % 4294967296
    local result, bit = 0, 1
    for _ = 1, 32 do
        local x, y = a % 2, b % 2
        if keep(x, y) then result = result + bit end
        a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
    end
    return __K2L_ToInt32(result)
end
local function __K2L_BAnd(a, b) return __K2L_BitOp(a, b, function(x, y) return x == 1 and y == 1 end) end
```

- 5.1: `__K2L_BitOp` + `__K2L_BAnd`/`BXor` = **94% of num_long** (27 s), **93% of num_hash_wrap** (14.5 s), **25% of
  coll_dijkstra** and 3% of coll_grid (HashMap iteration hashes every key with `__K2L_BXor(h, __K2L_Ushr(h, 16))`,
  `Collections.lua` `bucketOf`). Long bitwise ops (`LongBits.lua`: split into halves, then two `__K2L_BAnd`) multiply it.
- Fix: process 4 or 8 bits per step with precomputed tables, as `Long64.l64.lua`'s `logic` already does with 4-bit
  `AND`/`XOR` tables (8 steps instead of 32, no closure); give each operation its own function (no `keep` callback);
  fast paths for masks: `x and (2^k - 1)` is `x % 2^k`, `x ushr n` / `x shr n` are divisions, `x shl n` a multiplication.
  The codegen can also emit those forms directly for constant masks and shift counts (A). Expect 5-10x on the 5.1 numbers
  of num_long / num_hash_wrap, ~25% on 5.1 hash-map iteration.

### 2. (A) `is` checks and `when (sealed)` go through `__K2L_InstanceOf`, a metatable walk per branch

```lua
function Interpreter:eval(e, env)
    if __K2L_InstanceOf(e, Expr.Num) then
        return Value.NumV.new(e.value)
    elseif __K2L_InstanceOf(e, Expr.Str) then
    ...
    elseif __K2L_InstanceOf(e, Expr.Call) then
```

and `InstanceOf.lua` does `type`, `rawget(value, "____name")`, `getmetatable`, then loops over `____super` checking
`rawget(c, "____interfaces")[cls]` - for every branch until one matches. Objects are compared with `__K2L_Equals(s, Shape.Empty)`.

- **oop_interpreter 48% (5.4) / 52% (5.1) / 30% (JIT)**, **oop_shapes 43% / 41% / 28%**, str_json 6%, plus `as` casts
  (`e.components[0] as Position`, 4% of oop_shapes).
- Fix: when the tested class is final (data classes, leaf classes of a sealed hierarchy, any non-open class), emit
  `getmetatable(e) == Expr.Num`; for `object`s `rawequal(s, Shape.Empty)`; for `when (subject)` hoist
  `local ____mt = getmetatable(subject)` once and compare against each branch. For open classes and interfaces keep a
  helper, but give every class a precomputed ancestor set so it is one lookup: `local mt = getmetatable(v)
  return mt ~= nil and mt.____is ~= nil and mt.____is[cls] == true` (built in `__K2L_Class`). A two-branch dispatch went
  from 380 ns to 39 ns (5.4) and 47 ns to 0.6 ns (JIT) in the micro-measurement: most of the 40-50% above.

### 3. (A) Primitive array elements are read and written through `:get()`/`:set()` with bounds checks; `a[i] += x` does both

```lua
function Matrix:times(o)
    ...
                for j = 0, self.n - 1 do
                    local ____object_1 = r.data
                    local ____key_1 = i * self.n + j
                    ____object_1:set(____key_1, ____object_1:get(____key_1) + a * o.data:get(k * self.n + j))
```

(`__K2L_Array:get` checks `index < 0 or index >= self.size`, `__K2L_List:set` calls `self:get(index)` again.)

- **num_double 66% (5.4: Array:get 46%, List:set 20%) / 59% (5.1) / 27% + (JIT)**, num_long 15% (`LongArray`,
  `BooleanArray`), num_hash_wrap 9% (`IntArray`, `CRC_TABLE[...]`), coll_grid 4% (`Array<CharArray>`), str_builder 2%.
- Fix: index the table directly with an inline check: reads of a non-nullable primitive array as
  `(a[i + 1] or __K2L_ArrayOOB(a, i))` (any nil is out of bounds; not for `BooleanArray`, whose `false` needs
  `local v = a[i + 1] if v == nil then ... end`), writes as `if i < 0 or i >= a.size then __K2L_ArrayOOB(a, i) end a[i + 1] = v`,
  and compound assignment evaluating the index and the bounds check once. When the index is the loop variable of
  `for (i in a.indices)` / `0 until a.size` the check can be dropped (the compiler already does this for `for (x in array)`).
  86 ns -> 25 ns per read-modify-write on 5.4 (117 -> 36 on 5.1). num_double should drop by half on PUC Lua.

### 4. (B+A) Comparator chains: `compareBy`/`thenBy` closures, `__K2L_CompareValues`, `__K2L_Compare` with a UTF-8 scan per string comparison

```lua
local function __K2L_CompareBy(...)
    local selectors = {...}
    return function(a, b)
        for _, selector in ipairs(selectors) do
            local c = __K2L_CompareValues(selector(a), selector(b))
    ...
-- Compare.lua
    elseif t == "string" and a ~= b and (a:find("[\240-\244]") or b:find("[\240-\244]")) then
        return utf16Order(a, b)
```

- 5.4 self samples: **coll_sort ~60%** (Compare 30%, Comparators 23%, plus TimSort calling them), **coll_dijkstra ~47%**
  (the `PriorityQueue` comparator `compareBy { it.second }.thenBy { it.first }`), coll_grid ~16%. On LuaJIT coll_sort
  spends 27% of its time in C - the two `string.find` calls per string comparison, which the 5.4 hook cannot see.
  Micro: one generic `compareBy` step costs 150 ns on numbers and 416 ns on strings (5.4), 24 / 246 ns on LuaJIT.
- Fix (B): `__K2L_CompareBy` with one selector as its own closure (no `ipairs`, no vararg table); `__K2L_Compare` for
  strings: compare with `<` first and only take the UTF-16 path when the strings can order differently - that needs a
  supplementary character (lead byte F0-F4) in one string *and* a U+E000-U+FFFF character (lead byte EE-EF) in the
  other, which can be answered once per string from a small cache table instead of two `find` calls per comparison.
  Fix (A): when the selector's static type is `Int`/`Long`/`Double`/`String`/an enum, emit a specialized comparator
  (`__K2L_CompareByNumber(selector)` doing `x < y and -1 or (x > y and 1 or 0)` - 25 ns instead of 150, NaN/-0.0 handled only
  for `Double`), and `sortedBy`/`sortBy` on such keys already go through `sortByKeys` (11% of coll_sort), which can use the
  same fast compare.

### 5. (A) Lambdas of inline collection functions are real closures: allocation per call, and LuaJIT cannot compile closure creation

```lua
function Order:getTotal()
    return self.lines:sumOf(function(it) return it:getTotal() end)
end
...
local skuCounts = list:flatMap(function(it) return it.lines end):groupingBy(function(it) return it.sku end):fold(0, function(acc, line) return acc + line.quantity end)
```

- LuaJIT aborts the trace on every `FNEW` ("NYI: bytecode FNEW"): 122 aborts in str_parse, 94 in oop_sequences, 70 in
  coll_pipeline, 51 in coll_sort, 35 in str_builder, 24 in coll_grid/coll_dijkstra; the VM spends 30-55% of the time
  *interpreted* in coll_dijkstra (54%), oop_shapes (55%), coll_grid (45%), oop_interpreter (42%), coll_pipeline (33%).
  On PUC Lua the same code costs a closure allocation plus an indirect call per element: in coll_pipeline (5.4)
  `Iterable:map`/`sumOf`/`flatMap`/`groupBy`/`ListOfSize` and the lambdas are ~30% of the samples, `Order:getTotal` 12% on JIT.
- Fix: Kotlin's collection functions are `inline`; compile the common ones on `List`/`Array`/ranges to loops at the call
  site (`sumOf`, `map`, `mapIndexed`, `filter`, `count`, `any`, `all`, `none`, `forEach`, `first { }`, `maxOf`, `List(n) { }`,
  `IntArray(n) { }`, `groupBy`), the way `for (x in list)` already compiles to a numeric loop. Even where a lualib call
  remains, a lambda that captures nothing can be hoisted to a chunk-level local so it is created once. This is the single
  biggest LuaJIT item; on PUC Lua expect 10-30% on collection pipelines.

### 6. (A+B) Integer `%` and `/` call `__K2L_IRem`/`__K2L_IDiv`, which use `math.fmod` (a stitched C call on LuaJIT)

```lua
local function gcd(a, b)
    return b == 0 and a or gcd(b, __K2L_IRem(a, b))
end
-- IRem.float.lua (5.1, 5.2, LuaJIT)
    return math.fmod(a, b) + 0
-- generated for a constant divisor
    self.seed = math.fmod(self.seed * 75 + 74, 65537) + 0
    return math.fmod(it, 2) == 0 and __K2L_IDiv(it, 2) or 3 * it + 1
```

- **num_long 18% (5.4) / 36% (JIT)**, coll_pipeline 6% / 12%, oop_shapes 1% / 8-10% (JIT), oop_sequences `IDiv` 6% (5.4),
  plus every `math.fmod(...)` line in generated code (the `Lcg.next` of most programs, 3-8%).
- Fix (A): for a nonzero constant divisor on a value known non-negative (`.size`, `indices`, `0 until n` loop variables,
  results of `%`/`and` with a positive constant), emit Lua's `%` and `//` (`math.floor(a / c)` on float targets); for other
  constant divisors inline `fmod(a, c)` from a chunk-level `local fmod = math.fmod` (no global + field lookup per use).
  Fix (B): LuaJIT does not compile `math.fmod` (the trace stitches out to C: 21 ns per call vs 4 ns for `%` in a loop of
  1e7), so on LuaJIT replace it by compiled arithmetic: `local r = a % b if r ~= 0 and (r < 0) ~= (a < 0) then r = r - b end`
  (exact for the integral doubles an Int/Long holds below 2^53), and `IDiv` by `local q = a / b return q >= 0 and floor(q) or ceil(q)`.

### 7. (B) Hash map lookups: `Map:get` -> `findSlot` re-dispatches on the key type every time; get-then-put patterns look up twice

```lua
local function findSlot(self, key)
    local kind = type(key)
    if (kind == "table" and key.hashCode ~= nil) or kind == "cdata" then
        local bucket = self.____buckets[kind == "cdata" and __K2L_Hash(key) or key:hashCode()]
        ...
    return self.____index[key == nil and NIL_KEY or key]
end
function __K2L_Map:get(key)
    local slot = findSlot(self, key)
    return slot and self.____values[self.____accessOrder and accessed(self, slot) or slot]
```

- 5.4: **coll_pipeline ~35%** (findSlot 14%, Map:get 13%, put 4%, containsKey 3%; mostly `groupingBy { }.fold` and
  `groupBy`), oop_interpreter 11% (`Env.lookup`: `vars[name]` on a `HashMap<String, Value>`), coll_grid ~13% with data
  class keys (findSlot 6%, Equals 3%, `Pos:hashCode` 3%), coll_dijkstra 7%, num_long64 8%.
- Fix (B): a string/number fast path at the top of `Map:get`/`containsKey`/`put`
  (`if type(key) ~= "table" then local slot = self.____index[key] ...`), and `____accessOrder` checked once per map, not per get;
  `Grouping:fold`/`eachCount`/`getOrPut`/`merge` doing one slot lookup instead of `containsKey` + `get` + `put`.
  Fix (A): in data class `equals`/`hashCode` (and `when`) skip `__K2L_Equals` when the static type has its own `equals`
  (call `a:equals(b)` directly), and see item 9 for `hashCode`.

### 8. (B) `HashMap`/`HashSet` iteration re-sorts the whole map by bucket after any insertion

```lua
local function normalize(self)
    ...
    for i = 1, n do
        bucket[i], order[i] = bucketOf(keys[i], capacity), i     -- __K2L_Hash of every key
    end
    local sorted = stableSort(order, n, function(a, b) return bucket[a] < bucket[b] end)
    ...
    reindex(self)                                                 -- rebuilds the lookup tables
```

- Runs on the first iteration after any `put` (`dist.values.sumOf { }` in coll_dijkstra: `stableSort` 7% + its comparator
  3.5% + `__K2L_Hash`; 25% on 5.1 because `bucketOf` uses item 1's `BXor`/`Ushr`), and for every `HashMap` that is built and
  then iterated (groupBy-style code, `toSet()`), each time hashing string keys in Lua (item 9).
- Fix: keep the hash of each slot (computed once at insertion) so `normalize` does not rehash; sort with a key array
  (`sortByKeys`-style, no closure); skip `reindex` when only the order changed by rewriting `____index` in the same pass;
  or keep per-bucket chains incrementally so iteration needs no sort. On float targets the `h ~ (h >>> 16)` of `bucketOf`
  should use the table-based xor of item 1 (only the low `log2(capacity)` bits are needed, so one or two 8-bit steps).

### 9. (B+A) String and data class `hashCode()`: a Lua loop per byte, no caching, plus `__K2L_Hash` on statically typed fields

```lua
-- Hash.lua
        if value:find("[\128-\255]") then return hashUtf8(value) end
        for i = 1, #value do
            h = (31 * h + value:byte(i)) & 0xFFFFFFFF
        end
-- generated data class
function Pos:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.row) + __K2L_Hash(self.col))
end
```

- `__K2L_Hash`: **num_hash_wrap 31% (5.4) / 38% (JIT, of which the `find` line alone is 17%)**, coll_grid 14% (the `Int`
  fields of `Pos`/`State` keys), and the string keys of every `HashMap` iteration (item 8).
- Fix (B): hash strings in chunks (`local b1, b2, b3, b4 = byte(s, i, i + 3)`, `h = (h * 923521 + b1 * 29791 + b2 * 961 +
  b3 * 31 + b4) % 2^32`, exact within 2^53), detect non-ASCII in the same loop instead of a separate `find`, and memoize the
  last few hundred string hashes in a bounded cache (Lua strings are interned, so a lookup is cheap; `Utf16.lua` already has
  such a cache). Fix (A): for a property statically typed `Int`/`Short`/`Byte`/`Char`/`Boolean`/`String`, emit its hash
  directly (`self.row` itself for `Int`), and fold the `__K2L_ToInt32` wrapping of `31 * h + x` into one per hashCode
  (`(31 * h + x) & 0xFFFFFFFF` inline on 5.3/5.4).

### 10. (A) Strings are iterated with `gmatch(".")` and indexed with `__K2L_StringCharAt`; `Char` tests go through patterns

```lua
local function hash(s)
    local h = 0
    for c in s:gmatch(".") do
        h = math.fmod(h * 31 + c:byte(), 1000003)
    end
...
    local c = __K2L_StringCharAt(text, i)            -- bounds check + s:sub(i + 1, i + 1)
    while self.pos < #self.text and __K2L_StringCharAt(self.text, self.pos):match("^%s$") ~= nil do
```

- `for (c in s)`: **str_builder 32% (5.4) / 52% (JIT)**, str_format 11%, num_long64 `fnv64` 12% (JIT); `s[i]`: **str_json
  16%**, str_builder 10%, num_long 3%; `isWhitespace()`/`isDigit()` as `match` patterns: most of `Parser.skip` (9-13% of
  str_json), C time not even counted on PUC Lua.
- Fix: compile `for (c in s)` to `for i = 1, #s do local c = sub(s, i, i)` with `local sub, byte = string.sub, string.byte`
  at chunk level, and to `byte(s, i)` when `c` is only used through `.code`, comparisons with `Char` literals or `in 'a'..'z'`;
  compile `s[i] == 'x'` to `byte(s, i + 1) == 120` (bounds check only when the result is used as a value);
  `Char.isWhitespace()/isDigit()/isLetter()` on ASCII via a 256-entry lookup table in the lualib. Micro (5.4): `gmatch`
  loop 68 ns/char vs 28 ns with `byte`; `charAt(s, i) == ' '` 54 ns vs 28 ns.

### 11. (B) `String.format` re-parses the format per call and finds the shortest digits by trial

```lua
-- Strings.lua formatText, per call and per specifier
        local spec, index, flagText, widthText, precisionText, conv = format:match("^(%%(%d*%$?)([-#+ 0,(<]*)(%d*)%.?(%d*)([a-zA-Z%%]))", percent)
        local flags = { left = flagText:find("-", 1, true) ~= nil, plus = ..., space = ..., zero = ..., comma = ..., paren = ..., alt = ... }
-- convert(): a fresh table of tables per non-numeric specifier
        for _, flag in ipairs({{"alt", "#"}, {"plus", "+"}, {"space", " "}, {"zero", "0"}, {"comma", ","}, {"paren", "("}}) do
-- decimalDigits(), used by %f / %e: up to 16 string.format calls per value
    for precision = 1, 16 do
        s = string.format("%." .. precision .. "e", x)
        if tonumber(s) == x then break end
```

- **str_format 78% (5.4: formatText 37%, convert 13%, decimalDigits 10% of bytecode - most of its cost is the C
  `string.format` calls, invisible to the hook) / 84% on JIT (decimalDigits alone 44%)**; also `toString()` of doubles in
  str_json via `__K2L_DoubleToString` (8% JIT).
- Fix: cache the parsed specifiers per format string (formats are almost always literals; a table keyed by the format
  string), make the flag-name list a chunk-level constant, and in `decimalDigits` start at 15 significant digits
  (`%.14e`, `%.15e`, `%.16e`: 3 tries instead of up to 16) or try `%.17g` and shorten. Expect str_format 2-3x.

### 12. (A+B) Object construction: generic vararg `cls.new(...)` and nested class lookups

```lua
-- Class.lua
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then init(self, ...) end
        return self
    end
-- generated
    return Shape.Circle.new(self.r * k)
    return Value.NumV.new(e.value)
```

- `cls.new` self time 3-5% in coll_grid, oop_shapes, oop_sequences, oop_interpreter, str_json, str_parse, coll_pipeline on
  5.4 (26 points summed over programs), 36 points on JIT (9% of coll_grid); plus the `____init` methods themselves.
- Fix (A): for classes whose constructor only stores its parameters (data classes, most small classes), generate
  `function Pos.new(row, col) return setmetatable({row = row, col = col}, Pos) end` (table constructor sized up front, no
  vararg, no second call: 171 -> 89 ns on 5.4); refer to nested classes through chunk-level locals (`Shape.Circle` ->
  `Shape_Circle`). Fix (B): in the generic `new`, capture `init` when the class is finished instead of looking it up per call.

### 13. (B) BigInteger: base 10^7 limbs and float division in every inner loop

```lua
-- BigInteger.lua, mulMag / divSmall
                local cur = r[k] + ai * b[j] + carry
                carry = floor(cur / B)
                r[k] = cur - carry * B
```

- **num_bigint 98% lualib**: `mulMag` 40%, `divSmall` 24%, `fromNumber` 7%, `make` 5%, `divmodMag` 6% (5.4); on JIT GC 26%.
  The hot site is `result * BigInteger.valueOf(n - i) / BigInteger.valueOf(i + 1)`: a full multiplication by a one-limb
  number and a new BigInteger per `valueOf`.
- Fix: a variant for 5.3/5.4 using integer arithmetic (`cur // B`, `cur % B`) and a larger base (10^9 keeps products below
  2^63; 2^24 or 10^7 on float targets); `mulMag` with a one-limb operand -> `mulSmall`, divide by a one-limb divisor ->
  `divSmall` (already there for some paths); cache `valueOf` for small values like the JDK (-16..16) and avoid `make` for
  intermediate results. Expect 2x+ on num_bigint.

### 14. (B) Regex: continuation-passing matcher allocating closures per step, per-byte class tests, a metatable for input bytes

```lua
-- Regex.lua
        f = function(st, i, k)
            return a(st, i, function(i2) return b(st, i2, k) end)      -- a closure per element per attempt
        end
        local function hasByte(b)
            if bytes[b] then return true end
            for _, r in ipairs(ranges) do ... end
            for _, fn in ipairs(classes) do if fn(b) then return true end end
    local bytes = setmetatable({}, {__index = function(t, i) ... local b = s:byte(i) t[i] = b return b end})
```

- **str_parse 78% (5.4) / 65% (JIT, where GC is 44% of the time)**: `singleStep` closures 16%, `hasByte` 14%, the byte
  `__index` 10%, `compileRep` 9%, `MatchResult:____init` 4-15% (`matchEntire` of the log-line regex).
- Fix: precompute a 256-entry membership table per character class when the regex is compiled (one index per byte instead
  of loops); read input bytes with `byte(s, i)` (no lazy table); build the sequence continuations once at compile time
  (pass the continuation down as data, or compile sequences of single-character matchers into a loop) so matching allocates
  nothing; and for regexes that are plain Lua patterns (`\s+`, `\d+`, literal text, classes without alternation) use
  `string.find`/`gsub` directly.

### 15. (B+A) Long bit counts and bit operations: per-bit loops; double-`Long` masks and shifts split into halves

```lua
-- Bits.lua (5.3/5.4)
function __K2L_Bits.ones64(x)
    local count = 0
    while x ~= 0 do count = count + (x & 1) x = x >> 1 end
-- generated on double targets
        x = __K2L_LBAnd(x, x - 1)
        bits = bits + (popcount(x) + __K2L_LShr(x, 40) + __K2L_LBAnd(x, 4095))
```

- **num_long64 55% (5.4, `Long.bitCount`)**, 20% on JIT (`Long64Ext.l64.lua` `bitCount`, also bit by bit);
  num_long on JIT: `LongBits` split/join/`LBAnd`/`LShr` 35%.
- Fix (B): SWAR popcount (`x - ((x >> 1) & 0x5555...)` ... 5 operations) on integer targets and per 32-bit half with
  `bit`/tables elsewhere; same for `numberOfTrailingZeros`/`numberOfLeadingZeros`. Fix (A): on double-`Long` targets emit
  `x % 4096` for `x and 0xFFF` (any constant `2^k - 1` mask is exact as a floored modulo), `floor(x / 2^40)` for `x shr 40`,
  `x * 2^n` for constant left shifts within range.

### 16. (B) UTF-16 strings: `length` decodes, StringBuilder re-concatenates to measure itself

```lua
-- Utf16.lua: the code units of a string are decoded and cached (256 entries, the cache is dropped when full)
    local function units(s) local c = cache[s] if c == nil then if find(s, "[\128-\255]") then c = decode(s) ...
-- Strings.lua
function __K2L_StringBuilder:getLength()
    return #self:toString()                 -- the utf16 variant decodes the result
end
```

- **text_utf16 56% Utf16 + 12% Unicode + 9% Utf16Case (5.4)**: `decode` 28% - its largest site (13%) is
  `if (sb.length > 300)`, i.e. a StringBuilder measuring itself; `Unicode.lua` `find` (binary search per `isLetter()`) 9%.
- Fix: StringBuilder keeps a running length in code units (count the units of each appended piece; ASCII pieces are `#s`);
  string `length` without building the unit array: `#s - (number of continuation bytes) + (number of 4-byte lead bytes)`,
  both countable with C-speed `gsub` counts or a byte loop, cached as now; an ASCII fast path (`cp < 128`) for the
  `Character` predicates before the range binary search.

### 17. (A+B) `Enum.entries` copies a list on every access (through a vararg call LuaJIT cannot compile)

```lua
function Dir:turnRight()
    return __K2L_EnumValues(Dir):get(math.fmod(self.ordinal + 1, 4))
end
-- EnumValues.lua: a fresh list per call
    return __K2L_ListOf(__K2L_EnumUnpack(values, 1, #values))     -- newList({...}, select("#", ...))
```

- **coll_grid on LuaJIT: `__K2L_ListOf` 25% of samples, 27% GC** (it is the reason LuaJIT is 2.7x slower than 5.4 on this
  program); `Dir.entries.map { p + it }` in `neighbours` on every target.
- Fix: `entries` is a cached immutable `EnumEntries` list in Kotlin; return one cached read-only list per enum class (only
  `values()` must copy), and compile `entries[i]` / `values()[i]` to `Dir.____values[i + 1]` with a bounds check. Copy with
  a numeric loop instead of `unpack` + vararg.

### 18. (B) Sequences: generic iterator plumbing per element

```lua
-- Sequence.lua, generateSequence(seed) { next }
            current = (nextFunction or seedFunction)(current)
            if current ~= nil then return true, current end
```

- **oop_sequences 53% Sequence lualib (5.4)**: the `generateSequence` closure 30%, `count` 6%, `windowed`, `filterIndexed`
  (`filter` is implemented through it) 3% each; on JIT GC 29%.
- Fix: separate iterator closures for the seeded and unseeded forms (no `or` per step), `filter` without the index wrapper,
  and terminal operations (`count`, `sum`, `maxBy`, `toList`) that drive a known source sequence with a plain loop instead
  of the generic `iter()` protocol. Codegen (A) can turn `asSequence().map { }.filter { }.count()` chains on a range or list
  into one loop, as with item 5.

### 19. (B) StringBuilder appends and `toString`

```lua
function __K2L_StringBuilder:append(text)
    self.____parts[#self.____parts + 1] = text
    return self
end
```

- str_builder 11% (5.4) / 9% (JIT) + `toString` 5% (JIT), str_json 9-10%, text_utf16 1-3%. `length`, `isEmpty()`,
  `last()`, `get(i)` call `toString()` (a `table.concat`) - quadratic for `buildString { ... if (isNotEmpty() && last() != '-') ... }`
  patterns (`slugify` in text_utf16).
- Fix: keep the part count and total length in fields (`self.____n`, `self.____len`) so `append` does no `#` and
  `length`/`isEmpty` do no concatenation; `last()`/`get(i)` can look at the last part first.

### 20. (A) Repeated global and table lookups, and per-iteration bookkeeping, in generated code

```lua
    self.seed = math.fmod(self.seed * 75 + 74, 65537)       -- global `math` + field per call
    return math.pi * self.r * self.r
    return math.sqrt(s * (s - self.a) * (s - self.b) * (s - self.c))
    for ____i = 1, ____list.size do
        local n = ____list[____i]
        ...
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then break end
```

- Spread thin: `Lcg.next` (3-11% of every program that uses it, 11% of coll_pipeline on 5.4), the math-heavy loops of
  num_double/oop_shapes, the comodification test in every `for (x in list)` body.
- Fix: one `local fmod, floor, sqrt, pi = math.fmod, math.floor, math.sqrt, math.pi` (only the names used) at chunk
  level; nested class tables cached in locals; skip the comodification check when the loop body provably does not
  structurally modify the list (no calls, or only calls to known pure functions/getters).

### 21. (B) `--int-overflow wrap` and Int multiplication on LuaJIT go through function calls

```lua
        hashes = __K2L_ToInt32(hashes + __K2L_IMul(__K2L_Hash("key" .. i), __K2L_BOr(i, 1)))
-- ToInt32.float.lua
    x = x % 4294967296
    if x >= 2147483648 then return x - 4294967296 end
```

- num_hash_wrap on JIT: `__K2L_ToInt32` 15%, `__K2L_IMul` 6% (5.4 inlines the wrap as `(x + 0x80000000 & 0xFFFFFFFF) - 0x80000000`).
- Fix (A, LuaJIT target): emit `tobit(x)` from `local tobit = bit.tobit` (exact for |x| < 2^51, which covers the sum or
  difference of two Ints) instead of `__K2L_ToInt32`; for `IMul` split one operand into 16-bit halves inline or use
  `tobit` on the two partial products.

### 22. (B) Emulated 64-bit Long on LuaJIT normalizes every result

```lua
-- Long64.l64jit.lua
    return norm((a + 0LL) / b)          -- int64 cdata -> back to a double when it fits
```

- num_long64 on JIT: `norm` 12%, `div`/`rem` 18%, `bor`/`bxor` 11%, GC 19%; on 5.1 (`Long64.l64.lua`, 4-bit tables)
  `logic` is 49% of num_long64 (9 s); 5.2 already uses `bit32` for the halves and still takes 6.4 s (not profiled: the
  split into 32-bit halves and the multiplication/division emulation are the suspects).
- Fix: on LuaJIT keep values as int64 cdata through a chain of Long operations and normalize only at boundaries (storage
  into fields/collections, comparisons, `toString`), which the codegen knows; on 5.1 use 8-bit tables (item 1); profile
  5.2 (`-PbenchProfile -PbenchTargets=5.2 -PbenchOnly=num_long64`) before changing the emulation itself.

## Smaller observations

- `Pair` allocation for destructuring `val (u, d) = queue.poll()` and `listOf(...)` of moves inside loops (coll_grid:
  `cls.new` 6% at `val moves = listOf(...)` on JIT) - allocation-heavy idioms that are cheap on the JVM.
- `IntArray(n)`/`List(n) { }` initialisation (`__K2L_ListOfSize`) tests `type(init) == "function"` per element.
- Methods map to the Kotlin class line in some source maps (`function Interpreter:eval` maps to the statement before it);
  the profiler uses the first body line instead.
- Not profiled: Lua 5.2 and 5.3 (their profiles follow 5.1 and 5.4 respectively, except that 5.2 has `bit32`).
- Two transpiler gaps met while writing the suite (worked around in the programs): iterating a `CharSequence` parameter
  (`for (c in s)` with `s: CharSequence`) is "not supported yet"; and string lengths with non-ASCII text differ in the
  default `--strings bytes` mode, as documented.

## Round 2

### Round 2: generated code (profile of `1c6b0f0`, all five targets)

Profiled on 2026-10-20 at `1c6b0f0` (round 1 merged) on 5.1, 5.2, 5.3, 5.4 and LuaJIT
(`-PbenchProfile -PbenchTargets=5.1,5.2,5.3,5.4,JIT`). 5.2 and 5.3 had not been profiled before; the profiler now names
chunks compiled with `load` (BigInteger on 5.3/5.4) instead of writing their source text into the samples file.
5.2 follows 5.1 except where `bit32` helps, 5.3 follows 5.4 except for `IRem`. What was left in generated code, by
share of samples (5.1 / 5.2 / 5.3 / 5.4 / JIT where they differ):

1. `compareBy { }.thenBy { }` chains: `__K2L_CompareValues` plus the `CompareBy`/`ThenBy` closures, 45-60% of
   coll_dijkstra and coll_sort, 12-16% of coll_grid on every PUC target (6-17% on JIT).
2. `a % b` with a variable divisor through `__K2L_IRem`: **num_long 30% on 5.3** (`gcd`), 23% on 5.4, coll_pipeline
   8-10% (`Lcg.next`) and oop_shapes 4% everywhere, 15% of num_long on JIT (where IRem is already compiled `%`).
3. Strings read a Char at a time: `for (c in s)` with `c.code` (str_builder `hash` 38%, str_format 20%), `s[i]` with
   `isWhitespace()`/`isDigit()` as `match` patterns (str_json `Parser.skip` 18-20%, oop_interpreter `Lexer` 10%), and
   `s[i] == 'x'` as one-character strings.
4. `List(n) { }`: `__K2L_ListOfSize` calling a closure per element, **40 points summed on JIT** (coll_pipeline 15%,
   oop_shapes 12%), a few % on PUC Lua.
5. Array reads round 1 left as `:get()`: an index with `xor`/`or`/shifts (`CRC_TABLE[(crc xor b) and 0xFF]`,
   num_hash_wrap 8% on 5.4) and `Array<CharArray>` (coll_grid 4%).
6. Data class `hashCode` hashing a data class field with `__K2L_Hash` (coll_grid `State`, 6%).
7. Smaller: `is`/`as`/`catch` against open classes and interfaces (`__K2L_InstanceOf`) at most 2-3% (oop_interpreter's
   `catch (e: LangException)`, oop_shapes' `as Health`); the per-iteration comodification check, ~6% of oop_shapes on
   JIT (`for (c in e.components)` calling a virtual `update`, which no local analysis can clear); nested class lookups
   (`Shape.Circle.new`) about 1%.

The rest is lualib (Long64 emulation is 85% of num_long64 on 5.2, `__K2L_UAnd32`/`LongBits` most of num_long and
num_hash_wrap on 5.1/5.2, `List.contains` of strings through `__K2L_Equals` 10-12% of oop_interpreter on 5.2/5.3).

What was done (paired, alternating runs of the old and new generated code, median ms, 7 runs; ratio < 1 is faster):

- Items 1: `compareBy`/`compareByDescending`/`thenBy`/`thenByDescending` with lambda selectors compile to one function
  with the selector bodies inlined; Int keys compare with `<`, other keys with `__K2L_CompareValues`. When it captures
  nothing it is created once at chunk level. coll_dijkstra 921 -> 625 (5.1), 987 -> 641, 815 -> 551, 697 -> 484,
  177 -> 180 (JIT); coll_sort 974 -> 792, 979 -> 785, 829 -> 681, 668 -> 552, 231 -> 205.
- Item 2: `b ~= 0 and fmod(a, b) + 0 or __K2L_IRem(a, b)` with `fmod` a runtime local (not on LuaJIT). num_long
  3197 -> 3173, 1856 -> 1812, 508 -> 437, 342 -> 325; coll_pipeline 1309 -> 1225 (5.1), others within noise.
- Item 3: Char tests in bytes mode index tables built from the same patterns (`CharClasses.lua`); `for (c in s)` reads
  `byte(s, i)` when the body only uses `c.code` and comparisons with ASCII literals; `s[i] == 'x'` compares bytes.
  str_builder 717 -> 572, 746 -> 599, 749 -> 603, 635 -> 502, 206 -> 213; str_json 951 -> 901, 963 -> 921,
  949 -> 917, 935 -> 904, 280 -> 256; str_format 579 -> 534, 587 -> 558, 557 -> 513, 471 -> 422.
- Item 4: `List(n) { }` with a lambda literal is a loop with the lambda inlined, wrapped with `__K2L_ListWrap`.
  coll_pipeline on JIT 444 -> 399.
- Item 5: bitwise operators count as pure index reads; `Array<T>` of non-null numbers, Chars, Strings, arrays and
  program classes is read and written inline like the primitive arrays. num_hash_wrap 476 -> 451 (5.4).
- Item 6: data class fields typed as a data class of the program hash with their own `hashCode()`. coll_grid
  752 -> 741, 794 -> 774, 745 -> 728, 613 -> 591, 178 -> 172 (this change alone).

All together, paired against `1c6b0f0`: geomean 0.93 (5.1), 0.93 (5.2), 0.92 (5.3), 0.92 (5.4), 0.98 (JIT).
Not done (item 7): open-class `is` (needs every subclass, which other modules may add), dropping the comodification
check across virtual calls, nested class locals, and keeping int64 cdata through chains on LuaJIT `--long64 emulate`
(num_long64 there is `norm`/`bxor` in `Long64.l64jit.lua`, mostly lualib work).

### Round 2: lualib

Profiled on 2026-10-20 at `1c6b0f0` (main after PR #13) on all five targets, 5.2 and 5.3 for the first time
(`-PbenchProfile -PbenchTargets=5.1,5.2,5.3,5.4,JIT`). `profiler.lua` now names a chunk compiled with `load` from a string
`=[string]`: its source is its code, whose tabs and newlines broke the records (the 5.3 and 5.4 runs of num_bigint failed).

Hottest lualib functions after round 1 (sum of self % over the programs, 5.4 / 5.1 / JIT where it differs):

- `__K2L_CompareValues` and the `compareBy`/`thenBy` closures (60 / 58 / 20 + 33 / 32): coll_sort, coll_dijkstra, coll_grid.
  Already a single fast path; what is left is the call per comparison.
- BigInteger `mulSmall`/`divSmall`/`make` (52 / 53 / 62): the `binomial` loop multiplies and divides by one-limb numbers.
- `__K2L_IRem` (41 on 5.4, 49 on 5.3): calls from generated code (A).
- `findSlot`/`Map:get`/`addSlot` (64 / 45 / 43): hash map lookups, mostly with data class or Long keys.
- 5.1 and 5.2 only: `__K2L_UAnd32` (109 on 5.1) and the emulated Long (`uparts`/`makeU`/`mulp`/`parts`, 60 on 5.2):
  num_long64 6.4 s / 5.1 s, num_long 3.2 s / 1.9 s. 5.2 has `bit32`, so its cost was the calls splitting and joining the
  halves, not the logic.
- `generateSequence` closure (36 / 30 / 13): `collatz(it).count()` in oop_sequences.
- `hashString` (28 on 5.4, 44 on JIT): the `find(s, "[\128-\255]")` before the loop, a C call LuaJIT cannot compile.
- Regex `compileRep`/`singleStep`/`stepRun`/`MatchResult` (52 / 49 / 60 of str_parse): 13 MatchGroups and IntRanges made
  per `matchEntire`, a table of positions per repetition, a closure per group attempt.
- JIT only: `__K2L_ListOfSize` (46: `List(n) { }`, a growing table), `decimalDigits` (28 of str_format), `units` (12 of
  text_utf16: `last()` of a growing StringBuilder decoded every new string), `__K2L_Num.toRadix` (15).
- `Utf16.decode` (20 / 19 / 10 of text_utf16), `StringBuilder:append` (24 / 21 / 27) and `cls.new` (16 / 17 / 27) are
  still there; nothing tried on them gave a measurable gain (see below).

PR #13 cost: `__K2L_DeepPcall` is 1.7% self of oop_interpreter on 5.4 (plain `pcall` on 5.1 and LuaJIT). Paired runs of
the PR #12 build against main, 21 runs: oop_interpreter +1-2% on PUC Lua and +5% on LuaJIT; on LuaJIT the PR #12
Collections.lua alone takes the 5% back (the live-entry bookkeeping in `put`/`removeSlot`/`normalize` is the only
change on that program's path; not pinned down further). Other programs: within noise.

How the changes below were measured: both builds side by side, run alternately (A B, B A, ...) pinned to one core, CPU time
of the child (user + system), 9-31 runs, comparing medians and minimums; a change was kept only when both moved. Risky
rewrites were checked against the old bundle with random inputs (BigInteger operations, emulated Long and Int bit
operations, String.format of doubles, toString(radix), random regexes on random strings): identical output.

| change | program | 5.1 | 5.2 | 5.3 | 5.4 | JIT |
|---|---|---|---|---|---|---|
| BigInteger: base 10^9 limbs with integers (5.3+), `%` instead of `floor` calls (5.1/5.2) | num_bigint | 1370 -> 1269 | 1442 -> 1281 | 1198 -> 1100 | 935 -> 861 | = |
| `List(n) { }`: one loop per kind of init; `table.new` for lists of known size (JIT) | oop_shapes / coll_pipeline | | | | = | 87 -> 83 / 424 -> 412 |
| `hashString`: non-ASCII test in the byte loop, no `find` | num_hash_wrap | 1711 -> 1665 | | | 472 -> 419 | 185 -> 146 |
| Utf16 `first()`/`last()` of a string starting/ending in ASCII without decoding it | text_utf16 | 970 -> 948 | | | 878 -> 862 | 327 -> 287 |
| String.format: lowercase conversion, its kind and the first numeric-only flag parsed once | str_format | | 797 -> 733 | | 524 -> 512 | 271 -> 248 |
| Regex: MatchResult's range, groupValues, groups, destructured made when first read | str_parse | | 898 -> 862 (min) | | 659 -> 625 (min) | 425 -> 381 (min) |
| Regex: greedy repetition of one-byte steps without a positions table | str_parse | 824 -> 768 | | | 603 -> 573 | 358 -> 324 |
| Regex: group of single steps / of a greedy repetition without a continuation closure | str_parse | 746 -> 713 | | | 567 -> 539 | 308 -> 283 |
| `generateSequence(seed) { }.count()` in a plain loop | oop_sequences | 869 -> 795 | | | 586 -> 517 | 219 -> 213 |
| `joinToString`: one `table.concat` with the separator, no `__K2L_Str` call for strings | str_builder / coll_sort | | | | 634 -> 616 / 636 -> 611 | 207 -> 202 |
| Long64 (5.1/5.2): and/or/xor/shifts/mul/add split and join the halves in place (three commits, summed) | num_long64 | 5679 -> 5055 | 5633 -> 4167 | | | |
| LongBits: Long and/or/xor split and join in place | num_long | 3146 -> 2868 | 1790 -> 1456 | | | = |
| Bit (5.1): and/or/xor do UAnd32's table steps in place; Long64 xor/or from new `__K2L_UXor32`/`__K2L_UOr32` | num_long / num_long64 / num_hash_wrap | 3164 -> 2725 / 5560 -> 4892 / 1589 -> 1523 | | | | |
| `toString(16)`/`toString(8)` of magnitudes below 2^53 with `string.format` | str_format | | 547 -> 521 | | 438 -> 421 | 187 -> 175 |
| `decimalDigits`: digits and exponent cut from the `%e` text by position | str_format | 519 -> 512 | | | 421 -> 416 | 176 -> 160 |

(ms, paired medians unless marked; "=" means measured and unchanged; blank: not measured on its own, the code is shared
or does not run there.) Main against the end of the round, all 85 cells, 5 paired runs each: geomean 0.955 (5.1),
0.944 (5.2), 0.956 (5.3), 0.957 (5.4), 0.934 (JIT); largest: str_parse 0.72-0.86, num_long64 0.83/0.88 (5.2/5.1),
num_long 0.82/0.86, str_format 0.84-0.92, num_hash_wrap 0.78 (JIT), oop_sequences 0.88-0.91 on PUC Lua.

Tried and reverted (no measurable gain): a string/number fast path at the top of `Map:get`/`put`/`containsKey` and a
numeric loop over a hash bucket (0.99-1.00 on oop_interpreter, coll_pipeline, coll_grid); a two-generation Utf16 unit
cache instead of dropping it when full (1.00-1.02); `Utf16.decode` four ASCII bytes per step (0.99 on PUC, 1.01 on JIT);
`local floor` in the PriorityQueue sifts; one field read less in `StringBuilder:append` (0.99-1.00); an unrolled bit count
for the emulated Long (LuaJIT bimodal, 0.99 on 5.2); a number fast path in the `compareBy`/`thenBy` closures (1.00-1.04).
The `%`-instead-of-`floor` BigInteger loops are 4.5% slower on LuaJIT, where `floor` compiles to one instruction, so
LuaJIT keeps the `floor` versions.

Left for later: the StringBuilder length in bytes mode (no benchmark program measures itself), the emulated Long on
LuaJIT (`norm` 22% of num_long64, trace aborts "loop unroll limit reached" in `div`/`ushr`: keeping cdata through a chain
needs the codegen), and a regex sequence whose items run without continuation closures.
