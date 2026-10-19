// LongStream and the Long collectors and statistics with --long64 emulate: exact beyond 2^53 on every target.
import java.util.LongSummaryStatistics
import java.util.stream.Collectors
import java.util.stream.LongStream

fun main() {
    val big = 4_000_000_000_000_000_000L
    println(LongStream.of(big, big, 1L).sum())
    println(LongStream.of(Long.MAX_VALUE, 1L).sum())
    println(LongStream.rangeClosed(Long.MAX_VALUE - 2, Long.MAX_VALUE).boxed().toList())
    println(LongStream.range(9_007_199_254_740_990L, 9_007_199_254_740_995L).map { it * 2 }.boxed().toList())
    println("${LongStream.of(big, -big, 3L).max().asLong} ${LongStream.of(big, -big, 3L).min().asLong}")
    println(LongStream.of(big, big).average().asDouble)
    println(LongStream.iterate(1L) { it * 10 }.limit(19).reduce(0L) { a, b -> a + b })
    println(LongStream.of(big, 2L).summaryStatistics())
    println(LongSummaryStatistics())
    val values = listOf(big, big, 7L)
    println(values.stream().collect(Collectors.summingLong { it }))
    println(values.stream().collect(Collectors.summarizingLong { it }).sum)
    println(values.stream().mapToLong { it / 1000 }.sum())
    println(values.parallelStream().mapToLong { it }.max().asLong)
}
