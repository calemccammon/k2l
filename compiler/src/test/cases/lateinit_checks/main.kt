// Reading an unset lateinit property or variable throws UninitializedPropertyAccessException, and
// `::name.isInitialized` tells whether it was set.

class Service {
    lateinit var name: String
    private lateinit var cache: MutableList<Int>

    fun ready() = ::name.isInitialized
    fun warm() {
        if (!this::cache.isInitialized) cache = mutableListOf()
        cache += cache.size
    }
    fun cacheSize() = if (::cache.isInitialized) cache.size else -1
}

lateinit var config: Map<String, String>

fun main() {
    val s = Service()
    println("${s.ready()} ${s.cacheSize()}")
    try {
        println(s.name)
    } catch (e: UninitializedPropertyAccessException) {
        println("caught: ${e.message}")
    }
    println(runCatching { s.name.length }.exceptionOrNull())
    s.name = "api"
    s.warm()
    s.warm()
    println("${s.ready()} ${s.name} ${s.cacheSize()}")
    println(runCatching { config["x"] }.exceptionOrNull()?.message)
    println(::config.isInitialized)
    config = mapOf("x" to "1")
    println("${::config.isInitialized} ${config["x"]}")
    lateinit var local: String
    println(runCatching { local.uppercase() }.exceptionOrNull()?.message)
    local = "set"
    println(local.uppercase())
    val e: RuntimeException = UninitializedPropertyAccessException("custom")
    println("${e is UninitializedPropertyAccessException} $e")
}
