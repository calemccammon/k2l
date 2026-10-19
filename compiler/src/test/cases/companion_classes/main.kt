package app

// The class of a companion object value, and how KClass and Class objects print

class Outer {
    companion object {
        val z = 1
    }
}

class Named {
    companion object Factory {
        fun make() = Named()
    }
}

object Solo

interface Marker

class Impl : Marker

fun classOf(x: Any) = x::class

fun main() {
    val c = Outer.Companion
    println(c::class.simpleName)
    println(c::class.qualifiedName)
    println(c::class == Outer.Companion::class)
    println(c::class == Outer::class)
    println(c.javaClass.name)
    println(c.javaClass.simpleName)
    println(Outer.Companion::class.java.name)
    println(Outer.Companion::class.java == c.javaClass)
    println(classOf(c).simpleName)
    println(classOf(c) == Outer.Companion::class)
    println(classOf(Named.Factory).simpleName)
    println(classOf(Named.Factory).qualifiedName)
    println(classOf(Named.make()).simpleName)
    println(classOf(Solo).simpleName)
    println(Outer.Companion::class.isInstance(c))
    println(Outer.Companion::class.isInstance(Outer()))
    println(Outer::class.isInstance(c))
    println(Outer::class.isInstance(Outer()))
    val any: Any = Named
    println(any::class.simpleName)
    println(any is Named.Factory)
    println(Outer.z)

    // KClass prints like the JVM's without kotlin-reflect, Class like java.lang.Class
    println(Outer::class)
    println(Outer.Companion::class)
    println(Named.Factory::class)
    println(Solo::class)
    println(Marker::class)
    println(Impl()::class)
    println(c::class)
    println("${Outer::class}")
    println(Outer::class.java)
    println(Marker::class.java)
    println(Impl().javaClass)
    println(Outer.Companion::class.java)
    println(String::class)
    println(Int::class)
    println(Outer::class.java.kotlin == Outer::class)
    println(Impl().javaClass.kotlin.simpleName)
}
