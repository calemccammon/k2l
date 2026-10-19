open class Animal(val name: String)

class Dog(name: String) : Animal(name) {
    fun bark() = "woof from $name"
}

class Cat(name: String) : Animal(name)

interface Shape

class Square : Shape

object Single

fun attempt(label: String, block: () -> Any?) {
    try {
        println("$label: ${block()}")
    } catch (e: ClassCastException) {
        println("$label: ClassCastException")
    } catch (e: NullPointerException) {
        println("$label: NullPointerException")
    }
}

fun <T> unchecked(x: Any?): T {
    @Suppress("UNCHECKED_CAST")
    return x as T
}

fun describe(x: Any?): String {
    if (x is String) {
        val s = x as String // smart cast: no check
        return s.uppercase()
    }
    return "other"
}

fun main() {
    val animal: Animal = Dog("rex")
    println((animal as Dog).bark())
    attempt("cat") { (animal as Cat).name }
    val any: Any = "text"
    println(any as String)
    attempt("string as Int") { any as Int }
    val number: Any = 42
    println(number as Int)
    attempt("int as String") { number as String }
    attempt("int as Boolean") { number as Boolean }
    val flag: Any = true
    println(flag as Boolean)
    attempt("boolean as String") { flag as String }
    val nothing: Any? = null
    println(nothing as String?)
    println(nothing as Int?)
    attempt("null as String") { nothing as String }
    attempt("null as Dog") { nothing as Dog }
    val shape: Any = Square()
    println(shape is Shape)
    println((shape as Shape) === shape)
    attempt("square as Animal") { shape as Animal }
    attempt("object") { (Single as Any) === Single }
    attempt("string as Single") { "x" as Single }
    val list: Any = listOf(1, 2, 3)
    println((list as List<*>).size)
    @Suppress("UNCHECKED_CAST")
    println((list as List<String>).size) // erased: only the class is checked
    attempt("list as Map") { list as Map<*, *> }
    attempt("string as List") { any as List<*> }
    println(unchecked<String>("fine"))
    println(describe("abc"))
    println(describe(1))
    val upcast = Dog("up") as Animal
    println(upcast.name)
    val d: Double = 2.5
    val anyD: Any = d
    println(anyD as Double)
    println(listOf<Any>("a", 1).map { if (it is String) it as String else "n" })
    attempt("in args") { listOf(1 + 1, (any as Int) + 1) }
    try {
        any as Int
    } catch (e: ClassCastException) {
        println(e.message)
    }
    try {
        animal as Cat
    } catch (e: ClassCastException) {
        println(e.message?.substringBefore(" ("))
    }
}
