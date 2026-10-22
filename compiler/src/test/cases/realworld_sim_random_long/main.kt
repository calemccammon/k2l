import kotlin.random.Random
import kotlin.random.nextLong

// Procedural world generation driven by 64-bit seeds: a Random seeded with Longs,
// a SplitMix64 hash for per-chunk seeds, and Long draws that need every one of their 64 bits.

object SplitMix {
    fun mix(seed: Long): Long {
        var z = seed + -7046029254386353131L
        z = (z xor (z ushr 30)) * -4658895280553007687L
        z = (z xor (z ushr 27)) * -7723592293110705685L
        return z xor (z ushr 31)
    }

    fun chunkSeed(world: Long, cx: Int, cy: Int): Long = mix(world xor (cx.toLong() shl 32) xor (cy.toLong() and 0xFFFFFFFFL))
}

enum class Biome(val symbol: Char) { OCEAN('~'), PLAINS('.'), FOREST('T'), HILLS('n'), DESERT(':'), PEAK('^') }

class Chunk(val cx: Int, val cy: Int, seed: Long) {
    val heights = IntArray(16)
    val biome: Biome
    val ore: Long

    init {
        val rng = Random(seed)
        for (i in heights.indices) heights[i] = rng.nextInt(0, 256)
        val avg = heights.average()
        val moisture = rng.nextDouble()
        biome = when {
            avg < 90 -> Biome.OCEAN
            avg > 160 -> Biome.PEAK
            avg > 140 -> Biome.HILLS
            moisture < 0.3 -> Biome.DESERT
            moisture < 0.6 -> Biome.PLAINS
            else -> Biome.FOREST
        }
        ore = rng.nextLong(1L shl 40, 1L shl 62)
    }
}

class World(val seed: Long) {
    private val chunks = HashMap<Pair<Int, Int>, Chunk>()

    fun chunk(cx: Int, cy: Int): Chunk = chunks.getOrPut(cx to cy) { Chunk(cx, cy, SplitMix.chunkSeed(seed, cx, cy)) }

    fun render(size: Int): List<String> = (0 until size).map { y -> (0 until size).map { x -> chunk(x - 2, y - 2).biome.symbol }.joinToString("") }

    fun totalOre(size: Int): Long {
        var total = 0L
        for (y in 0 until size) for (x in 0 until size) total += chunk(x - 2, y - 2).ore
        return total
    }
}

fun longDraws() {
    println("-- long draws")
    val r = Random(Long.MAX_VALUE)
    println(List(3) { r.nextLong() })
    println(List(3) { r.nextLong(Long.MAX_VALUE) })
    println(List(3) { r.nextLong(1L shl 53) })
    println(List(3) { r.nextLong(1L shl 62) })
    println(List(3) { r.nextLong(3_000_000_000_000_000_001L) })
    println(List(3) { r.nextLong(Long.MIN_VALUE, Long.MAX_VALUE) })
    println(List(3) { r.nextLong(-1L shl 60, 1L shl 60) })
    println(List(3) { r.nextLong(0L..Long.MAX_VALUE) })
    println(List(3) { r.nextLong(Long.MIN_VALUE..Long.MAX_VALUE) })
    println(List(3) { r.nextLong(10L..20L) })
    println(List(2) { (1L..Long.MAX_VALUE).random(r) })
    println(List(6) { r.nextBits(31) }.sumOf { it.toLong() })
    for (seed in listOf(Long.MIN_VALUE, Long.MAX_VALUE, 1L shl 53, (1L shl 53) + 1, -1L shl 40, 0x123456789ABCDEFL)) {
        val s = Random(seed)
        println("$seed -> ${s.nextInt()} ${s.nextLong()} ${s.nextLong(1000L)}")
    }
}

fun worlds() {
    println("-- worlds")
    println(SplitMix.mix(0L))
    println(SplitMix.mix(1L))
    println(SplitMix.mix(Long.MIN_VALUE))
    println(SplitMix.chunkSeed(42L, -3, 7))
    for (seed in listOf(42L, 8_675_309L, -9_000_000_000_000_000_000L)) {
        val world = World(seed)
        println("world $seed")
        world.render(5).forEach { println("  $it") }
        println("  ore=${world.totalOre(5)} max=${(0 until 5).maxOf { world.chunk(it - 2, 0).ore }}")
        val c = world.chunk(0, 0)
        println("  chunk(0,0) heights=${c.heights.take(6)} biome=${c.biome}")
    }
}

fun lottery() {
    println("-- lottery")
    val draw = Random(20240101L)
    val tickets = List(5) { List(6) { draw.nextInt(1, 50) }.distinct().sorted() }
    tickets.forEachIndexed { i, t -> println("ticket $i: $t") }
    val winning = (1..49).shuffled(draw).take(6).sorted()
    println("winning: $winning")
    for (t in tickets) println("matches: ${t.count { it in winning }}")
    val ids = List(4) { (draw.nextLong() ushr 12).toString(16).padStart(16, '0') }
    println(ids)
}

fun main() {
    longDraws()
    worlds()
    lottery()
}
