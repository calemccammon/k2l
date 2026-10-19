import kotlin.reflect.KCallable
import kotlin.reflect.KFunction1
import kotlin.reflect.KFunction2
import kotlin.reflect.KProperty
import kotlin.reflect.KProperty1

// toString(), == and hashCode() of function and property references and of the KProperty passed to delegates

class Person(val name: String, var age: Int) {
    fun greet(other: String) = "hi $other from $name"
}

data class Point(val x: Int, val y: Int) {
    fun norm() = x * x + y * y
}

object Config {
    var level = 3
}

var counter = 10

fun twice(x: Int) = x * 2

fun twice(s: String) = s + s

fun negate(x: Int) = -x

val String.shout get() = uppercase() + "!"

class Seen {
    var last: KProperty<*>? = null

    operator fun getValue(thisRef: Any?, property: KProperty<*>): String {
        last = property
        return property.toString()
    }
}

val seen = Seen()

class Box {
    val content by seen
    val other by seen
}

val topLevel by seen

fun main() {
    // toString
    println(Person::name)
    println(Person("a", 1)::age)
    println(::counter)
    println(Config::level)
    println(String::shout)
    println("x"::shout)
    println(String::length)
    println("abc"::length)
    println(List<Int>::size)
    val t: KFunction1<Int, Int> = ::twice
    println(t)
    println("${Person::greet}")
    println(::negate.toString())
    println(::Person)
    val up: KFunction1<String, String> = String::uppercase
    println(up)
    val pl: KFunction2<Int, Int, Int> = Int::plus
    println(pl)
    println(listOf(1)::contains)
    val callables: List<KCallable<*>> = listOf(::negate, Person::name, String::length)
    println(callables)

    // ==
    println(Person::name == Person::name)
    println(Person::name == Person::age)
    val ann = Person("ann", 30)
    println(ann::name == ann::name)
    println(ann::name == Person("ann", 30)::name)
    println(Point(1, 2)::x == Point(1, 2)::x)
    println(Point(1, 2)::norm == Point(1, 2)::norm)
    println(Point(1, 2)::norm == Point(2, 1)::norm)
    println(Config::level == Config::level)
    println(::counter == ::counter)
    println(String::length == String::length)
    println("ab"::length == "ab"::length)
    println("ab"::length == "cd"::length)
    println(String::shout == String::shout)
    val t2: KFunction1<Int, Int> = ::twice
    val ts: KFunction1<String, String> = ::twice
    println(t == t2)
    println(t == ts)
    println(t != ::negate)
    println(Person::greet == Person::greet)
    println(ann::greet == ann::greet)
    val up2: KFunction1<String, String> = String::uppercase
    println(up == up2)
    val pName: KProperty1<Person, String> = Person::name
    println(pName.equals(Person::name))
    println(listOf(::negate, ::negate).distinct().size)
    println(setOf(Person::name, Person::name, Person::age).size)

    // hashCode agrees with ==
    println(::negate.hashCode() == ::negate.hashCode())
    println(Person::name.hashCode() == Person::name.hashCode())
    println(String::length.hashCode() == String::length.hashCode())

    // the KProperty passed to a delegate is the property's reference
    val box = Box()
    println(box.content)
    println(seen.last == Box::content)
    println(seen.last == Box::other)
    println(box.other)
    println(seen.last == Box::other)
    println(topLevel)
    println(seen.last == ::topLevel)
    println(seen.last?.name)
}
