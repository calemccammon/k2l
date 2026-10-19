// Shift counts use their low 6 bits, shr is arithmetic for every count, hashCode() of a small negative Long is not that of the Int,
// ULong ranges cross 2^63, a zero step is rejected and range objects may have boxed bounds (with long64=emulate)
fun main() {
    val min = Long.MIN_VALUE
    val max = Long.MAX_VALUE
    val big = 5_000_000_000_000_000_000L
    for (n in listOf(0, 1, 31, 32, 33, 62, 63, 64, 65, 127, 128, -1, -63)) {
        println("$n: ${1L shl n} ${min shr n} ${min ushr n} ${-big shr n} ${big ushr n} ${max shl n}")
    }
    println(1L shl 64)
    println(1L shl 65)
    println(min shr 63)
    println(min shr 62)
    println(-1L shr 70)
    println(-2L shr 1)
    println(1L shl 100)
    println((-1L).hashCode())
    println((-2L).hashCode())
    println((-5000000000L).hashCode())
    for (i in 9223372036854775806uL..9223372036854775810uL) print("$i ")
    println()
    try {
        for (i in 1L..5L step 0L) print(i)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    val r = max - 6..max
    println(r)
    println(r.toList())
    println(r.first)
    println(r.last)
    println(max in r)
    println(max - 7 in r)
    println(r.reversed().toList())
    println((r step 3L).toList())
    println((r step 3L).last)
    println(r.count())
    println(r.sum())
    println(r.isEmpty())
    println((max..max - 1).isEmpty())
    println((min until min).toList())
    println((min until min + 3).toList())
    println((max downTo max - 3).toList())
    println((max downTo max - 6 step 3L).toList())
    for (i in r.reversed()) print("$i ")
    println()
}
