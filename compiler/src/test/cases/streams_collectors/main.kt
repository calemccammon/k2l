import java.util.Optional
import java.util.OptionalDouble
import java.util.OptionalInt
import java.util.stream.Collectors
import java.util.stream.Stream

data class Person(val name: String, val age: Int, val city: String)

fun collectors(people: List<Person>) {
    println(people.stream().map { it.name }.collect(Collectors.toList()))
    println(people.stream().map { it.city }.collect(Collectors.toSet()))
    println(people.stream().map { it.name }.collect(Collectors.joining()))
    println(people.stream().map { it.name }.collect(Collectors.joining("|")))
    println(people.stream().map { it.name }.collect(Collectors.joining(", ", "[", "]")))
    println(people.stream().collect(Collectors.counting()))
    println(people.stream().collect(Collectors.groupingBy { it.city }))
    println(people.stream().collect(Collectors.groupingBy({ it.city }, Collectors.counting())))
    println(people.stream().collect(Collectors.groupingBy({ it.city }, Collectors.mapping({ it.name }, Collectors.toList()))))
    println(people.stream().collect(Collectors.groupingBy({ it.age / 10 }, Collectors.summingInt { it.age })))
    println(people.stream().collect(Collectors.groupingBy({ it.city }, Collectors.averagingInt { it.age })))
    println(people.stream().collect(Collectors.partitioningBy { it.age >= 30 }))
    println(people.stream().collect(Collectors.partitioningBy({ it.age >= 30 }, Collectors.counting())))
    println(people.stream().collect(Collectors.toMap({ it.name }, { it.age })))
    println(people.stream().collect(Collectors.toMap({ it.city }, { it.age }, { a, b -> a + b })))
    println(people.stream().collect(Collectors.summingInt { it.age }))
    println(people.stream().collect(Collectors.averagingInt { it.age }))
    println(people.stream().collect(Collectors.averagingDouble { it.age * 1.5 }))
    println(people.stream().collect(Collectors.summingDouble { it.age / 10.0 }))
    println(people.stream().collect(Collectors.maxBy(compareBy<Person> { it.age })))
    println(people.stream().collect(Collectors.minBy(compareBy<Person> { it.age })).get().name)
    println(Stream.empty<Person>().collect(Collectors.maxBy(compareBy<Person> { it.age })))
    println(people.stream().map { it.age }.collect(Collectors.collectingAndThen(Collectors.toList()) { it.size }))
    println(people.stream().map { it.name }.collect(Collectors.toCollection { java.util.TreeSet<String>() }))
    println(Stream.of(1, 2, 3, 4).collect({ ArrayList<Int>() }, { list, x -> list.add(x * x) }, { a, b -> a.addAll(b) }))
    println(Stream.empty<String>().collect(Collectors.joining(",")))
    println(Stream.empty<String>().collect(Collectors.groupingBy { it.length }))
    try {
        Stream.of(1, 1).collect(Collectors.toMap({ it }, { "v$it" }))
    } catch (e: IllegalStateException) {
        println(e.message)
    }
}

fun optionals() {
    val present = Optional.of("value")
    val empty = Optional.empty<String>()
    println(present)
    println(empty)
    println(present.isPresent)
    println(empty.isPresent)
    println(present.isEmpty)
    println(present.get())
    println(empty.orElse("other"))
    println(empty.orElseGet { "computed" })
    println(present.map { it.length })
    println(empty.map { it.length })
    println(present.filter { it.startsWith("v") })
    println(present.filter { it.startsWith("x") })
    println(Optional.ofNullable<String>(null))
    println(Optional.ofNullable("n"))
    present.ifPresent { println("has $it") }
    empty.ifPresent { println("has $it") }
    present.ifPresentOrElse({ println("yes $it") }, { println("no") })
    empty.ifPresentOrElse({ println("yes $it") }, { println("no") })
    println(present == Optional.of("value"))
    println(present == empty)
    println(present.flatMap { Optional.of(it + "!") })
    try {
        empty.get()
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
    val oi = OptionalInt.of(4)
    println(oi)
    println(oi.asInt)
    println(oi.orElse(0))
    println(OptionalInt.empty())
    println(OptionalInt.empty().orElse(-1))
    println(OptionalInt.empty().isPresent)
    val od = OptionalDouble.of(2.5)
    println(od)
    println(od.asDouble)
    println(OptionalDouble.empty())
    println(OptionalDouble.empty().orElse(0.5))
}

fun main() {
    val people = listOf(
        Person("Ann", 31, "Oslo"),
        Person("Bob", 25, "Rome"),
        Person("Cid", 40, "Oslo"),
        Person("Dee", 27, "Lima"),
        Person("Eve", 38, "Rome"),
        Person("Fay", 28, "Lima"),
    )
    collectors(people)
    optionals()
}
