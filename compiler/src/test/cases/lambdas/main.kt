fun applyTwice(f: (Int) -> Int, x: Int): Int = f(f(x))

fun makeAdder(n: Int): (Int) -> Int = { it + n }

fun compose(f: (Int) -> Int, g: (Int) -> Int): (Int) -> Int = { x -> g(f(x)) }

fun runAll(actions: (String) -> Unit) {
    actions("one")
    actions("two")
}

fun firstMatch(limit: Int, predicate: (Int) -> Boolean): Int {
    for (i in 0 until limit) {
        if (predicate(i)) return i
    }
    return -1
}

fun square(x: Int) = x * x

class Greeter(val greeting: String) {
    fun greet(name: String) = "$greeting, $name"
}

fun buildText(block: StringBox.() -> Unit): String {
    val box = StringBox()
    box.block()
    return box.text
}

class StringBox {
    var text = ""
    fun add(s: String) {
        text += s
    }
}

fun main() {
    println(applyTwice({ it * 3 }, 2))
    val add5 = makeAdder(5)
    println(add5(10))
    println(compose(add5, ::square)(1))
    var count = 0
    runAll { count += it.length }
    println(count)
    println(firstMatch(10) { it * it > 20 })
    val g = Greeter("Hi")
    val greet = g::greet
    println(greet("Ann"))
    val lengthOf: (String) -> Int = { s -> s.length }
    println(lengthOf("four"))
    val f = fun(x: Int): Int { return x + 1 }
    println(f(1))
    println(buildText { add("a"); add("b") })

    val x = 4
    println(x.let { it + 1 })
    val y = x.let {
        val doubled = it * 2
        doubled + 1
    }
    println(y)
    val sb = StringBox().apply {
        add("hello")
        add(" world")
    }
    println(sb.text)
    val also = StringBox().also { it.add("also") }
    println(also.text)
    println(with(sb) { text.length })
    println(sb.run { text.uppercase() })
    println(x.takeIf { it > 3 })
    println(x.takeIf { it > 10 })
    repeat(3) { i -> print("r$i ") }
    println()
    val n: Int? = null
    println(n?.let { it * 2 } ?: "none")
    val result = run {
        if (x > 2) return@run "big"
        "small"
    }
    println(result)
}
