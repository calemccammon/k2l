fun greet(name: String = "world", punctuation: String = "!"): String = "Hello, $name$punctuation"

fun range(from: Int = 0, to: Int, step: Int = 1): String {
    var s = ""
    var i = from
    while (i < to) {
        s += "$i "
        i += step
    }
    return s
}

fun withDerived(a: Int, b: Int = a * 2) = a + b

class Config(val name: String, val retries: Int = 3, val verbose: Boolean = false) {
    override fun toString() = "Config($name, $retries, $verbose)"
}

fun main() {
    println(greet())
    println(greet("Kotlin"))
    println(greet(punctuation = "?"))
    println(greet(punctuation = ".", name = "Lua"))
    println(range(to = 5))
    println(range(2, 10, 3))
    println(range(to = 6, step = 2))
    println(withDerived(5))
    println(withDerived(5, 1))
    println(Config("a"))
    println(Config("b", verbose = true))
    println(Config("c", 5))
}
