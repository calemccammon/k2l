// Any.toString() of a class without its own toString: the JVM class name and the hash code in hex. The hash differs
// between runs, so only its shape is printed.
package app

class P(val x: Int)

class Hashed(val id: Int) {
    override fun hashCode() = id * 31
}

open class Base

class Derived : Base()

class Outer {
    class Nested

    inner class Inner
}

object Singleton

data class D(val v: Int)

enum class E { A, B }

class Problem(msg: String) : Exception(msg)

interface Shape

class Square : Shape

val hash = Regex("@[0-9a-f]+")

fun shape(s: String) = s.replace(hash, "@<hex>")

fun main() {
    val p = P(1)
    println(shape(p.toString()))
    println(shape("$p"))
    println(shape(listOf(p, Derived()).toString()))
    println(shape(mapOf("k" to Outer.Nested()).toString()))
    println(shape(Outer().Inner().toString()))
    println(shape(Singleton.toString()))
    println(shape((Square() as Shape).toString()))
    val any: Any = p
    println(shape(any.toString()))
    println(p.toString() == p.toString())
    println(p.toString() == "app.P@" + Integer.toHexString(p.hashCode()))
    println(p.hashCode() == p.hashCode())
    println(P(1).toString() != p.toString())
    // toString uses an overridden hashCode
    println(Hashed(2).toString() + " " + Hashed(3))
    // data classes, enums and exceptions keep their own toString
    println("${D(1)} ${E.B} ${Problem("boom")}")
    println(shape(StringBuilder().append(p).toString()))
}
