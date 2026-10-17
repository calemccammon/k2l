enum class Op(val symbol: String) {
    PLUS("+") {
        override fun apply(a: Int, b: Int) = a + b
    },
    TIMES("*") {
        override fun apply(a: Int, b: Int) = a * b

        override fun describe() = "multiply (" + super.describe() + ")"
    },
    MINUS("-") {
        override fun apply(a: Int, b: Int) = a - b
        override fun toString() = "minus!"
    };

    abstract fun apply(a: Int, b: Int): Int
    open fun describe() = "op $symbol"
}

// Entries with and without bodies mixed; entry-body state and init blocks.
enum class Level(val weight: Int) {
    LOW(1),
    MEDIUM(5) {
        var calls = 0
        val label = "mid-" + weight

        init {
            calls = 100
        }

        override fun score(): Int {
            calls++
            return weight * 10 + calls
        }
    },
    HIGH(10) {
        override fun score() = weight * 100
    },
    NONE(0);

    open fun score(): Int = weight

    fun twice() = score() * 2
}

// Secondary constructors and entry-body initializers
enum class Shape(val sides: Int) {
    DOT(1),
    SQUARE(4) {
        val doubled = sides * 2
        override fun name2() = "square/$doubled"
    },
    TRIANGLE("tri") {
        override fun name2() = "triangle/$sides"
    },
    LINE("ab") {
        override fun name2() = "line"
    };

    constructor(label: String) : this(label.length)

    open fun name2() = "shape/$sides"
}

interface Describable {
    fun describe(): String
}

enum class Planet(val mass: Int) : Describable {
    EARTH(5) {
        override fun describe() = "home $mass"
    },
    MARS(1) {
        override fun describe() = "red $mass"
    }
}

enum class Color { RED, GREEN }

fun classify(op: Op): String = when (op) {
    Op.PLUS -> "add"
    Op.TIMES -> "mul"
    Op.MINUS -> "sub"
}

fun main() {
    for (op in Op.values()) {
        println("${op.name} ${op.ordinal} ${op.symbol} ${op.apply(6, 3)} ${op.describe()} ${classify(op)}")
    }
    println(Op.PLUS)
    println(Op.MINUS)
    println(Op.MINUS.name)
    println(Op.TIMES.toString())
    println("${Op.MINUS}")
    println(Op.entries)
    println(Op.valueOf("TIMES").apply(7, 6))
    println(Op.valueOf("PLUS") == Op.PLUS)
    println(Op.PLUS == Op.TIMES)
    println(Op.PLUS is Op)
    val any: Any = Op.TIMES
    println(any is Op)
    println(any is Level)
    println(Op.entries.map { it.symbol })
    println(Op.entries.size)

    println("-- levels")
    println(Level.LOW.score())
    println(Level.MEDIUM.score())
    println(Level.MEDIUM.score())
    println(Level.MEDIUM.twice())
    println(Level.HIGH.score())
    println(Level.HIGH.twice())
    println(Level.NONE.twice())
    val total = Level.entries.sumOf { it.weight }
    println(total)
    val best = Level.values().maxByOrNull { it.weight }
    println(best)
    println(Level.entries.joinToString { it.name.lowercase() })

    println("-- shapes")
    for (s in Shape.entries) {
        println("${s.name} ${s.sides} ${s.name2()}")
    }

    println("-- planets")
    for (p in Planet.values()) {
        println(p.describe())
    }
    val d: Describable = Planet.MARS
    println(d.describe())
    println(Color.valueOf("GREEN").ordinal)
    println(Color.values().size)
    try {
        Color.valueOf("BLUE")
    } catch (e: IllegalArgumentException) {
        println("no such color")
    }
}
