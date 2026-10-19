interface Greeter {
    fun greet(): String
}

fun main() {
    // an exception class declared inside a lambda
    val errors = listOf(1, 2).map { n ->
        class MyEx(m: String) : Exception(m)
        MyEx("failure $n")
    }
    println(errors.map { it.message })
    println(errors.first() is Exception)

    // thrown and caught inside the lambda
    val outcomes = listOf("a", "b").map { s ->
        class Oops(val code: Int) : RuntimeException("oops $s")
        try {
            throw Oops(s.length)
        } catch (e: Oops) {
            "${e.message}/${e.code}"
        }
    }
    println(outcomes)

    // a class with an interface and state, declared in a lambda used by run/let
    val greeting = run {
        class English(val who: String) : Greeter {
            override fun greet() = "Hello, $who"
        }
        English("lambda").greet()
    }
    println(greeting)

    val make: (Int) -> Any = { n ->
        class Box(val v: Int)
        Box(n * 2)
    }
    println(make(2) is Any)
}
