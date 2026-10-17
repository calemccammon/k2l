class Node(val value: Int, val next: Node?) {
    fun describe(): String = "Node($value)"
}

fun length(s: String?): Int = s?.length ?: -1

fun firstValue(n: Node?): Int? = n?.next?.value

fun orDefault(flag: Boolean?): Boolean = flag ?: true

fun parse(s: String?): Int {
    val text = s ?: return 0
    return text.length * 10
}

fun main() {
    println(length("abc"))
    println(length(null))
    val list = Node(1, Node(2, null))
    println(firstValue(list))
    println(firstValue(Node(3, null)))
    println(firstValue(null))
    println(orDefault(false))
    println(orDefault(null))
    println(parse("hello"))
    println(parse(null))
    var maybe: Node? = null
    maybe?.describe()
    println(maybe?.describe())
    maybe = list
    println(maybe?.describe())
    println(maybe!!.value)
    val s: String? = "x"
    if (s != null) println(s.length)
    val name: String? = null
    println(name ?: "anonymous")
    println((name ?: "a").length)
}
