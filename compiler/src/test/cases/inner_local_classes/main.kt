class Host(val name: String) {
    inner class In(val n: Int) {
        fun show() = "$name/$n"
    }

    fun refs(): List<String> = listOf(1, 2).map(::In).map { it.show() }

    fun bound(): String = (::In)(9).show()
}

class Pair2(val a: String) {
    inner class Part(val b: String) {
        fun joined() = a + b
    }
}

fun localInner(): String {
    val prefix = "p"

    class Local(val label: String) {
        var count = 0

        inner class Inner(val step: Int) {
            fun bump(): String {
                count += step
                return "$prefix:$label:$count"
            }

            inner class Deep {
                fun path() = "$label>${step}>$count"
            }
        }

        fun make(step: Int) = Inner(step)
    }

    val local = Local("L")
    val inner = local.make(2)
    val first = inner.bump()
    val second = local.Inner(5).bump()
    val deep = inner.Deep().path()
    return "$first $second $deep"
}

fun main() {
    val h = Host("host")
    println(h.refs())
    println(h.bound())
    println(localInner())

    // function references to inner constructors: the outer instance is the first parameter
    val make: (Host, Int) -> Host.In = Host::In
    println(make(Host("other"), 7).show())
    val partOf: Pair2.(String) -> Pair2.Part = Pair2::Part
    println(Pair2("x").partOf("y").joined())
    val bound: (Int) -> Host.In = h::In
    println(bound(3).show())
}
