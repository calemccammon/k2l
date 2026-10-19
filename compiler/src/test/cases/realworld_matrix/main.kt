import kotlin.math.abs
import kotlin.math.sqrt

// Linear algebra and geometry: a Matrix with indexed operators, Gaussian elimination,
// value classes for units, a polynomial type, and 2D vectors with operator overloading.

typealias Row = DoubleArray

class Matrix(val rows: Int, val cols: Int, init: (Int, Int) -> Double = { _, _ -> 0.0 }) {
    private val data: Array<Row> = Array(rows) { r -> DoubleArray(cols) { c -> init(r, c) } }

    operator fun get(r: Int, c: Int) = data[r][c]
    operator fun set(r: Int, c: Int, v: Double) {
        data[r][c] = v
    }

    operator fun times(o: Matrix): Matrix {
        require(cols == o.rows) { "dimension mismatch: ${rows}x$cols * ${o.rows}x${o.cols}" }
        return Matrix(rows, o.cols) { r, c -> (0 until cols).sumOf { this[r, it] * o[it, c] } }
    }

    operator fun times(k: Double) = Matrix(rows, cols) { r, c -> this[r, c] * k }
    operator fun plus(o: Matrix) = Matrix(rows, cols) { r, c -> this[r, c] + o[r, c] }
    operator fun unaryMinus() = this * -1.0

    fun transpose() = Matrix(cols, rows) { r, c -> this[c, r] }

    fun determinant(): Double {
        require(rows == cols) { "not square" }
        val m = copy()
        var det = 1.0
        for (col in 0 until rows) {
            val pivot = (col until rows).maxBy { abs(m[it, col]) }
            if (abs(m[pivot, col]) < 1e-12) return 0.0
            if (pivot != col) {
                m.swapRows(pivot, col)
                det = -det
            }
            det *= m[col, col]
            for (r in col + 1 until rows) {
                val f = m[r, col] / m[col, col]
                for (c in col until cols) m[r, c] -= f * m[col, c]
            }
        }
        return det
    }

    fun solve(b: DoubleArray): DoubleArray {
        val n = rows
        val aug = Matrix(n, n + 1) { r, c -> if (c < n) this[r, c] else b[r] }
        for (col in 0 until n) {
            val pivot = (col until n).maxBy { abs(aug[it, col]) }
            check(abs(aug[pivot, col]) > 1e-12) { "singular matrix" }
            aug.swapRows(pivot, col)
            for (r in 0 until n) {
                if (r == col) continue
                val f = aug[r, col] / aug[col, col]
                for (c in col..n) aug[r, c] -= f * aug[col, c]
            }
        }
        return DoubleArray(n) { aug[it, n] / aug[it, it] }
    }

    private fun swapRows(a: Int, b: Int) {
        val t = data[a]
        data[a] = data[b]
        data[b] = t
    }

    fun copy() = Matrix(rows, cols) { r, c -> this[r, c] }

    override fun equals(other: Any?) = other is Matrix && other.rows == rows && other.cols == cols &&
        (0 until rows).all { r -> data[r].contentEquals(other.data[r]) }

    override fun hashCode() = data.fold(rows * 31 + cols) { h, row -> h * 31 + row.contentHashCode() }

    override fun toString() = data.joinToString("\n") { row -> row.joinToString(" ") { "%7.2f".format(it) } }

    companion object {
        fun identity(n: Int) = Matrix(n, n) { r, c -> if (r == c) 1.0 else 0.0 }
        fun of(vararg rows: DoubleArray) = Matrix(rows.size, rows[0].size) { r, c -> rows[r][c] }
    }
}

@JvmInline
value class Meters(val value: Double) : Comparable<Meters> {
    operator fun plus(o: Meters) = Meters(value + o.value)
    operator fun times(k: Double) = Meters(value * k)
    override fun compareTo(other: Meters) = value.compareTo(other.value)
    override fun toString() = "%.2fm".format(value)
}

@JvmInline
value class Seconds(val value: Double)

operator fun Meters.div(t: Seconds) = value / t.value

val Double.m get() = Meters(this)
val Int.km get() = Meters(this * 1000.0)

data class Vec(val x: Double, val y: Double) {
    operator fun plus(o: Vec) = Vec(x + o.x, y + o.y)
    operator fun minus(o: Vec) = Vec(x - o.x, y - o.y)
    operator fun times(k: Double) = Vec(x * k, y * k)
    infix fun dot(o: Vec) = x * o.x + y * o.y
    infix fun cross(o: Vec) = x * o.y - y * o.x
    val length get() = sqrt(this dot this)
    override fun toString() = "(${x.fmt()}, ${y.fmt()})"
}

fun Double.fmt() = if (this == Math.floor(this) && abs(this) < 1e9) toLong().toString() else "%.3f".format(this)

fun convexHull(points: List<Vec>): List<Vec> {
    val sorted = points.sortedWith(compareBy({ it.x }, { it.y }))
    fun half(list: List<Vec>): List<Vec> {
        val hull = ArrayList<Vec>()
        for (p in list) {
            while (hull.size >= 2 && (hull[hull.size - 1] - hull[hull.size - 2]) cross (p - hull[hull.size - 2]) <= 0) hull.removeAt(hull.size - 1)
            hull += p
        }
        return hull.dropLast(1)
    }
    return half(sorted) + half(sorted.asReversed())
}

fun polygonArea(poly: List<Vec>) = abs((poly + poly.first()).zipWithNext { a, b -> a cross b }.sum()) / 2

class Poly(coefficients: List<Long>) {
    val coef: List<Long> = coefficients.dropLastWhile { it == 0L }.ifEmpty { listOf(0L) }
    val degree get() = coef.size - 1

    operator fun plus(o: Poly) = Poly(List(maxOf(coef.size, o.coef.size)) { coef.getOrElse(it) { 0L } + o.coef.getOrElse(it) { 0L } })
    operator fun times(o: Poly): Poly {
        val out = LongArray(coef.size + o.coef.size - 1)
        for ((i, a) in coef.withIndex()) for ((j, b) in o.coef.withIndex()) out[i + j] += a * b
        return Poly(out.toList())
    }

    operator fun invoke(x: Long) = coef.foldRight(0L) { c, acc -> acc * x + c }
    fun derivative() = Poly(coef.drop(1).mapIndexed { i, c -> c * (i + 1) })

    override fun toString(): String = coef.withIndex().reversed().filter { it.value != 0L }.joinToString(" + ") { (i, c) ->
        when (i) {
            0 -> "$c"
            1 -> "${if (c == 1L) "" else c}x"
            else -> "${if (c == 1L) "" else c}x^$i"
        }
    }.replace("+ -", "- ").ifEmpty { "0" }
}

fun main() {
    val a = Matrix.of(doubleArrayOf(2.0, 1.0, -1.0), doubleArrayOf(-3.0, -1.0, 2.0), doubleArrayOf(-2.0, 1.0, 2.0))
    println("A =\n$a")
    println("det(A) = ${a.determinant().fmt()}")
    val x = a.solve(doubleArrayOf(8.0, -11.0, -3.0))
    println("solve: ${x.joinToString { it.fmt() }}")
    println("A * I == A: ${a * Matrix.identity(3) == a}, A^T^T == A: ${a.transpose().transpose() == a}")
    val b = Matrix(2, 3) { r, c -> (r * 3 + c + 1).toDouble() }
    println("B * B^T =\n${b * b.transpose()}")
    println("-B + B is zero: ${(-b + b) == Matrix(2, 3)}")
    try {
        b * b
    } catch (e: IllegalArgumentException) {
        println("error: ${e.message}")
    }
    println(runCatching { Matrix.of(doubleArrayOf(1.0, 2.0), doubleArrayOf(2.0, 4.0)).solve(doubleArrayOf(1.0, 2.0)) }.exceptionOrNull())
    val hilbert = Matrix(4, 4) { r, c -> 1.0 / (r + c + 1) }
    println("det(H4) = ${"%.6e".format(hilbert.determinant())}")
    val m = Matrix.identity(2)
    m[0, 1] = 5.0
    m[1, 0] += 2.0
    println("edited: ${m[0, 1]} ${m[1, 0]} hash equal: ${m.hashCode() == m.copy().hashCode()}")

    val run = listOf(400.0.m, 1.km, 2.5.m * 100.0).fold(0.0.m) { acc, d -> acc + d }
    println("distance $run, speed ${"%.3f".format(run / Seconds(300.0))} m/s, longest ${listOf(3.0.m, 12.5.m, 7.0.m).max()}")
    val legs = mapOf("warmup" to 800.0.m, "main" to 5.km, "cooldown" to 400.0.m)
    println("legs sorted: ${legs.entries.sortedBy { it.value }.map { it.key }} total ${legs.values.reduce(Meters::plus)}")

    val pts = listOf(Vec(0.0, 0.0), Vec(4.0, 0.0), Vec(4.0, 3.0), Vec(0.0, 3.0), Vec(2.0, 1.0), Vec(1.0, 2.0), Vec(2.0, 5.0), Vec(3.0, 1.5))
    val hull = convexHull(pts)
    println("hull: $hull area=${polygonArea(hull).fmt()}")
    val v = Vec(3.0, 4.0)
    println("|v|=${v.length.fmt()} v·(1,0)=${(v dot Vec(1.0, 0.0)).fmt()} v×(0,1)=${(v cross Vec(0.0, 1.0)).fmt()} v*0.5=${v * 0.5}")
    val (vx, vy) = v - Vec(1.0, 1.0)
    println("destructured: $vx $vy")

    val p = Poly(listOf(-1L, 0L, 1L)) // x^2 - 1
    val q = Poly(listOf(1L, 1L)) // x + 1
    println("p = $p, q = $q, p*q = ${p * q}, p+q = ${p + q}, p' = ${p.derivative()}")
    println("p(3) = ${p(3)}, (p*q)(2) = ${(p * q)(2)}, degree ${(p * q * q).degree}")
    val binomial = generateSequence(Poly(listOf(1L))) { it * q }.take(6).last()
    println("(x+1)^5 = $binomial, at 10: ${binomial(10)}")
    println("zero: ${Poly(listOf(0L, 0L))} ${p + Poly(listOf(1L, 0L, -1L))}")
}
