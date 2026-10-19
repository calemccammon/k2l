// Stream members k2l does not map are reported.
import java.util.stream.Collectors
import java.util.stream.Stream

fun main() {
    val list = listOf(1, 2, 3)
    println(Stream.of(1, 2).spliterator().estimateSize())
    println(list.stream().collect(Collectors.teeing(Collectors.counting(), Collectors.toList()) { a, b -> "$a $b" }))
    println(list.stream().collect(Collectors.groupingByConcurrent { it % 2 }))
}
