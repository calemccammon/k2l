interface Named {
    fun label(): String
}

object Config : Named {
    val name = "config"
    var calls = 0

    init {
        println("Config initialized")
    }

    override fun label() = "Config($name)"

    fun bump(): Int {
        calls++
        return calls
    }
}

object Loud {
    val value = compute("Loud")
    val other = value + "!"

    private fun compute(s: String): String {
        println("computing $s")
        return s.uppercase()
    }
}

object Plain {
    val x = 10
    val names = listOf("a", "b")
    var count = 0

    fun inc() = ++count
}

object Second {
    val dependsOnConfig = Config.name + "-second"

    init {
        println("Second initialized")
    }
}

open class Base(val id: Int) {
    init {
        println("Base($id)")
    }
}

object Derived : Base(7) {
    val tag = "derived"
}

class Service {
    companion object {
        val instances = mutableListOf<String>()

        init {
            println("Service companion initialized")
        }

        fun create(name: String): Service {
            instances.add(name)
            return Service()
        }
    }

    object Nested {
        init {
            println("Nested initialized")
        }

        val k = 3
    }
}

class Quiet {
    companion object {
        val ZERO = Quiet()
        const val LIMIT = 5
        var made = 0
    }
}

enum class Level(val code: Int) {
    LOW(1),
    HIGH(2);

    init {
        println("Level.$name created")
    }

    companion object {
        val default = LOW
    }
}

enum class Color(val rgb: Int) {
    RED(0xff0000),
    GREEN(0x00ff00);

    fun hex() = "#" + rgb.toString(16)
}

enum class Mode {
    A {
        override fun describe() = "mode a"
    },
    B {
        override fun describe() = "mode b"
    };

    abstract fun describe(): String

    val upper = name.uppercase().also { println("Mode.$name upper") }
}

fun main() {
    println("start")
    println(Plain.inc())
    println(Color.RED.hex() + " " + Color.entries.size)
    println("before Config")
    val ref: Any = Config
    println("holding a reference")
    println(ref is Named)
    println(Config.bump())
    println(Config.label())
    println(Config.bump())
    println("before Loud")
    println(Loud.other)
    println(Loud.value)
    println("before Second")
    println(Second.dependsOnConfig)
    println("before Derived")
    println(Derived.tag)
    println(Derived.id)
    println("before Service")
    println(Service.Nested.k)
    println(Service.create("one").javaClass == Service::class.java)
    println(Service.instances)
    println(Quiet.LIMIT)
    println(Quiet.made)
    println("before Level")
    println(Level.HIGH.code)
    println(Level.values().map { it.name })
    println(Level.default)
    println(Level.valueOf("LOW").code)
    println("before Mode")
    println(Mode.B.describe())
    println(Mode.A.upper)
    println("end")
}
