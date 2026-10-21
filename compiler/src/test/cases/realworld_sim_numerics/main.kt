import java.math.BigDecimal
import java.math.RoundingMode
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.sin
import kotlin.math.sqrt

// Numerical methods with their results printed in full (Double.toString's shortest repr):
// root finding, quadrature, ODE integration, linear algebra and series, plus BigDecimal views.

fun newton(f: (Double) -> Double, df: (Double) -> Double, x0: Double, tol: Double = 1e-15): Pair<Double, Int> {
    var x = x0
    for (i in 1..100) {
        val step = f(x) / df(x)
        x -= step
        if (abs(step) <= tol * abs(x)) return x to i
    }
    return x to 100
}

fun bisect(f: (Double) -> Double, lo0: Double, hi0: Double): Double {
    var lo = lo0
    var hi = hi0
    repeat(200) {
        val mid = (lo + hi) / 2
        if (mid == lo || mid == hi) return mid
        if ((f(mid) < 0) == (f(lo) < 0)) lo = mid else hi = mid
    }
    return (lo + hi) / 2
}

fun simpson(f: (Double) -> Double, a: Double, b: Double, n: Int): Double {
    val h = (b - a) / n
    var sum = f(a) + f(b)
    for (i in 1 until n) sum += f(a + i * h) * if (i % 2 == 1) 4 else 2
    return sum * h / 3
}

fun rk4(f: (Double, Double) -> Double, y0: Double, t1: Double, steps: Int): Double {
    val h = t1 / steps
    var y = y0
    var t = 0.0
    repeat(steps) {
        val k1 = f(t, y)
        val k2 = f(t + h / 2, y + h * k1 / 2)
        val k3 = f(t + h / 2, y + h * k2 / 2)
        val k4 = f(t + h, y + h * k3)
        y += h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        t += h
    }
    return y
}

class Matrix(val rows: Int, val cols: Int, init: (Int, Int) -> Double = { _, _ -> 0.0 }) {
    val data = Array(rows) { r -> DoubleArray(cols) { c -> init(r, c) } }

    operator fun get(r: Int, c: Int) = data[r][c]

    operator fun times(o: Matrix): Matrix {
        require(cols == o.rows) { "shape mismatch: ${rows}x$cols * ${o.rows}x${o.cols}" }
        return Matrix(rows, o.cols) { r, c -> (0 until cols).sumOf { data[r][it] * o.data[it][c] } }
    }

    fun transpose() = Matrix(cols, rows) { r, c -> data[c][r] }

    override fun toString() = data.joinToString("\n") { row -> row.joinToString(" ") { "%10.5f".format(it) } }

    companion object {
        fun identity(n: Int) = Matrix(n, n) { r, c -> if (r == c) 1.0 else 0.0 }
    }
}

// Gaussian elimination with partial pivoting; returns the solution and the determinant.
fun solve(a: Matrix, b: DoubleArray): Pair<DoubleArray, Double> {
    val n = a.rows
    val m = Array(n) { r -> DoubleArray(n + 1) { c -> if (c < n) a[r, c] else b[r] } }
    var det = 1.0
    for (col in 0 until n) {
        val pivot = (col until n).maxBy { abs(m[it][col]) }
        if (abs(m[pivot][col]) < 1e-12) throw ArithmeticException("singular matrix at column $col")
        if (pivot != col) {
            val t = m[pivot]
            m[pivot] = m[col]
            m[col] = t
            det = -det
        }
        det *= m[col][col]
        for (r in col + 1 until n) {
            val factor = m[r][col] / m[col][col]
            for (c in col..n) m[r][c] -= factor * m[col][c]
        }
    }
    val x = DoubleArray(n)
    for (r in n - 1 downTo 0) {
        var s = m[r][n]
        for (c in r + 1 until n) s -= m[r][c] * x[c]
        x[r] = s / m[r][r]
    }
    return x to det
}

fun main() {
    println("-- roots")
    val (sqrt2, iterations) = newton({ it * it - 2 }, { 2 * it }, 1.0)
    println("sqrt(2) = $sqrt2 in $iterations steps, exact ${sqrt2 == sqrt(2.0)}")
    val (cubeRoot, _) = newton({ it * it * it - 10 }, { 3 * it * it }, 2.0)
    println("cbrt(10) = $cubeRoot vs ${Math.cbrt(10.0)}")
    val dottie = bisect({ cos(it) - it }, 0.0, 1.0)
    println("dottie number = $dottie")
    val (lnRoot, _) = newton({ exp(it) - 3 }, { exp(it) }, 1.0)
    println("ln(3) = $lnRoot vs ${ln(3.0)}")

    println("-- integrals")
    for (n in listOf(2, 10, 100, 1000)) println("sin 0..pi n=$n: ${simpson(::sin, 0.0, PI, n)}")
    val gauss = simpson({ exp(-it * it) }, -6.0, 6.0, 600)
    println("gaussian ${gauss} sqrt(pi) ${sqrt(PI)} diff ${abs(gauss - sqrt(PI))}")
    println("1/x 1..e: ${simpson({ 1 / it }, 1.0, Math.E, 64)}")

    println("-- ode")
    for (steps in listOf(1, 10, 100)) println("y'=y, y(1) with $steps steps: ${rk4({ _, y -> y }, 1.0, 1.0, steps)}")
    println("y'=-2ty: ${rk4({ t, y -> -2 * t * y }, 1.0, 2.0, 200)} exact ${exp(-4.0)}")

    println("-- linear algebra")
    val a = Matrix(3, 3) { r, c -> doubleArrayOf(2.0, 1.0, -1.0, -3.0, -1.0, 2.0, -2.0, 1.0, 2.0)[r * 3 + c] }
    val (x, det) = solve(a, doubleArrayOf(8.0, -11.0, -3.0))
    println("x = ${x.toList()} det = $det")
    val hilbert = Matrix(5, 5) { r, c -> 1.0 / (r + c + 1) }
    val (hx, hdet) = solve(hilbert, DoubleArray(5) { 1.0 })
    println("hilbert solution ${hx.map { "%.6f".format(it) }} det $hdet")
    val rot = Matrix(2, 2) { r, c -> if (r == c) cos(PI / 6) else if (r == 0) -sin(PI / 6) else sin(PI / 6) }
    var power = Matrix.identity(2)
    repeat(12) { power = power * rot }
    println("rotation^12 =\n$power")
    println("A * A^T =\n${a * a.transpose()}")
    try {
        solve(Matrix(2, 2) { r, c -> (r + 1.0) * (c + 1.0) }, doubleArrayOf(1.0, 2.0))
    } catch (e: ArithmeticException) {
        println(e.message)
    }
    try {
        a * Matrix(2, 2)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }

    println("-- series")
    var leibniz = 0.0
    for (k in 0 until 100000) leibniz += (if (k % 2 == 0) 1.0 else -1.0) / (2 * k + 1)
    println("leibniz pi ${leibniz * 4}")
    var e = 1.0
    var term = 1.0
    for (k in 1..20) {
        term /= k
        e += term
    }
    println("e series $e vs ${Math.E} equal ${e == Math.E}")
    var harmonic = 0.0
    for (k in 1..1000) harmonic += 1.0 / k
    println("H(1000) = $harmonic, minus ln = ${harmonic - ln(1000.0)}")
    println("doubles: ${listOf(0.1 * 3, 1.0 / 3, 2.0 / 3, 100.0 / 7, 1e-7, 123456789012.0, 1.0e21, 5e-324, 4.35, 0.3 - 0.1)}")

    println("-- big decimal")
    println(0.1.toBigDecimal())
    println(BigDecimal(0.1))
    println(sqrt2.toBigDecimal().setScale(20, RoundingMode.HALF_EVEN))
    println(BigDecimal.valueOf(dottie).setScale(8, RoundingMode.HALF_UP))
    println(leibniz.toBigDecimal().multiply(BigDecimal(4)).setScale(10, RoundingMode.DOWN))
    val total = listOf("0.1", "0.2", "0.3").map(::BigDecimal).fold(BigDecimal.ZERO, BigDecimal::add)
    println("$total ${total.toDouble()} ${0.1 + 0.2 + 0.3}")
    println(BigDecimal(1).divide(BigDecimal(7), 30, RoundingMode.HALF_EVEN))
}
