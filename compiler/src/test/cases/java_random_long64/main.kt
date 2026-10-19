import java.util.Random

fun main() {
    val r = Random(42)
    println((1..5).map { r.nextLong() })
    val s = Random(-1L)
    println(s.nextLong())
    println(s.nextLong() % 1000)
    println(Random(1234567890123456789L).nextInt(100))
}
