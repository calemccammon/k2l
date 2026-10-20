import kotlin.math.PI
import kotlin.math.sqrt

// Adapted from realworld_app_ecs, realworld_simulation and realworld_app_plugins: virtual calls through interfaces and
// open classes with super calls, sealed-class `when`, an event bus of lambdas, closures that capture state, function
// composition and a small entity-component system.

const val SIZE = 150_000 // entities

sealed class Shape {
    abstract fun area(): Double
    abstract fun perimeter(): Double
    open fun scale(k: Double): Shape = this

    class Circle(val r: Double) : Shape() {
        override fun area() = PI * r * r
        override fun perimeter() = 2 * PI * r
        override fun scale(k: Double) = Circle(r * k)
    }

    class Rect(val w: Double, val h: Double) : Shape() {
        override fun area() = w * h
        override fun perimeter() = 2 * (w + h)
        override fun scale(k: Double) = Rect(w * k, h * k)
    }

    class Triangle(val a: Double, val b: Double, val c: Double) : Shape() {
        override fun area(): Double {
            val s = perimeter() / 2
            return sqrt(s * (s - a) * (s - b) * (s - c))
        }
        override fun perimeter() = a + b + c
    }

    object Empty : Shape() {
        override fun area() = 0.0
        override fun perimeter() = 0.0
    }
}

fun describe(s: Shape): Int = when (s) {
    is Shape.Circle -> 1
    is Shape.Rect -> if (s.w == s.h) 2 else 3
    is Shape.Triangle -> 4
    Shape.Empty -> 0
}

interface Component {
    fun update(dt: Double)
}

class Position(var x: Double, var y: Double) : Component {
    override fun update(dt: Double) {}
}

class Velocity(val pos: Position, var dx: Double, var dy: Double) : Component {
    override fun update(dt: Double) {
        pos.x += dx * dt
        pos.y += dy * dt
        if (pos.x < 0 || pos.x > 100) dx = -dx
        if (pos.y < 0 || pos.y > 100) dy = -dy
    }
}

open class Health(var hp: Int) : Component {
    open fun damage(n: Int) {
        hp -= n
    }
    override fun update(dt: Double) {
        if (hp < 100) hp++
    }
}

class Armored(hp: Int, private val armor: Int) : Health(hp) {
    override fun damage(n: Int) = super.damage(maxOf(0, n - armor))
}

class Entity(val id: Int, val components: List<Component>)

class EventBus {
    private val listeners = HashMap<String, MutableList<(Int) -> Unit>>()
    fun on(event: String, listener: (Int) -> Unit) {
        listeners.getOrPut(event) { mutableListOf() }.add(listener)
    }
    fun emit(event: String, value: Int) {
        listeners[event]?.forEach { it(value) }
    }
}

fun counter(): () -> Int {
    var n = 0
    return { ++n }
}

fun <A, B, C> compose(f: (A) -> B, g: (B) -> C): (A) -> C = { g(f(it)) }

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

fun main() {
    val rng = Lcg(3)
    val shapes = List(SIZE) {
        when (rng.next(4)) {
            0 -> Shape.Circle(1.0 + rng.next(10))
            1 -> Shape.Rect(1.0 + rng.next(5), 1.0 + rng.next(5))
            2 -> Shape.Triangle(3.0, 4.0, 5.0)
            else -> Shape.Empty
        }
    }
    var area = 0.0
    var kinds = 0
    for (round in 0 until 5) {
        for (s in shapes) {
            val t = s.scale(1.0 + round / 10.0)
            area += t.area() + t.perimeter()
            kinds += describe(t)
        }
    }
    println("area %.3f kinds %d".format(area, kinds))

    val entities = List(SIZE / 10) { id ->
        val pos = Position(rng.next(100).toDouble(), rng.next(100).toDouble())
        val health = if (id % 3 == 0) Armored(100, 2) else Health(100)
        Entity(id, listOf(pos, Velocity(pos, rng.next(7) - 3.0, rng.next(7) - 3.0), health))
    }
    val bus = EventBus()
    val hits = counter()
    var damageTotal = 0
    bus.on("hit") { damageTotal += it }
    bus.on("hit") { hits() }
    val bonus = compose<Int, Int, Int>({ it * 2 }, { it + 1 })
    for (tick in 0 until 20) {
        for (e in entities) {
            for (c in e.components) c.update(0.5)
            val pos = e.components[0] as Position
            if (pos.x > 90) {
                val d = bonus(tick % 5)
                (e.components[2] as Health).damage(d)
                bus.emit("hit", d)
            }
        }
    }
    val alive = entities.count { (it.components[2] as Health).hp > 95 }
    val sumX = entities.sumOf { (it.components[0] as Position).x }
    println("hits ${hits() - 1} damage $damageTotal alive $alive x %.2f".format(sumX))
}
