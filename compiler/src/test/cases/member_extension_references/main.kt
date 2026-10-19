// Kotlin forbids references (`Builder::shout`, `b::shout`) to member extensions, so they are only called, also from
// lambdas that run later and from nested scopes.
class Builder(private val bang: String) {
    val parts = mutableListOf<String>()

    operator fun String.unaryPlus() {
        parts += this + bang
    }

    fun String.shout() = uppercase() + bang

    fun Int.twice() = this * 2 + parts.size

    fun fromInside(): List<String> = listOf("x", "y").map { it.shout() } + listOf("p").map { s -> s.shout() }

    fun inside(): List<Int> = listOf(1, 2).map { it.twice() }

    fun deferred(): () -> String {
        val f = { s: String -> s.shout() }
        return { f("later") + 3.twice() }
    }
}

fun main() {
    val b = Builder("!")
    with(b) {
        listOf("a", "b").forEach { it.unaryPlus() }
        listOf("c").forEach { +it }
        println(listOf("m", "n").map { it.shout() })
        val f: (String) -> String = { it.shout() }
        println(f("with"))
        val g = { n: Int -> n.twice() }
        println(g(4))
    }
    println(b.parts)
    println(b.fromInside())
    println(b.inside())
    println(b.deferred()())
    val h = b.run { { s: String -> s.shout() } }
    println(h("held"))
    println(b.let { with(it) { "q".shout() + 5.twice() } })
}
