object Registry {
    private var nextId = 1
    val prefix = "id-"

    fun register(name: String): String {
        val id = prefix + nextId
        nextId++
        println("registered $name as $id")
        return id
    }
}

enum class Direction {
    NORTH, EAST, SOUTH, WEST;

    fun turnRight(): Direction = when (this) {
        NORTH -> EAST
        EAST -> SOUTH
        SOUTH -> WEST
        WEST -> NORTH
    }
}

enum class Planet(val mass: Double, val radius: Double) {
    MERCURY(3.303e+23, 2.4397e6),
    EARTH(5.976e+24, 6.37814e6);

    val gravity: Double
        get() = 6.67300E-11 * mass / (radius * radius)
}

class Point private constructor(val x: Int, val y: Int) {
    companion object {
        val ORIGIN = Point(0, 0)
        var created = 0

        fun of(x: Int, y: Int): Point {
            created++
            return Point(x, y)
        }
    }

    fun plus(other: Point): Point = of(x + other.x, y + other.y)
}

fun main() {
    Registry.register("alpha")
    Registry.register("beta")
    println(Registry.prefix)

    var d = Direction.NORTH
    for (i in 1..5) {
        print("${d.name}(${d.ordinal}) ")
        d = d.turnRight()
    }
    println()
    println(Direction.WEST)
    println(d == Direction.EAST)
    val e = Planet.EARTH
    println(e.name + " " + (e.gravity > 9.7 && e.gravity < 9.9))
    println(Planet.MERCURY.mass)

    val p = Point.of(1, 2).plus(Point.of(3, 4))
    println("${p.x},${p.y} created=${Point.created}")
    println(Point.ORIGIN.x)
}
