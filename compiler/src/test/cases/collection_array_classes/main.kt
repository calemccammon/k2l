// Arrays know their JVM class at run time (held as Any), and print as [I@hash.
fun describe(x: Any): String = "${x::class.simpleName} ${x::class.qualifiedName} ${x.javaClass.name} ${x.javaClass.simpleName} ${x::class}"

fun <T> generic(x: T): String = (x as Any).javaClass.name

fun main() {
    val items: List<Any> = listOf(
        intArrayOf(1), IntArray(2), IntArray(2) { it }, longArrayOf(1), doubleArrayOf(1.0), booleanArrayOf(true),
        charArrayOf('a'), shortArrayOf(1), byteArrayOf(1), floatArrayOf(1f), arrayOf("a"), arrayOf(1, 2), Array(2) { "x$it" },
        arrayOfNulls<String>(2), emptyArray<Int>(), arrayOf(intArrayOf(1)), listOf("a").toTypedArray(), "ab".toCharArray(),
        listOf(1, 2).toIntArray(), arrayOf<Any>(1), intArrayOf(3, 1).sortedArray(), intArrayOf(1).copyOf(3),
        arrayOf("b", "a").copyOfRange(0, 1), uintArrayOf(1u),
    )
    for (x in items) println(describe(x))
    println(generic(intArrayOf(1)))
    println(generic(arrayOf("a")))
    val s = intArrayOf(1).toString()
    println(s.startsWith("[I@"))
    println("${arrayOf("a")}".startsWith("[Ljava.lang.String;@"))
    println(arrayOf(1).toString().startsWith("[Ljava.lang.Integer;@"))
    println(doubleArrayOf(1.0).toString().startsWith("[D@"))
    println(arrayOf(intArrayOf(1)).toString().startsWith("[[I@"))
    val a: Any = intArrayOf(1)
    val b: Any = arrayOf("a")
    println("${a is IntArray} ${a is Array<*>} ${b is IntArray} ${b is Array<*>} ${a is LongArray} ${b is Array<*>}")
    println("${intArrayOf(1).contentToString()} ${arrayOf(1, 2).contentToString()}")
    println(listOf(intArrayOf(1)).toString().startsWith("[[I@"))
    println(a.hashCode() == a.hashCode())
    println(a == intArrayOf(1))
}
