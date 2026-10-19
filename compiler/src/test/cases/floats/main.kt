import kotlin.math.sqrt

fun main() {
    val a = 1f / 3
    println(a)
    val d = 1.1f
    println(d.toDouble())
    println(listOf(1.5f, a))
    println("v=$a")
    var s = 0f
    for (i in 1..10) s += 0.1f
    println(s)
    println(Float.MAX_VALUE)
    println(Float.MIN_VALUE)
    println(Float.NaN)
    println(Float.POSITIVE_INFINITY)
    println(sqrt(2f))
    println(16777217.toFloat())
    println("3.14159".toFloat())
    println(3.14159.toFloat())
    println(1e10f)
    println(1.0e-5f)
    println(100f)
    println(a.toInt())
    println((a * 100).toInt())
    println(a < 0.34f)
    println(0.1f + 0.2f)
    println(0.1f + 0.2f == 0.3f)
    println(10 / 4f)
    var x = 1.1f
    x++
    println(x)
    println(-a)
    println(a * a * a)
    println(Float.MAX_VALUE * 2)
    println(3.4028235E38f.toDouble())
    val xs = listOf(1.1f, 2.2f, 3.3f)
    println(xs.sum())
    println(xs.map { it * 2 })
    println(a.toString() + "!")
    println(a.toDouble() * 3)
}
