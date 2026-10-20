// typeOf<T>() without kotlin-reflect: a KType that prints with JVM names, compares by its classifier, arguments and
// nullability, and lists its arguments.

import kotlin.reflect.KType
import kotlin.reflect.typeOf

class Outer {
    class Nested
}

data class Box<T>(val v: T)

inline fun <reified T> show() {
    val t = typeOf<T>()
    println("$t | ${t.isMarkedNullable} | ${t.classifier} | ${t.arguments} | ${t.arguments.map { it.type }}")
}

inline fun <reified T> key(): KType = typeOf<T>()

fun main() {
    show<Int>()
    println("${typeOf<Int?>()} ${typeOf<Int?>().isMarkedNullable}")
    show<String>()
    show<Any>()
    show<List<Int>>()
    show<MutableList<String?>>()
    show<Map<String, List<Box<Int>>>>()
    show<Array<String>>()
    show<IntArray>()
    show<Outer.Nested>()
    show<Box<*>>()
    show<Box<out Number>>()
    show<Box<in Int>>()
    show<Map.Entry<String, Int>>()
    show<(Int) -> String>()
    show<Unit>()
    show<Long>()
    show<Double>()
    show<Char>()
    show<Boolean>()
    show<Set<Outer>>()
    val m = mapOf(key<Int>() to "int", key<List<String>>() to "list of string")
    println(m[typeOf<Int>()])
    println(m[typeOf<List<String>>()])
    println(m[typeOf<List<Int>>()])
    println(key<Int>() == key<Int?>())
    println(key<List<Int>>().hashCode() == typeOf<List<Int>>().hashCode())
}
