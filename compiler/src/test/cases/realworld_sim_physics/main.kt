import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

// A 2D rigid-ball physics step: semi-implicit Euler with gravity and drag, wall bounces with
// restitution, elastic ball-ball collisions with positional correction, and energy bookkeeping.

data class Vec(val x: Double, val y: Double) {
    operator fun plus(o: Vec) = Vec(x + o.x, y + o.y)

    operator fun minus(o: Vec) = Vec(x - o.x, y - o.y)

    operator fun times(s: Double) = Vec(x * s, y * s)

    operator fun unaryMinus() = Vec(-x, -y)

    infix fun dot(o: Vec) = x * o.x + y * o.y

    val length get() = hypot(x, y)

    fun normalized(): Vec = length.let { if (it == 0.0) Vec(0.0, 0.0) else Vec(x / it, y / it) }

    override fun toString() = "(${"%.4f".format(x)}, ${"%.4f".format(y)})"

    companion object {
        val ZERO = Vec(0.0, 0.0)
    }
}

class Ball(val id: Int, var pos: Vec, var vel: Vec, val radius: Double, val mass: Double) {
    val inverseMass get() = if (mass == 0.0) 0.0 else 1.0 / mass

    fun kinetic() = 0.5 * mass * (vel dot vel)
}

class World(val width: Double, val height: Double, val gravity: Double = -9.81, val restitution: Double = 0.9) {
    val balls = mutableListOf<Ball>()
    var time = 0.0
        private set
    var wallHits = 0
        private set
    var ballHits = 0
        private set
    var drag = 0.0

    fun potential() = balls.sumOf { it.mass * -gravity * (it.pos.y - it.radius) }

    fun kinetic() = balls.sumOf { it.kinetic() }

    fun momentum(): Vec = balls.fold(Vec.ZERO) { acc, b -> acc + b.vel * b.mass }

    fun step(dt: Double) {
        for (b in balls) {
            var v = b.vel + Vec(0.0, gravity * dt)
            if (drag > 0.0) v = v * (1.0 - drag * dt)
            b.vel = v
            b.pos = b.pos + v * dt
        }
        for (b in balls) bounceWalls(b)
        for (i in balls.indices) {
            for (j in i + 1 until balls.size) collide(balls[i], balls[j])
        }
        time += dt
    }

    private fun bounceWalls(b: Ball) {
        var (x, y) = b.pos
        var (vx, vy) = b.vel
        if (x - b.radius < 0.0 && vx < 0.0) {
            x = b.radius
            vx = -vx * restitution
            wallHits++
        } else if (x + b.radius > width && vx > 0.0) {
            x = width - b.radius
            vx = -vx * restitution
            wallHits++
        }
        if (y - b.radius < 0.0 && vy < 0.0) {
            y = b.radius
            vy = -vy * restitution
            wallHits++
        } else if (y + b.radius > height && vy > 0.0) {
            y = height - b.radius
            vy = -vy * restitution
            wallHits++
        }
        b.pos = Vec(x, y)
        b.vel = Vec(vx, vy)
    }

    private fun collide(a: Ball, b: Ball) {
        val delta = b.pos - a.pos
        val dist = delta.length
        val overlap = a.radius + b.radius - dist
        if (overlap <= 0.0 || dist == 0.0) return
        val n = delta * (1.0 / dist)
        val totalInverse = a.inverseMass + b.inverseMass
        val correction = n * (overlap / totalInverse * 0.8)
        a.pos = a.pos - correction * a.inverseMass
        b.pos = b.pos + correction * b.inverseMass
        val relative = (b.vel - a.vel) dot n
        if (relative > 0.0) return
        val impulse = -(1.0 + restitution) * relative / totalInverse
        a.vel = a.vel - n * (impulse * a.inverseMass)
        b.vel = b.vel + n * (impulse * b.inverseMass)
        ballHits++
    }

    fun report(label: String) {
        val ke = kinetic()
        val pe = potential()
        println("$label t=${"%.3f".format(time)} KE=${"%.4f".format(ke)} PE=${"%.4f".format(pe)} E=${"%.4f".format(ke + pe)} p=${momentum()}")
    }
}

fun projectile() {
    println("-- projectile")
    val dt = 0.01
    var pos = Vec(0.0, 0.0)
    var vel = Vec(20.0, 20.0)
    var t = 0.0
    var apex = 0.0
    while (pos.y >= 0.0) {
        vel += Vec(0.0, -9.81 * dt)
        pos += vel * dt
        t += dt
        apex = max(apex, pos.y)
    }
    println("flight ${"%.2f".format(t)}s range ${"%.4f".format(pos.x)} apex ${"%.4f".format(apex)}")
    val analyticRange = 2 * 20.0 * 20.0 / 9.81
    println("analytic range ${"%.4f".format(analyticRange)} error ${"%.4f".format(abs(pos.x - analyticRange))}")
}

fun bouncing() {
    println("-- bouncing balls")
    val world = World(10.0, 10.0)
    world.balls += Ball(0, Vec(2.0, 8.0), Vec(1.5, 0.0), 0.5, 1.0)
    world.balls += Ball(1, Vec(5.0, 6.0), Vec(-1.0, 2.0), 0.7, 2.0)
    world.balls += Ball(2, Vec(8.0, 3.0), Vec(-3.0, 4.0), 0.4, 0.5)
    world.balls += Ball(3, Vec(4.0, 2.0), Vec(2.0, -1.0), 0.6, 1.5)
    world.report("start")
    for (frame in 1..600) {
        world.step(1.0 / 120)
        if (frame % 150 == 0) world.report("frame $frame")
    }
    for (b in world.balls) println("ball ${b.id} pos=${b.pos} vel=${b.vel} speed=${"%.4f".format(b.vel.length)}")
    println("wall hits ${world.wallHits}, ball hits ${world.ballHits}")
}

fun newtonsCradle() {
    println("-- cradle")
    val world = World(20.0, 2.0, gravity = 0.0, restitution = 1.0)
    for (i in 0 until 5) world.balls += Ball(i, Vec(5.0 + i * 1.0, 1.0), Vec.ZERO, 0.5, 1.0)
    world.balls[0].pos = Vec(2.0, 1.0)
    world.balls[0].vel = Vec(3.0, 0.0)
    val before = world.kinetic()
    repeat(400) { world.step(0.005) }
    println(world.balls.joinToString { "%.3f".format(it.vel.x) })
    println("energy kept: ${"%.6f".format(world.kinetic() / before)}")
    println("momentum: ${world.momentum()}")
}

fun orbit() {
    println("-- orbit")
    val gm = 1.0
    var pos = Vec(1.0, 0.0)
    var vel = Vec(0.0, 1.0)
    val dt = 0.001
    var minR = Double.MAX_VALUE
    var maxR = 0.0
    fun energy() = 0.5 * (vel dot vel) - gm / pos.length
    val e0 = energy()
    repeat(6284) {
        val r = pos.length
        val acc = -pos.normalized() * (gm / (r * r))
        vel += acc * dt
        pos += vel * dt
        minR = min(minR, pos.length)
        maxR = max(maxR, pos.length)
    }
    println("after one period: $pos")
    println("radius ${"%.6f".format(minR)}..${"%.6f".format(maxR)}")
    println("energy drift ${"%.3e".format(energy() - e0)}")
    println("unit circle ${sqrt(0.5) * sqrt(2.0)} ${Vec(3.0, 4.0).normalized()}")
}

fun main() {
    projectile()
    bouncing()
    newtonsCradle()
    orbit()
}
