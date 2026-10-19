// String templates evaluate their entries left to right, also when a later entry is an expanded inline call.
var counter = 0

fun next(): Int = ++counter

inline fun <reified T> count(items: List<Any>): Int {
    counter += 10
    return items.count { it is T }
}

inline fun <T> twice(block: () -> T): T {
    block()
    return block()
}

fun main() {
    val items = listOf(1, "a", 2)
    println("before ${next()} ints ${count<Int>(items)} after ${next()}")
    println("${counter} ${twice { next() }} ${counter}")
    val s = "x" + next() + count<String>(items) + next()
    println(s)
}
