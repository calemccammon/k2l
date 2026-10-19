fun hash(s: String): UInt {
    var h = 2166136261u
    for (c in s) {
        h = h xor c.code.toUInt()
        h = h * 16777619u
    }
    return h
}

fun main() {
    val a = 4000000000u
    val b = 500000000u
    println(a)
    println(a + b)
    println(b - a)
    println(a * 3u)
    println(a * a)
    println(a / 7u)
    println(a % 7u)
    println(a > b)
    println(b < a)
    println(a == 4000000000u)
    println(UInt.MAX_VALUE)
    println(UInt.MIN_VALUE)
    println(0xFFFFFFFFu)
    println(UInt.MAX_VALUE + 1u)
    println("a=$a")
    println(a.toInt())
    println((-1).toUInt())
    println((-1L).toUInt())
    println(5000000000L.toUInt())
    println(a.toLong())
    println(a.toULong())
    println(a.toDouble())
    println(3.7.toUInt())
    println((-3.7).toUInt())
    println(1e20.toUInt())
    println(a shl 1)
    println(a shr 3)
    println(a and 0xF0F0F0F0u)
    println(a or 1u)
    println(a xor 0xFFFFFFFFu)
    println(a.inv())
    println(hash("hello"))
    println(hash("The quick brown fox"))
    var c = 5u
    c--
    c--
    c--
    c--
    c--
    c--
    println(c)
    c += 10u
    println(c)
    for (i in 1u..5u) print("$i ")
    println()
    for (i in 10u downTo 7u) print("$i ")
    println()
    for (i in 0u until 3u) print("$i ")
    println()
    for (i in 0u..10u step 5) print("$i ")
    println()
    println(5u in 1u..10u)
    println(11u in 1u..10u)
    val bytes = 200u.toUByte()
    println(bytes)
    println((bytes + 100u.toUByte()))
    println(bytes.toInt())
    println(300.toUByte())
    println(70000.toUShort())
    println(bytes.toUInt() shl 4)
    val s: UShort = 65535u
    println(s)
    println(s.toInt() + 1)
    println(listOf(3u, 1u, 2u).sorted())
    println(listOf(1u, 2u).map { it * 2u })
    println(maxOf(5u, 9u))
    println(a.toString())
    println(a.toString(16))
    println(uintArrayOf(1u, 2u, 3u).sum())
    val arr = UIntArray(3)
    arr[1] = 7u
    println(arr.toList())
    println(arr[1] + arr[0])
    println(a.compareTo(b))
    println(4294967295u.toInt())
    println(1u.toDouble() / 3)
    println(a.toFloat())
    println(10u.toLong() * 2)
    println(UInt.MAX_VALUE.toULong() + 1u)
    // ULong values below 2^53 are exact on every target
    val x = 9000000000uL
    val y = 7uL
    println(x + y)
    println(x - y)
    println(x * y)
    println(x / y)
    println(x % y)
    println(x > y)
    println(y.compareTo(x))
    println(x.toString() + "!")
    println(x.toUInt())
    println(x.toLong() + 1)
    println(x.toDouble())
    println(x shr 3)
    println(x.inv() > x)
    println(y - 8uL > y)
    for (i in 1uL..3uL) print("$i ")
    println()
    println(sumOfSquares(5u))
}

fun sumOfSquares(n: UInt): UInt {
    var total = 0u
    for (i in 1u..n) total += i * i
    return total
}
