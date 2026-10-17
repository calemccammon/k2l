import kotlin.reflect.KProperty

class Provider {
    operator fun provideDelegate(thisRef: Any?, property: KProperty<*>) = Plain()
}

class Plain {
    operator fun getValue(thisRef: Any?, property: KProperty<*>) = 1
}

class NoMember

operator fun NoMember.getValue(thisRef: Any?, property: KProperty<*>) = 2

open class Base {
    open val x: Int by lazy { 3 }
}

val a by Provider()
val b by NoMember()

fun main() {
    println(a + b)
}
