import kotlin.math.PI
import kotlin.math.abs
import kotlin.reflect.KFunction1
import kotlin.reflect.KFunction2
import kotlin.reflect.KProperty0
import kotlin.reflect.KProperty1

fun describe(p: KProperty1<String, Int>, s: String) = "${p.name}(\"$s\") = ${p.get(s)}"

fun read(p: KProperty0<Any?>) = "${p.name} -> ${p.get()}"

fun main() {
    // references to library properties are property references
    val h = "abc"::length
    println(h())
    println(h.get())
    println(h.name)
    val f = String::length
    println(f("abcd"))
    println(f.get("abcde"))
    println(f.name)
    println(listOf("a", "bb").map(String::length))
    println(listOf("a", "bb").map(f))
    println(listOf("aa", "b").sortedBy(String::length))
    println(listOf("aaa", "b").maxBy(String::length))
    val g = List<Int>::size
    println(g.get(listOf(1)))
    println(g.name)
    println(describe(String::length, "four"))
    println(describe(String::lastIndex, "four"))
    println(read("lua"::length))
    println(read(::PI))

    val il = IntArray::size
    println(il(intArrayOf(1, 2, 3)))
    println(il.name)
    println(listOf(intArrayOf(1), intArrayOf()).map(IntArray::size))
    val first = Pair<Int, String>::first
    println(first(1 to "a"))
    println(first.name)
    println(listOf(1 to "x", 2 to "y").map(Pair<Int, String>::second))
    val key = Map.Entry<String, Int>::key
    println(mapOf("k" to 1, "j" to 2).entries.map(key))
    println(key.get(mapOf("z" to 1).entries.first()))
    println(mapOf("a" to 3).entries.map(Map.Entry<String, Int>::value))
    val sb = StringBuilder::length
    println(sb.get(StringBuilder("abcd")))
    println(sb.name)
    val m = mapOf("a" to 1)
    println(m::size.get())
    println((Map<String, Int>::keys)(m))
    println((Collection<Int>::size)(setOf(1, 2)))
    println((Throwable::message)(RuntimeException("boom")))
    val r = 1..3
    println((IntRange::first).get(r))
    println(r::last.get())
    val mx = Int.Companion::MAX_VALUE
    println(mx.name + " " + mx.get() + " " + mx())

    // extension properties of the library
    val li = String::lastIndex
    println(li("abc") + li.get("hello"))
    println(li.name)
    println(listOf("aa", "b").map(String::lastIndex))
    val lli = List<Int>::lastIndex
    println(lli(listOf(1, 2, 3)))
    println(listOf(listOf(1), listOf()).map(List<*>::lastIndex))
    val ind = CharSequence::indices
    println(ind("abc"))
    println(ind.name)
    val bound = "hello"::lastIndex
    println(bound() + bound.get())
    val props: List<KProperty1<String, Int>> = listOf(String::length, String::lastIndex)
    println(props.map { it.name + "=" + it.get("four") })

    // references to library functions
    val up: (String) -> String = String::uppercase
    println(up("abc"))
    println(listOf("a", "b").map(String::uppercase))
    val plus: (Int, Int) -> Int = Int::plus
    println(plus(2, 3))
    println(listOf(1, 2, 3).reduce(Int::plus))
    val xplus: (String) -> String = "x"::plus
    println(xplus("y"))
    val c = listOf(1, 2)::contains
    println(c(2))
    println(listOf(1, 5).filter(listOf(1, 2)::contains))
    val pr: (Any?) -> Unit = ::println
    pr("printed")
    listOf("p", "q").forEach(::println)
    val a: (Int) -> Int = ::abs
    println(a(-3))
    val kup: KFunction1<String, String> = String::uppercase
    println(kup.name + " " + kup("k"))
    val kc = listOf(1, 2)::contains
    println(kc.name + " " + kc(1))
    val kplus: KFunction2<Int, Int, Int> = Int::plus
    println(kplus.name + " " + kplus(1, 2))
    val ka: KFunction1<Double, Double> = ::abs
    println(ka.name + " " + ka(-2.5))
    println(m::isEmpty.name)
}
