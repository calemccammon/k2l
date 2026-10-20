// Adapted from realworld_app_pipeline and realworld_catalog: a batch of order records run through collection
// pipelines (filter, map, groupBy, associateBy, flatMap, distinct, partition, windowed, chunked, fold, zip).

const val SIZE = 40_000 // orders per batch

enum class Region { NORTH, SOUTH, EAST, WEST }

data class Customer(val id: Int, val name: String, val region: Region, val vip: Boolean)

data class Line(val sku: String, val quantity: Int, val priceCents: Int) {
    val total get() = quantity * priceCents
}

data class Order(val id: Int, val customerId: Int, val day: Int, val lines: List<Line>) {
    val total get() = lines.sumOf { it.total }
}

class Lcg(private var seed: Int) {
    fun next(bound: Int): Int {
        seed = (seed * 75 + 74) % 65537
        return seed % bound
    }
}

data class Summary(val region: Region, val orders: Int, val revenue: Long, val topSku: String)

fun summarize(orders: List<Order>, customers: Map<Int, Customer>): List<Summary> =
    orders.groupBy { customers.getValue(it.customerId).region }
        .map { (region, list) ->
            val skuCounts = list.flatMap { it.lines }.groupingBy { it.sku }.fold(0) { acc, line -> acc + line.quantity }
            val top = skuCounts.entries.maxWith(compareBy({ it.value }, { it.key })).key
            Summary(region, list.size, list.sumOf { it.total.toLong() }, top)
        }
        .sortedByDescending { it.revenue }

fun main() {
    val rng = Lcg(2024)
    val customers = (1..500).map { Customer(it, "customer$it", Region.entries[rng.next(4)], rng.next(10) == 0) }
    val byId = customers.associateBy { it.id }
    var checksum = 0L
    repeat(3) { batch ->
        val orders = (1..SIZE).map { id ->
            val lines = List(1 + rng.next(4)) { Line("sku${rng.next(60)}", 1 + rng.next(5), 100 + rng.next(9900)) }
            Order(id, 1 + rng.next(500), rng.next(28), lines)
        }
        val summaries = summarize(orders, byId)
        summaries.forEach { checksum += it.revenue % 1_000_003 + it.orders }
        println("batch $batch: " + summaries.joinToString { "${it.region}=${it.orders}/${it.topSku}" })

        val (vip, regular) = orders.partition { byId.getValue(it.customerId).vip }
        val vipAverage = vip.map { it.total }.average()
        val bigSpenders = orders.groupBy { it.customerId }.mapValues { (_, list) -> list.sumOf { it.total.toLong() } }
            .entries.sortedWith(compareByDescending<Map.Entry<Int, Long>> { it.value }.thenBy { it.key }).take(5).map { it.key }
        val daily = orders.groupBy { it.day }.toSortedMap().values.map { list -> list.sumOf { it.total.toLong() } }
        val bestWeek = daily.windowed(7).maxOf { it.sum() }
        val skus = orders.flatMap { o -> o.lines.map { it.sku } }.distinct().sorted()
        val chunks = regular.chunked(1000).map { chunk -> chunk.count { it.lines.size > 2 } }
        val dot = daily.zip(daily.drop(1)) { a, b -> (b - a) % 1000 }.fold(0L) { acc, d -> acc + d }
        checksum += vipAverage.toLong() + bigSpenders.sum() + bestWeek % 1_000_003 + skus.size + chunks.sum() + dot
        println("  vip ${vip.size} avg ${vipAverage.toLong()}, top $bigSpenders, week $bestWeek, skus ${skus.size}, chunks ${chunks.max()}")
    }
    println("checksum $checksum")
}
