// A reference to a library constructor works for every class whose constructor call does.
fun main() {
    val builder: (String) -> StringBuilder = ::StringBuilder
    println(builder("ab").append("c"))
    val lists: () -> ArrayList<Int> = ::ArrayList
    val s = lists()
    s.add(1)
    s.add(2)
    println("${s.removeLast()} $s")
    val indexed: (Int, String) -> IndexedValue<String> = ::IndexedValue
    println(listOf("x", "y").mapIndexed(indexed))
    val anys = List(2) { ::Any }.map { it() }
    println(anys[0] == anys[1])
    val pair: (String, Int) -> Pair<String, Int> = ::Pair
    println(listOf(1 to "a", 2 to "b").map { (n, t) -> pair(t, n) })
}
