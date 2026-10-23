package app

import bindings.callTwice
import dev.k2l.lua.NoSelf
import shapes.*

@NoSelf
interface Handler {
    fun handle(value: Int): String
}

@NoSelf
object Book {
    var opened = 0

    fun Initialize(title: String, page: Int) {
        opened++
        println("open $title at $page, $opened opened")
    }

    fun reopen() = Initialize("again", opened)
}

// Not annotated: its overrides of Handler's function follow Handler, its own functions take self.
object Doubler : Handler {
    override fun handle(value: Int) = "${value * 2}"

    fun twice(value: Int) = handle(handle(value).toInt())
}

open class Counter(private var count: Int) : Handler {
    override fun handle(value: Int): String {
        count += value
        return "$count"
    }

    fun current() = count
}

class LoudCounter(start: Int) : Counter(start) {
    override fun handle(value: Int) = super.handle(value) + "!"
}

// One annotated function in a class that otherwise takes self.
class Registry {
    private var names = ""

    @NoSelf
    fun add(name: String) {
        names += "[$name]"
    }

    fun all() = names
}

// A class marked @NoSelf; its companion follows it.
@NoSelf
class Config(val name: String) {
    fun greet() = "config $name"

    companion object {
        var loaded = 0

        fun load(name: String): Config {
            loaded++
            return Config(name)
        }
    }
}

fun main() {
    Book.Initialize("Atlas", 3)
    Book.reopen()
    val square = Square(3)
    val rect = Rect(2, 5)
    val shapes = listOf(square, rect, Unit1)
    for (s in shapes) println(s.describe())
    println("${square.scaled(2)} ${rect.scaled(2)}")
    val inline = object : Handler {
        override fun handle(value: Int) = "inline $value"
    }
    println(callTwice(inline, 1))
    println(callTwice(Doubler, 4))
    println(Doubler.twice(3))
    val counter = LoudCounter(10)
    println(callTwice(counter, 5))
    println(counter.current())
    val registry = Registry()
    registry.add("a")
    registry.add("b")
    println(registry.all())
    val config = Config.load("main")
    println("${config.greet()} ${Config.loaded}")
    println(Money.of(2).plus(Money(5)).toString() + " " + (Money(5) == Money(5)) + " " + (Money.ZERO == Money(1)))

    // function references
    val open = Book::Initialize
    open("Ref", 9)
    val handle = Handler::handle
    println(handle(Doubler, 21))
    val area = square::area
    val describe = Shape::describe
    println("${area()} ${describe(Unit1)}")
    val add = registry::add
    add("c")
    println(registry.all())
}
