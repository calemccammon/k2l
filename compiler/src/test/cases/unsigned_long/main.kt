fun fnv(s: String): ULong {
    var h = 14695981039346656037uL
    for (c in s) {
        h = h xor c.code.toULong()
        h *= 1099511628211uL
    }
    return h
}

fun main() {
    val max = ULong.MAX_VALUE
    val big = 10000000000000000000uL
    val small = 12345uL
    println(max)
    println(ULong.MIN_VALUE)
    println(big)
    println(big + small)
    println(max + 2uL)
    println(small - big)
    println(big * 3uL)
    println(big / 3uL)
    println(big % 7uL)
    println(max / 10uL)
    println(max % 10uL)
    println(max / big)
    println(big / max)
    println(max / 0x8000000000000000uL)
    println(big > small)
    println(small > big)
    println(big < max)
    println(max >= big)
    println(big <= big)
    println(big.compareTo(small))
    println(small.compareTo(big))
    println(big == 10000000000000000000uL)
    println("big=$big")
    println(big.toString())
    println(big.toLong())
    println(small.toLong())
    println((-1L).toULong())
    println((-1).toULong())
    println(5.toULong())
    println(max.toUInt())
    println(big.toUInt())
    println(max.toInt())
    println(big.toDouble())
    println(max.toDouble())
    println(small.toDouble())
    println(1e19.toULong())
    println(1.8446744073709552e19.toULong())
    println((-5.0).toULong())
    println(3.9.toULong())
    println(max shr 60)
    println(max shl 4)
    println(1uL shl 63)
    println(big and 0xFFFFuL)
    println(small or 0xF0000uL)
    println(max xor 1uL)
    println(max.inv())
    println(small.inv())
    println(fnv("hello"))
    println(fnv("Kotlin to Lua"))
    var counter = 0uL
    counter--
    println(counter)
    counter++
    counter++
    println(counter)
    for (i in 1uL..3uL) print("$i ")
    println()
    println(small.toUInt() + 1u)
    println(maxOf(small, 7uL))
    println(listOf(big, small, max).size)
}
