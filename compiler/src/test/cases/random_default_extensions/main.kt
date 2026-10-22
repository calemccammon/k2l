// The kotlin.random extensions called on the `Random` companion (Random.Default) itself, not on an instance.
import kotlin.random.Random
import kotlin.random.nextInt
import kotlin.random.nextLong

fun main() {
    println(Random.nextInt(1..6) in 1..6)
    println(Random.nextInt(5 until 6))
    println(Random.Default.nextInt(3..3))
    println(Random.nextLong(10L..20L) in 10L..20L)
    println(Random.nextLong(7L..7L))
    // the instance forms still draw from their receiver
    val seeded = Random(42)
    val again = Random(42)
    println(seeded.nextInt(0..1000) == again.nextInt(0..1000))
}
