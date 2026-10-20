// A local with the name of a top-level function doesn't hide the function from calls in its scope.
fun nullable(x: Int): Int? = if (x > 0) x else null

fun total(xs: List<Int>): Int = xs.sum()

val label = "top"

fun label(n: Int) = "label $n"

fun main() {
    val nullable = nullable(3)
    println(nullable)
    println(nullable(-1))
    val total = total(listOf(1, 2))
    println(total + total(listOf(3)))
    val f = { total: Int -> total(listOf(total, 1)) }
    println(f(4))
    val label = label(1)
    println(label + " " + label(2))
    for (total in 1..2) println(total(listOf(total)))
}
