interface Shape { fun area(): Double }
open class Base(val id: Int) {
    open fun weight(): Int = id
    fun twice(): Int = weight() * 2
}
open class Mid(id: Int) : Base(id) { override fun weight(): Int = super.weight() + 1 }
class Leaf(id: Int) : Mid(id), Shape {
    override fun weight(): Int = super.weight() + 2
    override fun area(): Double = id * 1.5
}
class Counter { var n = 0; fun inc() { n++ } }

fun main() {
    val leaves = Array(1000) { Leaf(it) }
    var total = 0L
    var area = 0.0
    for (r in 0 until 1000) {
        for (l in leaves) {
            total += l.twice()
            area += l.area()
            total += l.id
        }
    }
    println(total)
    println(area)
    val c = Counter()
    for (i in 0 until 3000000) c.inc()
    println(c.n)
    var x = 0
    val f = { a: Int -> a + 1 }
    for (i in 0 until 3000000) x = f(x)
    println(x)
}
