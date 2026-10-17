data class Person(val name: String, val age: Int, val email: String?)

data class Pair2(val first: Int, val second: Double)

data class Wrapper(val inner: Person)

fun main() {
    val p = Person("Ada", 36, null)
    println(p)
    val q = p.copy(age = 37)
    println(q)
    println(p == q)
    println(p == p.copy())
    println(p != q)
    println(q.copy(email = "ada@example.com", name = "Ada L."))
    println(p.component1() + " " + p.component2())
    println(Pair2(1, 2.5))
    val w1 = Wrapper(p)
    val w2 = Wrapper(Person("Ada", 36, null))
    println(w1 == w2)
    println(w1)
    val maybe: Person? = null
    println(maybe == p)
    println(p.equals(q))
}
