import tools.attempt
import tools.eachIndexedWhile
import tools.fallback
import tools.tally

inline fun <T> firstOr(xs: List<T>, default: T, test: (T) -> Boolean): T {
    for (x in xs) {
        if (test(x)) return x
    }
    return default
}

inline fun twice(action: () -> Unit) {
    action()
    action()
}

inline fun withLog(name: String, block: (Int) -> Int): Int {
    println("start $name")
    val r = block(name.length)
    println("end $name")
    return r
}

fun findBig(xs: List<Int>): String {
    val x = 100
    val found = firstOr(xs, -1) { if (it > 50) return "early $it"; it > 3 }
    return "found $found $x"
}

fun counter(): Int {
    var n = 0
    twice {
        n++
        if (n == 5) return -1
    }
    twice { n += 10 }
    return n
}

fun shadow(): Int {
    val x = 7
    return withLog("abc") { x + it }
}

fun early(flag: Boolean): String {
    val v = withLog("q") {
        if (flag) return "bail"
        it * 2
    }
    return "v=$v"
}

// ---- members, extensions, defaults ----

class Box(val items: MutableList<Int>) {
    var calls = 0

    inline fun each(action: (Int) -> Unit) {
        calls++
        for (i in items) action(i)
    }

    inline fun <R> mapFirst(f: (Int) -> R): R? {
        if (items.isEmpty()) return null
        return f(items[0])
    }
}

inline fun List<Int>.sumUntil(limit: Int, onSkip: (Int) -> Unit = {}): Int {
    var total = 0
    for (v in this) {
        if (total + v > limit) {
            onSkip(v)
            return total
        }
        total += v
    }
    return total
}

fun boxes(): String {
    val b = Box(mutableListOf(3, 4, 5))
    var s = 0
    b.each {
        if (it == 5) return "stopped at $s calls=${b.calls}"
        s += it
    }
    return "done"
}

fun mapFirst(): String {
    val b = Box(mutableListOf(2))
    val r = b.mapFirst { if (it > 1) return "big" else it }
    return "r=$r"
}

fun sumTest(): String {
    val xs = listOf(1, 2, 3, 4, 5)
    var skipped = -1
    val s = xs.sumUntil(7) { skipped = it }
    val t = xs.sumUntil(100) { return "never" }
    val u = xs.sumUntil(3) { return "skip $it" }
    return "$s $skipped $t $u"
}

// ---- passing lambdas along, names that must not be captured ----

inline fun outer(f: () -> Unit) {
    println("outer>")
    inner(f)
    println("<outer")
}

inline fun inner(g: () -> Unit) {
    println(" inner>")
    g()
    println(" <inner")
}

fun nested(): String {
    var log = ""
    outer {
        log += "a"
        outer {
            log += "b"
            if (log.length > 1) return "ret $log"
        }
    }
    return "end $log"
}

inline fun swap(a: Int, b: Int, use: (Int, Int) -> Unit) {
    val t = a
    val u = b
    use(u, t)
}

fun swaps(): String {
    val a = 1
    val b = 2
    var out = ""
    swap(b, a) { x, y ->
        out += "$x,$y;"
        if (x == 99) return "no"
    }
    swap(a, b) { a2, b2 -> out += "$a2,$b2;" }
    val t = 10
    val u = 20
    swap(t, u) { u2, t2 ->
        out += "$u2-$t2;"
        if (t2 < 0) return "neg"
    }
    return out
}

fun hygiene(): Int {
    val t = 5
    val u = 6
    var acc = 0
    swap(u, t) { x, y ->
        acc += x * 10 + y + t + u
        if (acc < 0) return -1
    }
    return acc
}

inline fun loopWith(n: Int, body: (Int) -> Unit) {
    var i = 0
    while (i < n) {
        body(i)
        i++
    }
}

fun loops(): String {
    val i = 100
    var out = ""
    loopWith(4) { k ->
        out += "$k$i "
        if (k == 2) return out + "stop"
    }
    return out
}

// ---- noinline and crossinline ----

inline fun runAll(noinline kept: () -> Unit, crossinline wrapped: () -> Unit, plain: () -> Unit): () -> Unit {
    plain()
    return {
        kept()
        wrapped()
    }
}

fun mixed(): String {
    var s = ""
    val f = runAll({ s += "k" }, { s += "w" }, {
        s += "p"
        if (s == "x") return "x"
    })
    f()
    f()
    return s
}

// ---- try/catch ----

inline fun guarded(f: () -> Unit): String {
    try {
        f()
    } catch (e: Exception) {
        return "caught ${e.message}"
    }
    return "ok"
}

fun guards(mode: Int): String {
    val r = guarded {
        if (mode == 1) return "early"
        if (mode == 2) throw IllegalStateException("two")
    }
    return "r=$r"
}

// ---- inline calls inside larger expressions ----

fun order(xs: List<Int>): String {
    val log = mutableListOf<String>()
    fun note(s: String): Int {
        log += s
        return s.length
    }
    val total = note("a") + firstOr(xs, note("bb")) { note("c"); it > 1 } * note("ddd")
    val flag = xs.isEmpty() || firstOr(xs, 0) { it > 100 } == 0
    return "$total $flag $log"
}

// ---- receivers ----

inline fun String.withBang(f: String.() -> String): String = this.f() + "!"

inline fun <T> T.letIf(cond: Boolean, f: (T) -> T): T = if (cond) f(this) else this

fun receivers(): String {
    val a = "hi".withBang { uppercase() }
    val b = "x".letIf(true) { it + "y" }
    val c = "x".letIf(false) { return "never" }
    return "$a $b $c"
}

// ---- reified type parameters ----

inline fun <reified T> countOf(items: List<Any>): Int {
    var n = 0
    for (i in items) if (i is T) n++
    return n
}

inline fun <reified T> firstOfType(items: List<Any>): T? {
    for (i in items) if (i is T) return i
    return null
}

inline fun <reified T : Any> describe(x: Any): String = if (x is T) "yes" else "no"

inline fun <reified T> castOrNull(x: Any): T? = x as? T

inline fun <reified A, reified B> pairs(items: List<Any>): String = "${countOf<A>(items)}/${countOf<B>(items)}"

open class Animal(val name: String)

class Dog(name: String) : Animal(name)

class Cat(name: String) : Animal(name)

fun reified(): String {
    val items: List<Any> = listOf(Dog("d"), Cat("c"), "s", 4, Dog("e"), true)
    val out = mutableListOf<String>()
    out += countOf<Dog>(items).toString()
    out += countOf<Animal>(items).toString()
    out += countOf<String>(items).toString()
    out += countOf<Int>(items).toString()
    out += countOf<Boolean>(items).toString()
    out += firstOfType<Cat>(items)?.name.toString()
    out += firstOfType<Int>(items).toString()
    out += firstOfType<Boolean>(items).toString()
    out += describe<Dog>(Dog("x"))
    out += describe<Cat>(Dog("x"))
    out += castOrNull<Dog>(Dog("z"))?.name.toString()
    out += castOrNull<Dog>(Cat("z")).toString()
    out += pairs<Animal, String>(items)
    return out.joinToString(",")
}

// ---- other files ----

fun elsewhere(stopAt: String): String {
    val a = attempt(3) { n -> if (n < 2) null else "n=$n" }
    val b = fallback("none") {
        if (a == "never") return "returned early"
        null
    }
    val c = fallback("none") { "given" }
    val d = attempt(3) { n -> if (n == 9) return "nine" else if (n == 2) "two" else null }
    var seen = ""
    eachIndexedWhile(listOf("a", "b", "c", "d")) { i, v ->
        seen += "$i$v"
        if (v == stopAt) return "stopped $seen"
        true
    }
    val counts = tally(listOf("x", "y", "x")) { if (it == "z") return "z!" else it }
    return "$a $b $c $d $seen $counts"
}

// ---- receivers, labels and nesting ----

class Tracker(val name: String) {
    var count = 0
    inline fun visit(n: Int, f: Tracker.(Int) -> Unit) {
        for (i in 0 until n) {
            count++
            this.f(i)
        }
    }

    inline fun apply2(f: (Tracker) -> Int): Int {
        val r = f(this)
        return r + count
    }

    fun id() = name
}

class Client(val label: String) {
    // not inlined: no lambda returns from run
    fun plain(): String {
        var out = ""
        other.visit(2) { i -> out += "$i${this.name};" }
        return out
    }

    val other = Tracker("other")

    fun run(): String {
        var out = ""
        other.visit(3) { i ->
            out += "$i:${this.name}:$label;"
            if (i == 1) return out + "early"
        }
        val x = other.apply2 { t -> if (t.count > 10) return "big"; t.count * 2 + label.length }
        return "$out $x ${other.count}"
    }
}

inline fun <T> T.tap(f: T.() -> Unit): T {
    f()
    return this
}

inline fun mapNotNullFirst(xs: List<String>, f: (String) -> Int?): Int? {
    for (x in xs) {
        val r = f(x)
        if (r != null) return r
    }
    return null
}

fun labeled(xs: List<String>): String {
    val r = mapNotNullFirst(xs) lbl@{
        if (it == "skip") return@lbl null
        if (it == "stop") return "stopped"
        it.length
    }
    return "r=$r"
}

fun chain(): String {
    val sb = StringBuilder()
    val t = Tracker("t").tap { count = 5 }.tap { sb.append(count) }
    return sb.toString() + t.count
}

fun whenUse(n: Int): String {
    val v = when (n) {
        0 -> mapNotNullFirst(listOf("a")) { if (n == 0) return "zero" else 1 }
        else -> mapNotNullFirst(listOf("abc")) { it.length }
    }
    return "v=$v"
}

fun main() {
    println(findBig(listOf(1, 2, 5, 9)))
    println(findBig(listOf(1, 2, 3)))
    println(findBig(listOf(1, 60, 3)))
    println(counter())
    println(shadow())
    println(early(true))
    println(early(false))
    println(boxes())
    println(mapFirst())
    println(sumTest())
    println(nested())
    println(swaps())
    println(hygiene())
    println(loops())
    println(mixed())
    println(receivers())
    println(guards(0))
    println(guards(1))
    println(guards(2))
    println(order(listOf(1, 2, 3)))
    println(order(emptyList()))
    println(reified())
    println(Client("L").run())
    println(Client("L").plain())
    println(labeled(listOf("skip", "abc")))
    println(labeled(listOf("skip", "stop", "abc")))
    println(labeled(emptyList()))
    println(chain())
    println(whenUse(0))
    println(whenUse(1))
    println(elsewhere("c"))
    println(elsewhere("zzz"))
}
