import java.util.concurrent.atomic.AtomicInteger

fun main() {
    val make: () -> AtomicInteger = ::AtomicInteger
    val list: (Array<out Int>) -> List<Int> = ::listOf
    val options = Regex::options
    println("" + make + list(arrayOf(1)) + options)
}
