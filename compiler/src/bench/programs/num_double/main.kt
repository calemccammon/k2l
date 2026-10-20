import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.exp
import kotlin.math.sin
import kotlin.math.sqrt

// Adapted from realworld_matrix and realworld_simulation: Double math in tight loops; a Matrix class with operator
// overloading and DoubleArray storage, Gaussian elimination, an n-body step, a Mandelbrot grid and Simpson integration.

const val SIZE = 130 // matrix side

class Matrix(val n: Int, val data: DoubleArray = DoubleArray(n * n)) {
    operator fun get(i: Int, j: Int) = data[i * n + j]
    operator fun set(i: Int, j: Int, v: Double) {
        data[i * n + j] = v
    }

    operator fun times(o: Matrix): Matrix {
        val r = Matrix(n)
        for (i in 0 until n) for (k in 0 until n) {
            val a = this[i, k]
            if (a == 0.0) continue
            for (j in 0 until n) r.data[i * n + j] += a * o.data[k * n + j]
        }
        return r
    }

    operator fun plus(o: Matrix) = Matrix(n, DoubleArray(n * n) { data[it] + o.data[it] })

    fun trace() = (0 until n).sumOf { this[it, it] }
}

/** Solves a x = b by Gaussian elimination with partial pivoting. */
fun solve(a0: Matrix, b0: DoubleArray): DoubleArray {
    val n = a0.n
    val a = Matrix(n, a0.data.copyOf())
    val b = b0.copyOf()
    for (col in 0 until n) {
        var pivot = col
        for (r in col + 1 until n) if (abs(a[r, col]) > abs(a[pivot, col])) pivot = r
        if (pivot != col) {
            for (j in 0 until n) {
                val t = a[col, j]
                a[col, j] = a[pivot, j]
                a[pivot, j] = t
            }
            val t = b[col]
            b[col] = b[pivot]
            b[pivot] = t
        }
        for (r in col + 1 until n) {
            val f = a[r, col] / a[col, col]
            for (j in col until n) a[r, j] -= f * a[col, j]
            b[r] -= f * b[col]
        }
    }
    val x = DoubleArray(n)
    for (i in n - 1 downTo 0) {
        var s = b[i]
        for (j in i + 1 until n) s -= a[i, j] * x[j]
        x[i] = s / a[i, i]
    }
    return x
}

class Body(var x: Double, var y: Double, var vx: Double, var vy: Double, val mass: Double)

fun step(bodies: List<Body>, dt: Double) {
    for (i in bodies.indices) {
        val a = bodies[i]
        for (j in i + 1 until bodies.size) {
            val b = bodies[j]
            val dx = a.x - b.x
            val dy = a.y - b.y
            val d2 = dx * dx + dy * dy + 0.01
            val mag = dt / (d2 * sqrt(d2))
            a.vx -= dx * b.mass * mag
            a.vy -= dy * b.mass * mag
            b.vx += dx * a.mass * mag
            b.vy += dy * a.mass * mag
        }
    }
    for (b in bodies) {
        b.x += dt * b.vx
        b.y += dt * b.vy
    }
}

fun energy(bodies: List<Body>): Double = bodies.sumOf { 0.5 * it.mass * (it.vx * it.vx + it.vy * it.vy) }

fun mandelbrot(w: Int, h: Int, maxIter: Int): Int {
    var inside = 0
    for (py in 0 until h) for (px in 0 until w) {
        val cx = -2.0 + 3.0 * px / w
        val cy = -1.2 + 2.4 * py / h
        var x = 0.0
        var y = 0.0
        var i = 0
        while (i < maxIter && x * x + y * y < 4.0) {
            val t = x * x - y * y + cx
            y = 2 * x * y + cy
            x = t
            i++
        }
        if (i == maxIter) inside++
    }
    return inside
}

inline fun simpson(from: Double, to: Double, steps: Int, f: (Double) -> Double): Double {
    val h = (to - from) / steps
    var sum = f(from) + f(to)
    for (i in 1 until steps) sum += f(from + i * h) * if (i % 2 == 1) 4 else 2
    return sum * h / 3
}

fun main() {
    val a = Matrix(SIZE)
    for (i in 0 until SIZE) for (j in 0 until SIZE) a[i, j] = sin(i * 0.37 + j * 0.11) + if (i == j) SIZE.toDouble() else 0.0
    val p = a * a + a
    val q = p * a
    println("trace %.6e %.6e".format(p.trace(), q.trace()))
    val x = solve(a, DoubleArray(SIZE) { cos(it * 0.5) })
    println("solution %.9f %.9f".format(x.sum(), x.maxOf { abs(it) }))

    val bodies = List(40) { Body(cos(it * 1.3) * 10, sin(it * 0.7) * 10, sin(it * 0.3), cos(it * 0.9), 1.0 + it % 3) }
    repeat(300) { step(bodies, 0.001) }
    println("energy %.9f".format(energy(bodies)))
    println("mandelbrot ${mandelbrot(SIZE * 2, SIZE, 120)}")
    val gauss = simpson(-5.0, 5.0, SIZE * 1000) { exp(-it * it / 2) } / sqrt(2 * Math.PI)
    println("gauss %.12f".format(gauss))
}
