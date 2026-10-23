// With the runtime inlined, a file gets only the part of it that its code uses: the list methods called here, Pair, and
// what those need.
class Pending(val fn: () -> Unit, var remaining: Int, val name: String? = null)

private var deferred = mutableListOf<Pending>()

fun defer(fn: () -> Unit, frames: Int = 60) {
    deferred.add(Pending(fn, frames))
}

fun run() {
    if (deferred.isEmpty()) return
    val pending = deferred
    deferred = mutableListOf()
    for (item in pending) {
        item.remaining--
        if (item.remaining > 0) deferred.add(item) else item.fn()
    }
}

fun pair() = 1 to 2

fun main() {
    defer({ println("a") }, 1)
    defer({ println("b") }, 2)
    run()
    run()
    run()
    println(pair())
}
