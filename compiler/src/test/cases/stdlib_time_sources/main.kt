import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TestTimeSource
import kotlin.time.TimeMark
import kotlin.time.TimeSource
import kotlin.time.TimedValue
import kotlin.time.measureTime
import kotlin.time.measureTimedValue

// Time sources, marks and measureTime. Real timings vary, so only their properties are printed; TestTimeSource is exact.
fun work(n: Int): Long {
    var acc = 0L
    for (i in 1..n) acc += i.toLong() * i
    return acc
}

class Stopwatch(private val source: TimeSource) {
    private var start: TimeMark = source.markNow()
    fun reset() {
        start = source.markNow()
    }
    fun elapsed(): Duration = start.elapsedNow()
}

fun main() {
    // measureTime and measureTimedValue on the monotonic clock
    val took = measureTime { work(10_000) }
    println("measureTime non-negative: ${!took.isNegative()}, finite: ${took.isFinite()}")
    val (value, duration) = measureTimedValue { work(1_000) }
    println("measureTimedValue: $value, non-negative: ${duration >= Duration.ZERO}")
    val timed: TimedValue<String> = measureTimedValue { "done" }
    println("timed value: ${timed.value}, below a minute: ${timed.duration < 60.seconds}")

    // marks of TimeSource.Monotonic
    val mark = TimeSource.Monotonic.markNow()
    work(1_000)
    val elapsed = mark.elapsedNow()
    println("elapsed non-negative: ${!elapsed.isNegative()}, passed: ${mark.hasPassedNow()}, not passed: ${mark.hasNotPassedNow()}")
    val later = mark + 1.seconds
    println("future mark: passed ${later.hasPassedNow()}, not passed ${later.hasNotPassedNow()}")
    println("mark difference: ${later - mark}, order: ${mark < later}, ${later > mark}")
    val earlier = mark - 2.seconds
    println("earlier: ${earlier - mark}, ${earlier.elapsedNow() >= 2.seconds}")
    val source: TimeSource = TimeSource.Monotonic
    println("source: $source")
    val m2 = source.markNow()
    println("generic mark elapsed non-negative: ${!m2.elapsedNow().isNegative()}")
    println("measured on a source: ${!source.measureTime { work(100) }.isNegative()}")

    // TestTimeSource: time moves only when told to
    val test = TestTimeSource()
    val start = test.markNow()
    test += 1500.milliseconds
    println("test elapsed: ${start.elapsedNow()}")
    val stopwatch = Stopwatch(test)
    test += 2.seconds
    println("stopwatch: ${stopwatch.elapsed()}")
    stopwatch.reset()
    test += 250.milliseconds
    println("after reset: ${stopwatch.elapsed()}, total: ${start.elapsedNow()}")
    val deadline = test.markNow() + 1.seconds
    println("deadline passed: ${deadline.hasPassedNow()}")
    test += 1.seconds
    println("deadline passed: ${deadline.hasPassedNow()}, over by: ${deadline.elapsedNow()}")
    val t1 = test.markNow()
    test += 3.seconds
    val t2 = test.markNow()
    println("t2 - t1 = ${t2 - t1}, t1 < t2: ${t1 < t2}, compare: ${t2.compareTo(t1) > 0}")
    val measured = test.measureTime { test += 42.milliseconds }
    println("test measureTime: $measured")
    val tv = test.measureTimedValue {
        test += 7.seconds
        "ok"
    }
    println("test measureTimedValue: $tv, ${tv.value}, ${tv.duration}")
    println("copy: ${tv.copy(value = "changed")}, equal: ${tv == TimedValue("ok", 7.seconds)}")
}
