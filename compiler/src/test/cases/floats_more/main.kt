import kotlin.math.*

data class Vec(val x: Float, val y: Float) {
    operator fun plus(o: Vec) = Vec(x + o.x, y + o.y)
    fun length() = sqrt(x * x + y * y)
    fun scaled(k: Float) = Vec(x * k, y * k)
}

fun average(xs: FloatArray): Float {
    var s = 0f
    for (x in xs) s += x
    return s / xs.size
}

fun main() {
    val v = Vec(0.1f, 0.2f) + Vec(0.3f, 0.4f)
    println(v)
    println(v.length())
    println(v.scaled(1f / 3))
    val arr = floatArrayOf(0.1f, 0.7f, 1.3f)
    println(average(arr))
    println(arr.toList())
    val zeros = FloatArray(2)
    println(zeros[0])
    zeros[1] = 2.5f / 3
    println(zeros[1])
    println(abs(-1.1f))
    println(max(1.1f, 2.2f))
    println(min(1.1f, 2.2f))
    println(1.1f.coerceIn(0f, 1f))
    println(2.5f.roundToInt())
    println(3.7f.toLong())
    println(2f.pow(10))
    println(2f.pow(0.5f))
    println(sin(1f))
    println(exp(1f))
    println(ln(10f))
    println(1.1f.compareTo(1.2f))
    println(String.format("%.3f", 1f / 3))
    println("%.1f".format(2.27f))
    val m = mapOf("a" to 0.1f, "b" to 0.2f + 0.1f)
    println(m)
    val p: Float? = 0.7f * 3
    println(p)
    println("p=$p")
    val any: Any = 1f / 7
    println(any)
    println(1_000_000f)
    println(12345678f)
    println(0.001f)
    println(0.0001f)
    val zero = 0f
    println(-zero)
    println(1f / 0)
    println(-1f / 0)
    println((0f / 0).isNaN())
    println(5 % 3f)
    println(-7.5f % 2)
    println(7 / 2f)
    println(16777216f + 1)
    println(0.1f.toDouble() + 0.2f.toDouble())
    println(0.1 + 0.2)
    println(1.1f * 1.1f)
    println(1.1 * 1.1)
    val big = 1e38f * 10
    println(big)
    println(3 * 0.1f)
    println(0.1f * 3 == 0.3f)
    val total = listOf(0.1f, 0.2f, 0.3f).sumOf { (it * 2).toDouble() }
    println(total)
    println(listOf(0.1f, 0.2f, 0.3f).average())
    println(listOf(3.3f, 1.1f).max())
    println(listOf(3.3f, 1.1f).sorted())
    println(Float.MIN_VALUE.toDouble())
    println(100000.0f.toInt())
    println(16777217.0.toFloat())
    println((0.1f).hashCode() == (0.1f).hashCode())
    var count = 0f
    count += 1
    count++
    count -= 0.1f
    count *= 3
    count /= 7
    println(count)
}
