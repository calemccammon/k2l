// Unchecked casts: an erased `x as T` or `x as List<String>` checks nothing, and the JVM throws ClassCastException later,
// where the value meets a concrete type (a variable, a parameter, a member call), not where it meets Any or a type
// parameter (println, a template, ==). A reified `as T` checks at the cast.

@Suppress("UNCHECKED_CAST")
fun <T> unsafeCast(x: Any?): T = x as T

inline fun <reified T> reifiedCast(x: Any?): T = x as T

@Suppress("UNCHECKED_CAST")
fun <T> firstOf(x: Any?): T = (x as List<T>)[0]

class Box<T>(var value: Any?) {
    @Suppress("UNCHECKED_CAST")
    fun get(): T = value as T

    @Suppress("UNCHECKED_CAST")
    val current: T get() = value as T
}

class Slots<T>(vararg values: Any?) {
    private val items = arrayOf(*values)

    @Suppress("UNCHECKED_CAST")
    operator fun get(i: Int): T = items[i] as T
}

// generic code without casts is not checked
class Stack<T> {
    private val items = ArrayList<T>()

    fun push(x: T) = items.add(x)

    fun pop(): T = items.removeAt(items.size - 1)
}

fun returnsString(): String = unsafeCast(5)
fun returnsAny(): Any = unsafeCast<String>(5)
fun takesString(s: String) = "takes $s"
fun takesAny(a: Any?) = "any $a"
fun <T> generic(t: T) = "generic $t"

fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: ClassCastException) {
        println("$label: CCE ${e.message}")
    } catch (e: RuntimeException) {
        println("$label: NPE ${e.message}")
    }
}

fun main() {
    attempt("val typed") { val s: String = unsafeCast(5); "ok" }
    attempt("val inferred") { val s = unsafeCast<String>(5); "ok" }
    attempt("val inferred used") { val s = unsafeCast<String>(5); s }
    attempt("println arg") { println(unsafeCast<String>(5)); "printed" }
    attempt("template") { "${unsafeCast<String>(5)}" }
    attempt("length") { unsafeCast<String>(5).length }
    attempt("concrete param") { takesString(unsafeCast(5)) }
    attempt("any param") { takesAny(unsafeCast<String>(5)) }
    attempt("generic param") { generic(unsafeCast<String>(5)) }
    attempt("return as String") { val f: () -> String = { unsafeCast(5) }; f() }
    attempt("lambda result") { listOf(1).map { unsafeCast<String>(it) } }
    attempt("int") { val i: Int = unsafeCast("x"); i }
    attempt("int plus") { unsafeCast<Int>("x") + 1 }
    attempt("null to String") { val s: String = unsafeCast(null); s }
    attempt("null to String?") { val s: String? = unsafeCast(null); s }
    attempt("reified") { reifiedCast<String>(5) }
    attempt("reified to Any") { val a: Any = reifiedCast<String>(5); a }
    attempt("reified println") { println(reifiedCast<String>(5)); "printed" }
    attempt("reified null") { reifiedCast<String>(null) }
    attempt("reified nullable") { reifiedCast<String?>(null) }
    attempt("reified list") { reifiedCast<List<String>>(listOf(1)) }
    attempt("list cast elem println") { val l = listOf<Any>(1) as List<String>; println(l[0]); "printed" }
    attempt("list cast elem length") { val l = listOf<Any>(1) as List<String>; l[0].length }
    attempt("list cast elem val") { val l = listOf<Any>(1) as List<String>; val s: String = l[0]; s }
    attempt("list cast elem first") { val l = listOf<Any>(1) as List<String>; l.first().length }
    attempt("list cast for") { val l = listOf<Any>(1) as List<String>; var n = 0; for (s in l) n += s.length; n }
    attempt("list cast for print") { val l = listOf<Any>(1) as List<String>; for (s in l) println(s); "done" }
    attempt("firstOf") { firstOf<String>(listOf(1)).length }
    attempt("box") { Box<String>(5).get().length }
    attempt("box val") { val s: String = Box<String>(5).get(); s }
    attempt("map get") { val m = mapOf<String, Any>("a" to 1) as Map<String, String>; m["a"]!!.length }
    attempt("box property") { Box<String>(5).current.uppercase() }
    attempt("if branch") { val s: String = if (true) unsafeCast(5) else "x"; s }
    attempt("if statement") { if (true) unsafeCast<String>(5) else "x"; "unused" }
    attempt("when branch") { val s: String = when (2) { 1 -> "one"; else -> unsafeCast(5) }; s }
    attempt("elvis") { val s: String = unsafeCast<String?>(5) ?: "none"; s }
    attempt("not null") { val s: String = unsafeCast<String?>(5)!!; s }
    attempt("statement") { unsafeCast<String>(5); "unused" }
    attempt("return") { returnsString() }
    attempt("return Any") { returnsAny() }
    attempt("stack") { val st = Stack<String>(); st.push("a"); st.pop().length }
    attempt("if any") { val x: Any = if (true) unsafeCast<String>(5) else "x"; x }
    attempt("if println") { println(if (true) unsafeCast<String>(5) else "x"); "p" }
    attempt("if stmt no else") { if (true) unsafeCast<String>(5); "u" }
    attempt("when stmt") { when (1) { 1 -> unsafeCast<String>(5); else -> "x" }; "u" }
    attempt("elvis any") { val x: Any = unsafeCast<String?>(5) ?: "n"; x }
    attempt("elvis stmt") { unsafeCast<String?>(5) ?: "n"; "u" }
    attempt("notnull stmt") { unsafeCast<String?>(5)!!; "u" }
    attempt("notnull any") { val x: Any = unsafeCast<String?>(5)!!; x }
    attempt("let") { unsafeCast<String>(5).let { it.length } }
    attempt("let print") { unsafeCast<String>(5).let { println(it) }; "u" }
    attempt("also") { unsafeCast<String>(5).also { println(it) }; "u" }
    attempt("operator get") { Slots<String>(1, "b")[0].length }
    attempt("operator get ok") { Slots<String>(1, "b")[1].length }
    attempt("operator get Int") { val n: Int = Slots<Int>("x")[0]; n }
    attempt("compare") { unsafeCast<String>(5) == "5" }
    attempt("is") { unsafeCast<String>(5) is String }
    attempt("string plus") { unsafeCast<String>(5) + "!" }
}
