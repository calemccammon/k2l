var log = ""

fun trace(label: String, value: Int): Int {
    log += label
    return value
}

fun add(a: Int, b: Int, c: Int): Int = a + b + c

fun main() {
    // The middle argument needs statements; the first must still be evaluated first.
    val r = add(trace("a", 1), if (trace("b", 0) > 0) 10 else { log += "!"; 20 }, trace("c", 3))
    println(r)
    println(log)

    var i = 0
    val old = i++
    val new = ++i
    println("$old $new $i")

    log = ""
    val both = trace("x", 0) > 0 && when (trace("y", 1)) { 1 -> true; else -> false }
    println("$both $log")
    log = ""
    val either = trace("x", 1) > 0 || when (trace("y", 1)) { 1 -> true; else -> false }
    println("$either $log")
}
