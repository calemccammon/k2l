// Object expressions: anonymous objects implementing interfaces or extending classes, capturing locals and `this`.
package app

interface Greeter {
    fun greet(name: String): String
}

interface Counter {
    fun next(): Int
}

open class Animal(val name: String) {
    open fun sound() = "..."

    fun describe() = "$name says ${sound()}"
}

class Ticker : Counter {
    private var n = 0

    override fun next() = ++n
}

class Shop(val title: String) {
    private var visits = 0

    // `this` of the enclosing class, and a member of it changed from the object
    fun greeter(): Greeter = object : Greeter {
        override fun greet(name: String): String {
            visits++
            return "Welcome to $title, $name (visit $visits)"
        }
    }

    val counter = object : Counter {
        var count = 10

        override fun next() = count++ + visits
    }

    inner class Desk {
        fun helper(): Greeter = object : Greeter {
            override fun greet(name: String) = "$title desk helps $name"
        }
    }
}

fun makeCounter(start: Int): Counter {
    var current = start
    // a captured `var` changed by the object and seen outside of it
    val c = object : Counter {
        override fun next(): Int {
            current += 2
            return current
        }
    }
    c.next()
    println("current after one call: $current")
    return c
}

fun use(g: Greeter) = g.greet("Ann")

fun main() {
    println(use(object : Greeter {
        override fun greet(name: String) = "Hi $name"
    }))

    val dog = object : Animal("Rex"), Counter {
        init {
            println("init of the dog object")
        }

        var barks = 0

        override fun sound(): String {
            barks++
            return "woof"
        }

        override fun next() = barks
    }
    println(dog.describe() + " " + dog.describe() + " " + dog.next())
    println("${dog is Animal} ${dog is Counter} ${(dog as Animal).name}")

    // members of an anonymous type are reachable through the inferred type
    val point = object {
        val x = 3
        var y = 4

        fun sum() = x + y
    }
    point.y = 10
    println(point.sum())

    val counter = makeCounter(5)
    println("${counter.next()} ${counter.next()}")

    val shop = Shop("Corner")
    val g = shop.greeter()
    println(g.greet("Bo"))
    println(g.greet("Cy"))
    println(shop.counter.next() + shop.counter.next())
    println(shop.Desk().helper().greet("Di"))

    // delegation, and one object per evaluation
    val ticker = object : Counter by Ticker() {}
    println("${ticker.next()} ${ticker.next()}")
    val made = (1..3).map { i ->
        object : Counter {
            override fun next() = i * 100
        }
    }
    println(made.map { it.next() })
    println(made[0] === made[1])

    // JVM class names of local and anonymous classes
    class Local

    println(Local().javaClass.name)
    println(g.javaClass.name + " " + point.javaClass.name)
    println(shop.counter.javaClass.name + " " + made[0].javaClass.name)
    println("${point::class.simpleName} ${Local::class.simpleName} ${point::class.qualifiedName}")
    println(point.toString().startsWith("app.MainKt\$main\$point\$1@"))
}
