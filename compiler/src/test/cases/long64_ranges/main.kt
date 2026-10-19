// Loops over Long ranges that end at Long.MAX_VALUE or begin at Long.MIN_VALUE (with long64=emulate)
fun main() {
    val max = Long.MAX_VALUE
    val min = Long.MIN_VALUE
    val big = 5_000_000_000_000_000_000L
    for (i in max - 2..max) print("$i ")
    println()
    for (i in min..min + 2) print("$i ")
    println()
    for (i in max downTo max - 2) print("$i ")
    println()
    for (i in min + 2 downTo min) print("$i ")
    println()
    for (i in max - 10..max step 4L) print("$i ")
    println()
    for (i in min until min + 3) print("$i ")
    println()
    for (i in max until max) print("$i ")
    println("empty")
    for (i in 5L..4L) print("$i ")
    println("empty")
    var firstBig = 0L
    for (i in 1L..max step 1_000_000_000L) {
        if (i * i > big) {
            firstBig = i
            break
        }
    }
    println(firstBig)
    var count = 0
    for (i in 1L..max) {
        if (i > 5) break
        count++
    }
    println(count)
    var last = 0L
    for (i in big - 3..max) {
        last = i
        if (i == big) break
    }
    println(last)
    println(max in max - 1..max)
    println(min !in min + 1..max)
    for (i in 1uL..3uL) print("$i ")
    println()
    for (i in ULong.MAX_VALUE - 2uL..ULong.MAX_VALUE) print("$i ")
    println()
    for (i in ULong.MAX_VALUE downTo ULong.MAX_VALUE - 1uL) print("$i ")
    println()
    // stepped `in` over Long and ULong progressions with values beyond 2^53 and 2^63 (the JVM walks the elements, so
    // they are short)
    val top = ULong.MAX_VALUE
    val half = 1uL shl 63
    println("${top in top - 8uL..top step 2L} ${top - 1uL in top - 8uL..top step 2L} ${half + 3uL in half - 3uL..half + 9uL step 3L}")
    println("${half - 1uL in half + 5uL downTo half - 7uL step 3L} ${top !in top - 9uL until top step 1L} ${half in 1uL..9uL step 2L}")
    println("${max - 2 in max - 10..max step 2L} ${max - 1 in max - 10..max step 2L} ${big + 3 in big + 9 downTo big step 3L}")
    println("${5u in 1u..10u step 2} ${6u in 1u..10u step 2} ${UInt.MAX_VALUE in UInt.MAX_VALUE - 10u..UInt.MAX_VALUE step 5}")
}
