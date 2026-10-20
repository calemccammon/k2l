// java.util.EnumMap and EnumSet: ordinal order, the factories, copies and their errors, type tests and class names.
import java.util.EnumMap
import java.util.EnumSet
enum class S { A, B, C, D, E, F, G }
fun main() {
    val m = EnumMap<S, Int>(S::class.java)
    m[S.C] = 3; m[S.A] = 1
    m.merge(S.C, 10, Int::plus)
    println(m)
    println(m.keys)
    println(EnumSet.copyOf(m.keys))
    println(EnumSet.of(S.G, S.B, S.A, S.D, S.E, S.F))
    println(EnumSet.of(S.G))
    val n = EnumSet.noneOf(S::class.java); n.add(S.D)
    println(n to EnumSet.complementOf(n))
    println(EnumSet.allOf(S::class.java))
    println(EnumSet.range(S.B, S.E))
    println(runCatching { EnumSet.range(S.E, S.B) })
    println(runCatching { EnumSet.copyOf(emptyList<S>()) })
    println(runCatching { EnumMap(mapOf<S, Int>()) })
    println(EnumMap(mapOf(S.F to 1, S.A to 2)))
    println(m is EnumMap<*, *>)
    val anyMap: Map<S, Int> = m
    val anySet: Set<S> = n
    println("${anyMap is java.util.TreeMap<*, *>} ${anySet is java.util.TreeSet<*>} ${anySet is java.util.SortedSet<*>} ${anyMap is EnumMap<*, *>}")
    println(n is EnumSet<*>)
    println(n.javaClass.simpleName + " " + m.javaClass.name)
    val e = EnumSet.copyOf(listOf(S.E, S.A))
    println(EnumSet.complementOf(e))
    println(m.entries.map { it.key.ordinal * it.value })
    m.remove(S.A)
    println(m.size.toString() + m.containsKey(S.A))
    val arr = arrayOf(S.B, S.C)
    println(EnumSet.of(S.A, *arr))
}
