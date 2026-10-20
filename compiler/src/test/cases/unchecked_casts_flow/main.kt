// Unchecked values that flow on before they meet a concrete type: elements passed to the lambdas of library and program
// functions (the JVM checks a lambda's arguments against its parameter types as it starts, used or not), and values stored
// in properties (checked where they are read, like the local they came from).

class Holder(var s: String)
class GHolder<T>(val v: T)
class Box(val items: List<String>)

class Registry {
    private var names: List<String> = emptyList()
    val sorted: Map<String, Int> = mapOf<String, Any>("a" to "x") as Map<String, Int>

    fun load(raw: Any) {
        val l = raw as List<String>
        names = l
    }

    fun total() = names.sumOf { it.length }
    fun first() = names.first()
    fun count() = sorted.values.count { it > 0 }
}

fun <T> List<T>.each(f: (T) -> Unit) {
    for (x in this) f(x)
}

fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: ClassCastException) {
        println("$label: CCE ${e.message}")
    }
}

@Suppress("UNCHECKED_CAST")
fun main() {
    val raw: Any = listOf<Any>(1, "b")
    val l = raw as List<String>
    attempt("map it") { l.map { it } }
    attempt("map length") { l.map { it.length } }
    attempt("map toString") { l.map { it.toString() } }
    attempt("forEach println") { l.forEach { println(it) } }
    attempt("forEach typed") { l.forEach { x: String -> println(x) } }
    attempt("filter true") { l.filter { true } }
    attempt("filter ==") { l.filter { it == "b" } }
    attempt("joinToString") { l.joinToString() }
    attempt("sortedBy") { (listOf<Any>("a", 2) as List<String>).sortedBy { it } }
    attempt("any") { l.any { it.isEmpty() } }
    attempt("associateWith") { l.associateWith { 1 } }
    attempt("mapIndexed") { l.mapIndexed { i, _ -> i } }
    attempt("fold") { l.fold(0) { acc, _ -> acc + 1 } }
    attempt("fold length") { l.fold(0) { acc, s -> acc + s.length } }
    attempt("sequence map") { l.asSequence().map { it }.toList() }
    attempt("sequence map length") { l.asSequence().map { it.length }.toList() }
    attempt("program function") { l.each { println(it) } }
    attempt("chain") { l.filter { it is Any }.map { 0 } }
    attempt("with") { l.forEach { with(it) { println(this) } } }
    attempt("nullable") { (listOf<Any?>(null, 1) as List<String?>).map { it } }
    attempt("ok after filter") { (listOf<Any>("x", "yy") as List<String>).filter { it.length > 1 } }
    attempt("cast index") { (raw as List<String>)[0].length }
    attempt("cast for") { for (s in raw as List<String>) println(s.length) }
    attempt("cast first Any") { (raw as List<String>).first() }
    attempt("field") { Holder((raw as List<String>)[0]) }
    attempt("generic field") { GHolder(l[0]).v }
    attempt("box") { "size ${Box(l).items.size}" }
    attempt("box index") { Box(l).items[0].length }
    attempt("box index Any") { val x: Any = Box(l).items[0]; x }
    attempt("box first") { Box(l).items.first() }
    attempt("box first length") { Box(l).items.first().length }
    attempt("box for") { for (s in Box(l).items) println(s.length) }
    attempt("box map") { Box(l).items.map { it } }
    attempt("generic holder") { (GHolder<Any>(1) as GHolder<String>).v.length }
    attempt("generic holder println") { println((GHolder<Any>(1) as GHolder<String>).v) }
    val registry = Registry()
    registry.load(raw)
    attempt("assigned field") { registry.total() }
    attempt("assigned field first") { registry.first() }
    attempt("cast field") { registry.count() }
}
