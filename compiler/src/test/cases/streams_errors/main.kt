import java.util.Arrays
import java.util.stream.IntStream
import java.util.stream.LongStream
import java.util.stream.Stream

fun main() {
    val list = listOf(1, 2, 3)
    println(LongStream.range(0, 3).sum())
    println(Arrays.stream(longArrayOf(1, 2)).sum())
    println(list.parallelStream().count())
    println(Stream.of(1, 2).iterator().hasNext())
    println(IntStream.range(0, 3).summaryStatistics().max)
    println(IntStream.range(0, 3).mapToLong { it.toLong() }.sum())
    println(Stream.of(1, 2).flatMapToInt { IntStream.of(it) }.sum())
    println(list.stream().collect(java.util.stream.Collectors.summingLong { it.toLong() }))
}
