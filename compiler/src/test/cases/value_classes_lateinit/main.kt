// Value classes compare, hash and print by their value; lateinit properties throw until they are assigned.

@JvmInline
value class UserId(val raw: Int) {
    init {
        require(raw >= 0) { "negative id $raw" }
    }

    val next get() = UserId(raw + 1)

    fun describe() = "user#$raw"
}

@JvmInline
value class Email(val address: String) {
    val domain get() = address.substringAfter('@')
}

data class Account(val id: UserId, val email: Email)

class Session {
    lateinit var user: Account
    lateinit var tags: MutableList<String>

    fun login(account: Account) {
        user = account
    }

    fun status() = if (this::user.isInitialized) "logged in as ${user.email.address}" else "anonymous"
}

lateinit var config: String

fun main() {
    val a = UserId(7)
    println(a)
    println(a == UserId(7))
    println(a.hashCode() == 7.hashCode())
    println(setOf(UserId(1), UserId(1), UserId(2)).size)
    println(mapOf(UserId(3) to "x")[UserId(3)])
    println("${a.next} ${a.describe()} ${Email("a@b.org").domain}")
    println(Account(UserId(1), Email("x@y.z")) == Account(UserId(1), Email("x@y.z")))
    println(Account(UserId(1), Email("x@y.z")))
    println(runCatching { UserId(-1) }.exceptionOrNull()?.message)
    println(listOf(UserId(3), UserId(1)).sortedBy { it.raw })

    val s = Session()
    println(s.status())
    try {
        println(s.user)
    } catch (e: UninitializedPropertyAccessException) {
        println("${e::class.simpleName}: ${e.message}")
    }
    s.login(Account(UserId(9), Email("me@k2l.dev")))
    println(s.status())
    println(runCatching { s.tags.size }.exceptionOrNull()?.message)
    s.tags = mutableListOf("a")
    s.tags += "b"
    println(s.tags)
    println(runCatching { config.length }.exceptionOrNull()?.message)
    config = "ready"
    println(config)
    lateinit var local: String
    val e = runCatching { local.length }.exceptionOrNull()
    println(e is UninitializedPropertyAccessException && e is RuntimeException)
    local = "set"
    println(local)
}
