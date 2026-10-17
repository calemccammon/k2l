class Failure : Exception() {
    override val message: String get() = "failed"
}

fun main() {
    println(Failure().message)
}
