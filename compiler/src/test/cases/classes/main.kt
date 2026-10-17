class Counter(private val step: Int) {
    var count = 0
        private set
    val doubled: Int
        get() = count * 2

    init {
        println("Counter created with step $step")
    }

    fun increment(): Counter {
        count += step
        return this
    }

    fun reset() {
        count = 0
    }
}

class Temperature(celsius: Double) {
    var celsius: Double = celsius
        set(value) {
            println("setting $value")
            field = if (value < -273.15) -273.15 else value
        }
    val fahrenheit: Double
        get() = celsius * 9 / 5 + 32
}

class Account(val owner: String) {
    var balance = 0
    constructor(owner: String, initial: Int) : this(owner) {
        balance = initial
        println("secondary constructor for $owner")
    }

    fun deposit(amount: Int) {
        balance += amount
    }

    override fun toString(): String = "Account($owner, $balance)"
}

fun main() {
    val c = Counter(3)
    c.increment().increment()
    println(c.count)
    println(c.doubled)
    c.reset()
    println(c.count)

    val t = Temperature(20.0)
    println(t.fahrenheit)
    t.celsius = -300.0
    println(t.celsius)

    val a = Account("Ada", 100)
    a.deposit(50)
    a.balance -= 30
    println(a)
    println("account: $a")
    val b = Account("Bob")
    b.balance++
    println(b.toString())
    println(a == b)
    println(a == a)
}
