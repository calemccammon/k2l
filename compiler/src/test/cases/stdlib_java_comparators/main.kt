// java.util.Comparator's primitive-keyed factories and nullsFirst/nullsLast, as Java code ported to Kotlin uses them
data class Employee(val name: String, val age: Int, val salary: Long, val rating: Double)

fun main() {
    val staff = listOf(
        Employee("Ann", 41, 5200, 4.5),
        Employee("Bob", 29, 4100, 3.9),
        Employee("Cid", 41, 4100, 4.8),
        Employee("Dee", 35, 6100, 3.9),
    )
    println(staff.sortedWith(Comparator.comparingInt { it.age }).map { it.name })
    println(staff.sortedWith(Comparator.comparingLong<Employee> { it.salary }.thenComparingInt { it.age }).map { it.name })
    println(staff.sortedWith(Comparator.comparingDouble<Employee> { it.rating }.thenComparingLong { it.salary }).map { it.name })
    println(staff.sortedWith(compareBy<Employee> { it.age }.thenComparingDouble { -it.rating }).map { it.name })
    val names = listOf("pear", null, "apple", null, "fig")
    println(names.sortedWith(Comparator.nullsFirst(naturalOrder<String>())))
    println(names.sortedWith(Comparator.nullsLast(Comparator.comparingInt<String> { it.length })))
}
