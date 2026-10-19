// `is` and `as` against nullable types hold for null, also with a reified type parameter (`is T` with T = String?,
// `as T?` with T = Person).
data class Person(val name: String)

inline fun <reified T> Any?.isA(): Boolean = this is T

inline fun <reified T> List<*>.firstAs(): T? = firstOrNull { it is T } as T?

inline fun <reified T> List<*>.countOf(): Int = count { it is T? }

fun kind(x: Any?): String = when (x) {
    is Int -> "int"
    is String? -> "string or null"
    else -> "other"
}

fun main() {
    val none: Any? = null
    val text: Any? = "t"
    val num: Any? = 4
    println("${none is String?} ${none is String} ${text is String?} ${num is String?} ${num !is Int?}")
    println("${kind(null)} ${kind("s")} ${kind(1)} ${kind(Person("p"))}")
    println("${null.isA<String?>()} ${null.isA<String>()} ${"s".isA<String?>()} ${1.isA<String?>()} ${Person("a").isA<Person?>()}")
    println("${listOf(1, "x", Person("p")).firstAs<Person>()} ${listOf(1).firstAs<Person>()} ${listOf<Any?>(null, 2).firstAs<Int>()}")
    println("${listOf(null, "a", 1, null).countOf<String>()} ${listOf(1, 2).countOf<String>()}")
    val s = none as String?
    val p = text as? Int?
    println("$s $p ${num as? Int?}")
    try {
        println(num as String?)
    } catch (e: ClassCastException) {
        println("ClassCastException")
    }
}
