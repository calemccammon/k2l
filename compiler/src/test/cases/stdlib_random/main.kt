import kotlin.random.Random

// Properties of Random that hold for any seed.
fun main() {
    val r = Random(42)
    var inRange = true
    repeat(200) {
        val i = r.nextInt(10)
        val j = r.nextInt(5, 8)
        val d = r.nextDouble()
        val e = r.nextDouble(2.0, 3.0)
       
        if (i !in 0..9 || j !in 5..7 || d < 0.0 || d >= 1.0 || e < 2.0 || e >= 3.0) inRange = false
    }
    println(inRange)

    val a = Random(7)
    val b = Random(7)
    println((1..20).map { a.nextInt(1000) } == (1..20).map { b.nextInt(1000) })
    println(Random(1).nextInt() == Random(1).nextInt())
    println(Random(1).nextDouble() == Random(1).nextDouble())
    println(Random(1).nextBoolean() == Random(1).nextBoolean())

    val seen = HashSet<Int>()
    repeat(500) { seen.add(r.nextInt(4)) }
    println(seen.size)
    var trues = 0
    repeat(1000) { if (r.nextBoolean()) trues++ }
    println(trues in 300..700)

    val xs = (1..20).toList()
    val shuffled = xs.shuffled(Random(3))
    println(shuffled.sorted() == xs)
    println(shuffled.size)
    println(xs.shuffled(Random(5)) == xs.shuffled(Random(5)))
    val ml = xs.toMutableList()
    ml.shuffle(Random(9))
    println(ml.sorted() == xs)
    println(xs.random(Random(2)) in xs)
    println(xs.randomOrNull(Random(2)) in xs)
    println(emptyList<Int>().randomOrNull())
    println((1..5).random(Random(1)) in 1..5)
    println(('a'..'e').random(Random(1)) in 'a'..'e')
    println("abc".random(Random(1)) in "abc")
    println(Random.nextInt(5) in 0..4)
    println(Random.nextInt(1, 3) in 1..2)
    println(Random.Default.nextDouble() < 1.0)
    try {
        Random(1).nextInt(0)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        Random(1).nextInt(5, 5)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        emptyList<Int>().random()
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
}
