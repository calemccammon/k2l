// `x in a..b step s`, `!in`, `downTo`/`until` with a step and `when` branches: a value is in a progression when it is one of
// its elements, so it must be a whole number of steps from the first one and not past the last one.
fun ints(range: IntRange, test: (Int) -> Boolean) = range.filter(test).joinToString(",")

var evaluations = 0

fun traced(n: Int): Int {
    evaluations++
    return n
}

fun t(s: String, n: Int): Int {
    print("$s ")
    return n
}

fun classify(x: Int): String = when (x) {
    in 0..10 step 5 -> "five"
    in 20 downTo 11 step 3 -> "down3"
    !in -10 until 30 step 2 -> "odd"
    else -> "even"
}

fun charKind(c: Char) = when (c) {
    in 'a'..'z' step 2 -> "even letter"
    in 'b'..'z' step 2 -> "odd letter"
    else -> "other"
}

fun main() {
    println(ints(-2..12) { it in 0..10 step 2 })
    println(ints(-2..12) { it in 1..10 step 3 })
    println(ints(-2..12) { it !in 1..10 step 3 })
    println(ints(-2..12) { it in 10 downTo 0 step 3 })
    println(ints(-2..12) { it in 0 until 10 step 4 })
    println(ints(-2..12) { it in 0..<9 step 3 })
    println(ints(-2..12) { it in 5..4 step 1 })
    println(ints(-2..12) { it in 7..7 step 5 })
    println(ints(-2..12) { it in -1 downTo -1 step 2 })

    // the last element is 9, not 10
    println("${9 in 1..10 step 2} ${10 in 1..10 step 2} ${(1..10 step 2).last}")
    println("${4 in 10 downTo 1 step 3} ${1 in 10 downTo 1 step 3} ${0 in 10 downTo 1 step 3}")

    for (x in listOf(0, 5, 10, 14, 17, 21, -3, 25, 26)) print(classify(x) + " ")
    println()

    val lo = traced(3)
    val step = traced(4)
    println(ints(0..20) { it in lo..traced(15) step step })
    println(evaluations)
    // operands are evaluated once each, in order, also when the first comparison fails
    println(t("x", 3) in t("a", 0)..t("b", 9) step t("s", 3))
    println(t("x", -1) in t("a", 0)..t("b", 9) step t("s", 3))
    println(t("x", -1) in t("a", 0)..t("b", 9))
    println(t("x", 12) in t("a", 9) downTo t("b", 0))
    println(t("x", 12) in t("a", 9) downTo t("b", 0) step t("s", 2))

    println("${'e' in 'a'..'z' step 4} ${'f' in 'a'..'z' step 4} ${'y' in 'z' downTo 'a' step 3} ${'w' in 'z' downTo 'a' step 3}")
    println("${charKind('c')} ${charKind('d')} ${charKind('#')}")

    val big = 3_000_000_000L
    println("${big in 0L..4_000_000_000L step 1_000_000_000L} ${big + 1 in 0L..4_000_000_000L step 1_000_000_000L}")
    println("${-6L in 10L downTo -10L step 4L} ${-7L !in 10L downTo -10L step 4L} ${10L in 0L until 10L step 5L}")
    println("${7u in 1u..10u step 3} ${8u !in 1u..10u step 3} ${5uL in 9uL downTo 1uL step 2L} ${4uL in 9uL downTo 1uL step 2L}")
    val longs = (-5L..15L).filter { it in 2L..13L step 5L }
    println(longs)

    for (s in listOf(2, 0, -3)) {
        try {
            println(5 in 1..10 step s)
        } catch (e: IllegalArgumentException) {
            println(e.message)
        }
    }
    try {
        for (i in 0..4 step lo - 3) print(i)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    for (c in 'a'..'k' step 3) print(c)
    for (c in 'k' downTo 'a' step 4) print(c)
    println()
}
