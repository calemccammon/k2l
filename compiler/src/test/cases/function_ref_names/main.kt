import kotlin.reflect.KCallable
import kotlin.reflect.KFunction
import kotlin.reflect.KFunction1

class Greeter(val greeting: String) {
    fun greet(name: String) = "$greeting, $name"
}

fun twice(x: Int) = x * 2

fun shout(s: String) = s.uppercase() + "!"

fun String.whisper() = lowercase() + "..."

fun describe(f: KFunction<*>) = "function ${f.name}"

fun names(vararg fs: KCallable<*>): List<String> = fs.map { it.name }

fun pick(flag: Boolean): KFunction1<Int, Int> = if (flag) ::twice else ::negate

fun negate(x: Int) = -x

fun main() {
    val f = ::twice
    println(f.name)
    println(f(21))
    println(f.invoke(4))
    println(listOf(1, 2, 3).map(f))
    println(listOf(1, 2, 3).map(::twice))
    println(listOf(1, 2, 3).map(::negate))

    val g: KFunction1<String, String> = ::shout
    println(g.name + " -> " + g("hey"))

    val w = String::whisper
    println(w.name + " -> " + w("LOUD"))

    val greeter = Greeter("Hello")
    val bound = greeter::greet
    println(bound.name + " -> " + bound("Kotlin"))
    val unbound = Greeter::greet
    println(unbound.name + " -> " + unbound(greeter, "Lua"))

    val len = String::isEmpty
    println("${len.name}: ${len("four")}")
    val up = String::isBlank
    println(up.name + " -> " + up("  "))

    println(describe(::twice))
    println(names(::twice, ::shout, Greeter::greet))
    val chosen = pick(true)
    println(chosen.name + " " + chosen(5))
    println(pick(false).name)

    val make = ::Greeter
    println(make.name)
    println(make("Hi").greet("there"))

    val table = mapOf("a" to ::twice, "b" to ::negate)
    for ((key, fn) in table) println("$key: ${fn.name} ${fn(10)}")
    println(sortedNames(listOf(::shout, ::twice)))
    println(::twice.name)
}

fun sortedNames(fs: List<KFunction<*>>) = fs.map { it.name }.sorted()
