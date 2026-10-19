// Companion members named like members of the class's instances: the companion gets a table of its own, so neither hides
// the other.
data class Response(val status: Int, val body: String, val note: String? = null) {
    val ok get() = status in 200..299

    companion object {
        val note = "companion note"
        fun ok(body: String) = Response(200, body)
        fun copy(r: Response) = r.copy(body = r.body + "!")
        override fun toString() = "Response.Companion"
    }
}

class Counter(var count: Int) {
    fun count(by: Int) = count + by

    companion object {
        var count = 100
        fun count() = count++
    }
}

fun main() {
    val r = Response.ok("hi")
    println("$r ${r.ok} ${r.note} ${Response.note} ${Response.copy(r)} ${Response}")
    val c = Counter(1)
    println("${c.count} ${c.count(5)} ${Counter.count()} ${Counter.count()} ${Counter.count}")
    val companion: Any = Response
    println(companion)
}
