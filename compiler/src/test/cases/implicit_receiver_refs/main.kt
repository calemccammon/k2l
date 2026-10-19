// References to members without a receiver (`::scale` inside the class, `::parse` inside a companion,
// `::count` inside an object) are bound to the implicit `this`; `Obj::f` of an object is bound to the object.

object Util {
    var calls = 0
    fun twice(x: Int): Int {
        calls++
        return x * 2
    }
    fun all(xs: List<Int>) = xs.map(::twice)
    fun counter() = ::calls
}

class Scaler(val k: Int) {
    var total = 0
    fun scale(x: Int) = (x * k).also { total += it }
    fun scaleAll(xs: List<Int>) = xs.map(::scale)
    fun scaleAllThis(xs: List<Int>) = xs.map(this::scale)
    fun totalRef() = ::total
    fun kRef() = ::k

    inner class Report {
        fun lines(xs: List<Int>) = xs.map(::scale).map(::format)
        private fun format(x: Int) = "<$x>"
    }

    companion object {
        fun parse(s: String) = Scaler(s.toInt())
        fun parseAll(xs: List<String>) = xs.map(::parse).map { it.k }
    }
}

fun main() {
    println(Util.all(listOf(1, 2)))
    println(listOf(3, 4).map(Util::twice))
    println("${Util.counter().get()} ${Util.counter().name}")
    val s = Scaler(3)
    println("${s.scaleAll(listOf(1, 2))} ${s.scaleAllThis(listOf(5))}")
    val ref = s.totalRef()
    println("${ref.get()} ${ref.name}")
    ref.set(100)
    println("${s.total} ${s.kRef().get()}")
    println(s.Report().lines(listOf(1, 10)))
    println(Scaler.parseAll(listOf("7", "8")))
    println(listOf("9").map(Scaler.Companion::parse).map { it.k })
    with(Scaler(10)) { println(listOf(1, 2).map(::scale)) }
}
