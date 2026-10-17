fun greet(name: String): String = "Hello, $name!"

fun main() {
    val names = listOf("Lua", "Kotlin")
    for (n in names) println(greet(n))
}
