package app

import dev.k2l.lua.LuaName

object Counter {
    private var count = 0
    private val step = 2

    private fun advance(by: Int) {
        count += by
    }

    fun tick(): Int {
        advance(step)
        return count
    }

    fun reference(): () -> Unit = ::reset

    private fun reset() {
        count = 0
    }

    fun property(): () -> Int = ::count
}

class Account(val owner: String) {
    private var balance = 0

    private fun check(amount: Int) = amount <= balance

    private fun check(text: String) = text.isNotEmpty()

    fun deposit(amount: Int): Account {
        balance += amount
        return this
    }

    fun withdraw(amount: Int): Boolean = check(amount).also { ok -> if (ok) balance -= amount }

    fun sameOwner(other: Account) = other.label() == label()

    private fun label() = owner.uppercase()

    fun labels(accounts: List<Account>) = accounts.map(Account::label) + accounts.map { it.label() }

    fun bound(): () -> Boolean = this::nonEmpty

    private fun nonEmpty() = check(owner)

    var pin = 0
        private set

    fun changePin(p: Int) {
        pin = p
    }
}

class Ledger {
    private fun check(amount: Int) = amount > 100

    fun large(amount: Int) = check(amount)
}

class Shadows {
    private fun total(xs: List<Int>) = xs.sum()

    fun run(total: Int, count: Int) = total + count + total(listOf(1, 2))
}

class Machine {
    companion object {
        private var made = 0
        private fun nextId() = ++made

        fun create() = Machine()
    }

    val id = nextId()

    inner class Part {
        fun owner() = "part of ${describe()}"
    }

    private fun describe() = "machine $id"
}

object Lazy {
    private val start = load("Lazy")

    init {
        println("Lazy ready")
    }

    private fun load(what: String): Int {
        println("loading $what")
        return 41
    }

    class Reader {
        // runs before Lazy is initialized: reading `start` initializes it
        fun read() = start + 1
    }

    fun direct() = start
}

interface Greeter {
    val name: String

    private fun prefix() = "Hello, "

    fun greet() = prefix() + name
}

class English(override val name: String) : Greeter

enum class Op {
    ADD {
        override fun apply(a: Int, b: Int) = clamp(a + b)
    },
    SUB {
        override fun apply(a: Int, b: Int) = clamp(a - b)
    }, ;

    abstract fun apply(a: Int, b: Int): Int

    protected fun clamp(v: Int) = limit(v)

    private fun limit(v: Int) = if (v < 0) 0 else v
}

object Exposed {
    @LuaName("visible_helper")
    private fun helper() = "kept"

    fun call() = helper()
}

object Late {
    private lateinit var config: String

    fun ready() = ::config.isInitialized

    fun set(value: String) {
        config = value
    }

    fun get() = config
}

class Matrix(private val cells: IntArray) {
    private operator fun get(i: Int) = cells[i]

    fun first() = this[0]
}

object Recursion {
    private fun even(n: Int): Boolean = if (n == 0) true else odd(n - 1)

    private fun odd(n: Int): Boolean = if (n == 0) false else even(n - 1)

    fun isEven(n: Int) = even(n)
}

fun main() {
    println(Counter.tick())
    println(Counter.tick())
    Counter.reference()()
    println(Counter.tick())
    val count = Counter.property()
    println(count())

    val a = Account("ada").deposit(10)
    println(a.withdraw(3))
    println(a.withdraw(30))
    println(a.sameOwner(Account("ADA")))
    println(a.labels(listOf(a, Account("bob"))))
    println(a.bound()())
    a.changePin(42)
    println(a.pin)
    println(Ledger().large(500))
    println(Shadows().run(1, 2))

    val m = Machine.create()
    println(Machine.create().id)
    println(m.Part().owner())

    println("before reader")
    println(Lazy.Reader().read())
    println(Lazy.direct())

    println(English("Bob").greet())
    println(Op.ADD.apply(1, 2))
    println(Op.SUB.apply(1, 2))
    println(Exposed.call())

    println(Late.ready())
    Late.set("on")
    println(Late.ready())
    println(Late.get())

    println(Matrix(intArrayOf(7, 8)).first())
    println(Recursion.isEven(10))
}
