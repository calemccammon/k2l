// LongStream, parallelStream() (sequential here: only order-independent results and forEachOrdered are printed),
// Stream.iterator() and the summary statistics of streams and collectors.
import java.util.DoubleSummaryStatistics
import java.util.IntSummaryStatistics
import java.util.LongSummaryStatistics
import java.util.stream.Collectors
import java.util.stream.IntStream
import java.util.stream.LongStream
import java.util.stream.Stream

fun longStreams() {
    println(LongStream.range(1L, 6L).sum())
    println(LongStream.rangeClosed(1L, 5L).map { it * it }.boxed().toList())
    println(LongStream.of(3L, 1L, 2L).sorted().toArray().toList())
    println("${LongStream.of(5L, 9L, 2L).max().asLong} ${LongStream.of(5L, 9L, 2L).min().asLong} ${LongStream.empty().max()}")
    println("${LongStream.of(1L, 2L).average().asDouble} ${LongStream.empty().average()} ${LongStream.of(7L).max()}")
    println(LongStream.iterate(1L) { it * 3 }.limit(5).boxed().toList())
    println(IntStream.range(0, 4).asLongStream().map { it * 1_000_000_000L }.sum())
    println(IntStream.range(0, 4).mapToLong { it * 10L }.boxed().toList())
    println(Stream.of("a", "bb", "ccc").mapToLong { it.length.toLong() }.sum())
    println(longArrayOf(4L, 5L, 6L).let { java.util.Arrays.stream(it).filter { x -> x % 2 == 0L }.count() })
    println(LongStream.rangeClosed(1L, 20L).reduce(1L) { a, b -> a * b })
    println(LongStream.of(1L, 2L, 3L).mapToObj { "n$it" }.collect(Collectors.joining(",")))
    println(LongStream.of(1L, 2L, 3L).asDoubleStream().sum())
    println(LongStream.of(10L, 20L).mapToInt { (it / 10).toInt() }.sum())
    println(listOf(1L, 2L, 3L).stream().collect(Collectors.summingLong { it }))
    println(listOf("a", "bb").stream().collect(Collectors.averagingLong { it.length.toLong() }))
    println(Stream.of(1, 2).flatMapToInt { IntStream.of(it, it * 10) }.boxed().toList())
    println(Stream.of(3L, 4L).flatMapToLong { LongStream.range(0L, it) }.count())
}

fun parallel() {
    val numbers = (1..100).toList()
    println(numbers.parallelStream().mapToInt { it }.sum())
    println(numbers.parallelStream().filter { it % 7 == 0 }.count())
    println(numbers.parallelStream().map { it * 2 }.toList().take(5))
    println(numbers.parallelStream().reduce(0) { a, b -> a + b })
    println(numbers.parallelStream().collect(Collectors.toSet()).size)
    val ordered = mutableListOf<Int>()
    numbers.parallelStream().filter { it > 95 }.forEachOrdered { ordered += it }
    println(ordered)
    println("${numbers.parallelStream().isParallel} ${numbers.stream().isParallel} ${numbers.stream().parallel().isParallel}")
    println(numbers.parallelStream().anyMatch { it == 50 })
    println(numbers.stream().parallel().max(Comparator.naturalOrder()).get())
}

fun iterators() {
    val it = Stream.of("x", "y", "z").map { it.uppercase() }.iterator()
    while (it.hasNext()) print(it.next())
    println()
    val seen = mutableListOf<String>()
    val lazy = Stream.of(1, 2, 3).peek { seen += "peek $it" }.iterator()
    seen += "made"
    println("${lazy.hasNext()} $seen")
    println("${lazy.next()} ${lazy.next()} $seen")
    for (n in IntStream.range(0, 3).iterator()) print("$n ")
    println()
    val ints = IntStream.of(4, 5).iterator()
    println("${ints.nextInt()} ${ints.next()} ${ints.hasNext()}")
    try {
        ints.next()
    } catch (e: NoSuchElementException) {
        println("done")
    }
}

fun statistics() {
    val ints = IntStream.of(4, 8, 15, 16, 23, 42).summaryStatistics()
    println(ints)
    println("${ints.count} ${ints.sum} ${ints.min} ${ints.max} ${ints.average}")
    println(IntStream.empty().summaryStatistics())
    println(IntStream.of(Int.MAX_VALUE, Int.MAX_VALUE).summaryStatistics().sum)
    println(LongStream.of(5L, 7L).summaryStatistics())
    println(LongStream.empty().summaryStatistics().count)
    val doubles = java.util.stream.DoubleStream.of(1.5, 2.25, 3.0).summaryStatistics()
    println(doubles)
    println("${doubles.sum} ${doubles.average} ${doubles.min} ${doubles.max}")
    println(java.util.stream.DoubleStream.empty().summaryStatistics())
    val words = listOf("kotlin", "lua", "jvm", "transpiler")
    println(words.stream().collect(Collectors.summarizingInt { it.length }))
    println(words.stream().collect(Collectors.summarizingLong { it.length.toLong() }).max)
    println(words.stream().collect(Collectors.summarizingDouble { it.length / 2.0 }))
    val manual = IntSummaryStatistics()
    manual.accept(3)
    manual.accept(-1)
    val other = IntSummaryStatistics()
    other.accept(10)
    manual.combine(other)
    println("$manual ${manual.average}")
    val longs = LongSummaryStatistics()
    longs.accept(2L)
    longs.accept(4)
    println(longs)
    val ds = DoubleSummaryStatistics()
    ds.accept(0.1)
    ds.accept(0.2)
    println("${ds.sum} $ds")
    println(words.stream().mapToInt { it.length }.summaryStatistics().average)
}

fun main() {
    longStreams()
    parallel()
    iterators()
    statistics()
}
