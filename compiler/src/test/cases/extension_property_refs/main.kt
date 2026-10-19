import kotlin.reflect.KMutableProperty1
import kotlin.reflect.KProperty0
import kotlin.reflect.KProperty1

class Box(var items: MutableList<Int>)

val String.lastChar: Char get() = this[length - 1]

val List<Int>.total: Int get() = sum()

var Box.first: Int
    get() = items[0]
    set(value) {
        items[0] = value
    }

val Box.size: Int get() = items.size

fun describe(p: KProperty1<String, Char>, s: String) = "${p.name} of $s is ${p.get(s)}"

fun main() {
    val ref = String::lastChar
    println(ref.name)
    println(ref.get("hello"))
    println(ref("world"))
    println(listOf("ab", "cd", "xyz").map(String::lastChar))
    println(describe(String::lastChar, "kotlin"))

    val bound: KProperty0<Char> = "lua"::lastChar
    println(bound.name)
    println(bound.get())
    println(bound())

    val totals = listOf(listOf(1, 2), listOf(3, 4, 5)).map(List<Int>::total)
    println(totals)

    val box = Box(mutableListOf(7, 8))
    val first: KMutableProperty1<Box, Int> = Box::first
    println(first.get(box))
    first.set(box, 70)
    println(box.items)
    println(first.name)
    val boundFirst = box::first
    boundFirst.set(99)
    println(boundFirst.get())
    println(listOf(box, Box(mutableListOf(1))).map(Box::size))
    println(listOf(box, Box(mutableListOf(1))).sumOf(Box::first))
}
