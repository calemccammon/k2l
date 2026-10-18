// Compiled with intOverflow=wrap (see options.txt): Int arithmetic wraps to 32 bits like the JVM.
class Counter(var value: Int) {
    fun bump() {
        value++
    }
}

fun hash(s: String): Int {
    var h = 7
    for (c in s) {
        h = 31 * h + c.code
    }
    return h
}

fun mix(a: Int, b: Int): Int = (a * 31 + b) * 1000003 - a

fun id(x: Int): Int = x

fun main() {
    println(hash("hello"))
    println(hash("the quick brown fox jumps over the lazy dog"))
    println(hash("Aa") == hash("BB"))

    val max = id(Int.MAX_VALUE)
    val min = id(Int.MIN_VALUE)
    println(max + 1)
    println(min - 1)
    println(max + max)
    println(min + min)
    println(-min)
    println(-max)
    println(min * -1)
    println(max * max)
    println(max * 2)
    println(min * min)
    println(123456789 * id(987654321))
    println(id(65536) * id(65536))
    println(id(46341) * id(46341))
    println(id(-46341) * id(46341))
    println(mix(max, min))
    println(mix(123456, -654321))

    var i = id(Int.MAX_VALUE)
    i++
    println(i)
    i--
    println(i)
    val before = i++
    println(before)
    println(i)
    var j = id(Int.MIN_VALUE)
    println(--j)
    println(++j)

    var acc = id(1)
    for (k in 1..40) {
        acc *= 3
    }
    println(acc)
    acc += id(2000000000)
    println(acc)
    acc -= id(2000000000)
    acc -= id(2000000000)
    println(acc)

    val c = Counter(Int.MAX_VALUE)
    c.bump()
    println(c.value)
    c.value += 5
    println(c.value)

    val arr = intArrayOf(Int.MAX_VALUE, 1)
    arr[0] += arr[1]
    println(arr[0])

    val l = 5_000_000_000L + id(1)
    println(l.toInt())
    println((l * 3).toInt())
    println(Int.MAX_VALUE.toLong() + 1)
    println(id(7).toLong() * 1000000000L)
    println(3000000000.0.toInt())
    println((-2.5).toInt())
    println(max.plus(1))
    println(max.inc())
    println(min.dec())
    println(min.unaryMinus())
    println(max.times(2))

    val s: Short = 30000
    val t: Short = 30000
    println(s + t)
    var sh: Short = Short.MAX_VALUE
    sh++
    println(sh)
    var by: Byte = Byte.MAX_VALUE
    by++
    println(by)
    println(by + 1)

    println(id(7) / 2)
    println(id(-7) % 3)
    println(Int.MAX_VALUE + 1)
    println(Int.MIN_VALUE - 1)
    println(-Int.MIN_VALUE)
    println(id(1) shl 31)
    println(id(1) shl 31 shr 31)
    println(max xor min)

    var sum = 0
    for (n in 1..100000) {
        sum += n * n
    }
    println(sum)
}
