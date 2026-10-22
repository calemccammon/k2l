import java.math.BigDecimal
import java.math.BigInteger
import java.util.PriorityQueue
import java.util.TreeMap
import kotlin.math.ulp
import kotlin.reflect.typeOf
import kotlin.time.Duration.Companion.seconds
import kotlin.time.TimeSource
import kotlin.time.measureTime

// Library areas k2l does not translate (big numbers, java.*, kotlin.time, reflection, JVM details): each use is a compile
// error naming the API, as TypeScriptToLua reports an unsupported property.

fun bigNumbers() {
    println(BigInteger("123") + BigInteger.ONE)
    println(BigDecimal("1.5"))
    println(10.toBigInteger())
}

fun time() {
    println(2.seconds)
    println(measureTime { })
    println(TimeSource.Monotonic.markNow())
}

fun javaUtil() {
    val queue = PriorityQueue<Int>()
    val tree = TreeMap<String, Int>()
    println(java.util.Collections.max(listOf(1, 2)))
    println(Integer.toHexString(255))
    println(Math.addExact(1, 2))
    println(listOf(1, 2).stream().count())
    println(sortedMapOf(1 to "a").firstKey())
}

fun reflection(x: Any) {
    println(x::class.qualifiedName)
    println(x.javaClass.name)
    println(typeOf<List<Int>>())
    val f = ::bigNumbers
    println(f.name)
}

// JVM details that have no Lua counterpart: IEEE bit patterns, array element types, UTF-16 surrogates, the deep-recursion
// trampoline and exceptions nothing throws
fun jvmDetails(x: Any, c: Char) {
    println(1.5.toBits())
    println(Double.fromBits(0L))
    println(1.0.ulp)
    println(x is IntArray)
    println(c.isSurrogate())
    println(DeepRecursiveFunction<Int, Int> { it }(1))
    println(ConcurrentModificationException("changed"))
}

fun main() {
    bigNumbers()
    time()
    javaUtil()
    reflection(1)
    jvmDetails(1, 'c')
}
