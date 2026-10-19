import kotlin.reflect.KMutableProperty1
import kotlin.reflect.KProperty0
import kotlin.reflect.KProperty1

class Person(val name: String, var age: Int) {
    fun greet(other: String) = "hi $other from $name"
}

object Config {
    var level = 3
    val title = "cfg"
}

var counter = 10
val label = "top"

fun twice(x: Int) = x * 2

fun describe(p: KProperty1<Person, *>, who: Person): String = "${p.name}=${p.get(who)}"

fun main() {
    val people = listOf(Person("ann", 30), Person("bob", 25))

    val nameRef = Person::name
    val ageRef: KMutableProperty1<Person, Int> = Person::age
    println(nameRef.name)
    println(ageRef.name)
    println(nameRef.get(people[0]))
    println(nameRef(people[1]))
    println(ageRef.get(people[1]))
    ageRef.set(people[1], 26)
    println(people[1].age)
    println(people.map(Person::name))
    println(people.sumOf(Person::age))
    println(describe(Person::name, people[0]))
    println(describe(Person::age, people[1]))

    val bound: KProperty0<String> = people[0]::name
    println(bound.name)
    println(bound.get())
    println(bound())
    val boundAge = people[0]::age
    boundAge.set(31)
    println(people[0].age)

    println(Config::level.name)
    println(Config::level.get())
    println(::counter.name)
    println(::counter.get())
    println(::label.get())

    println(::twice.name)
    println(Person::greet.name)
    println(people[0]::greet.name)
    println(listOf(1, 2).map(::twice))
}
