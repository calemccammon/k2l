import java.util.stream.IntStream
import java.util.stream.Stream

fun main() {
    // the stages run element by element, in the JDK's order
    val result = Stream.of("a", "bb", "ccc", "dddd")
        .filter { println("filter $it"); it.length > 1 }
        .map { println("map $it"); it.uppercase() }
        .peek { println("peek $it") }
        .toList()
    println(result)

    // sorted waits for all the elements before it
    Stream.of(3, 1, 2)
        .peek { println("before $it") }
        .sorted()
        .peek { println("after $it") }
        .forEach { println("each $it") }

    // limit and findFirst stop pulling
    println(Stream.of(1, 2, 3, 4, 5).peek { println("see $it") }.limit(2).toList())
    println(IntStream.range(0, 100).peek { println("int $it") }.filter { it % 2 == 1 }.findFirst())
    println(Stream.of(1, 2, 3, 4).peek { println("any $it") }.anyMatch { it == 2 })
    println(Stream.of(1, 2, 3, 4).peek { println("all $it") }.allMatch { it < 3 })
    println(Stream.of(1, 2, 3, 4).peek { println("none $it") }.noneMatch { it == 3 })

    // nothing runs until the terminal operation
    val pending = Stream.of(1, 2, 3).map { println("never $it"); it }.filter { it > 1 }
    println("built")
    println(pending.count())

    // count() of a sized stream does not run the stages (JDK 9+)
    println(Stream.of(1, 2, 3).peek { println("sized $it") }.count())
    println(listOf(1, 2, 3).stream().map { println("sized map $it"); it }.count())
    println(IntStream.range(0, 4).peek { println("range $it") }.count())
    println(Stream.of(1, 2, 3, 4).peek { println("skipped $it") }.skip(1).limit(2).count())
    println(Stream.of(1, 2, 3, 4).peek { println("filtered $it") }.filter { it > 1 }.count())
    println(Stream.of(1, 2, 3).peek { println("sorted $it") }.sorted().count())
    println(Stream.of(1, 2, 3, 2).peek { println("distinct $it") }.distinct().count())

    // infinite streams
    var calls = 0
    println(Stream.iterate(1) { calls++; it + 1 }.limit(3).toList())
    println(calls)
    println(Stream.generate { "x" }.limit(3).toList())
    println(Stream.iterate(1) { it * 2 }.filter { it > 100 }.findFirst().get())

    // flatMap pulls the inner streams lazily
    println(Stream.of(1, 2, 3).flatMap { n -> Stream.of(n, n * 10).peek { println("inner $it") } }.limit(3).toList())

    // a stream is consumed by its first operation
    val once = Stream.of(1, 2, 3)
    println(once.count())
    try {
        once.forEach { println(it) }
    } catch (e: IllegalStateException) {
        println("reuse: ${e.message}")
    }
    val filtered = Stream.of(1, 2, 3).filter { it > 1 }
    println(filtered.toList())
    try {
        filtered.map { it * 2 }
    } catch (e: IllegalStateException) {
        println("reuse: ${e.message}")
    }
    val ints = IntStream.range(0, 3)
    val mapped = ints.map { it + 1 }
    try {
        ints.sum()
    } catch (e: IllegalStateException) {
        println("reuse: ${e.message}")
    }
    println(mapped.sum())

    // errors
    try {
        Stream.of(1).limit(-1)
    } catch (e: IllegalArgumentException) {
        println("limit: ${e.message}")
    }
    try {
        IntStream.empty().max().asInt
    } catch (e: NoSuchElementException) {
        println("max: ${e.message}")
    }
    try {
        Stream.of(1, 2).findFirst().orElseThrow { IllegalStateException("none") }
        Stream.empty<Int>().findFirst().orElseThrow { IllegalStateException("none") }
    } catch (e: IllegalStateException) {
        println("orElseThrow: ${e.message}")
    }
}
