package warehouse

// A warehouse: products with an open/abstract hierarchy, interface default methods called through super<...>, secondary
// constructors, a grid of shelves (2D arrays), picking routes and a text report.

interface Priced {
    val unitPrice: Int
    fun price(quantity: Int): Int = unitPrice * quantity
}

interface Discounted : Priced {
    val discountPercent: Int
    override fun price(quantity: Int): Int = super.price(quantity) * (100 - discountPercent) / 100
}

interface Taxed : Priced {
    override fun price(quantity: Int): Int = super.price(quantity) * 108 / 100
}

abstract class Product(val sku: String, val name: String) : Priced {
    protected abstract val category: String
    open val fragile = false
    val label: String
        get() = "[$category] $name" + if (fragile) " (fragile)" else ""

    init {
        require(sku.matches(Regex("[A-Z]{2}-\\d{3}"))) { "bad sku '$sku'" }
    }

    override fun equals(other: Any?) = other is Product && other.sku == sku
    override fun hashCode() = sku.hashCode()
    override fun toString() = sku
}

open class Tool(sku: String, name: String, override val unitPrice: Int) : Product(sku, name) {
    override val category = "tool"

    constructor(sku: String, unitPrice: Int) : this(sku, sku.lowercase(), unitPrice)
}

class Glassware(sku: String, name: String, override val unitPrice: Int, override val discountPercent: Int) :
    Product(sku, name), Discounted, Taxed {
    override val category get() = "glass"
    override val fragile = true

    override fun price(quantity: Int): Int = maxOf(super<Discounted>.price(quantity), super<Taxed>.price(quantity) - 50)
}

class PowerTool(sku: String, name: String, unitPrice: Int, val watts: Int) : Tool(sku, name, unitPrice), Taxed {
    override val category = "power"

    override fun price(quantity: Int) = super<Taxed>.price(quantity)
}

data class Slot(val row: Int, val col: Int) {
    operator fun minus(o: Slot) = kotlin.math.abs(row - o.row) + kotlin.math.abs(col - o.col)
}

class Grid(val rows: Int, val cols: Int) {
    private val cells: Array<Array<Product?>> = Array(rows) { arrayOfNulls(cols) }
    private val counts = Array(rows) { IntArray(cols) }

    operator fun get(slot: Slot): Pair<Product, Int>? = cells[slot.row][slot.col]?.let { it to counts[slot.row][slot.col] }

    fun store(product: Product, quantity: Int): Slot {
        for (r in 0 until rows) {
            for (c in 0 until cols) {
                if (cells[r][c] == product) {
                    counts[r][c] += quantity
                    return Slot(r, c)
                }
            }
        }
        outer@ for (r in 0 until rows) {
            for (c in 0 until cols) {
                if (cells[r][c] != null) continue
                if (product.fragile && r > 0) break@outer
                cells[r][c] = product
                counts[r][c] = quantity
                return Slot(r, c)
            }
        }
        throw IllegalStateException("no room for ${product.label}")
    }

    fun take(slot: Slot, quantity: Int): Int {
        val have = counts[slot.row][slot.col]
        val taken = quantity.coerceAtMost(have)
        counts[slot.row][slot.col] -= taken
        if (counts[slot.row][slot.col] == 0) cells[slot.row][slot.col] = null
        return taken
    }

    fun find(product: Product): Slot? {
        cells.forEachIndexed { r, row ->
            row.forEachIndexed { c, p -> if (p == product) return Slot(r, c) }
        }
        return null
    }

    fun render(): String = cells.indices.joinToString("\n") { r ->
        cells[r].indices.joinToString(" | ") { c -> cells[r][c]?.let { "${it.sku} x${counts[r][c]}".padEnd(10) } ?: "-".padEnd(10) }
    }

    val totalUnits get() = counts.sumOf { it.sum() }
}

class Order(val id: Int, vararg lines: Pair<Product, Int>) {
    val lines = lines.toList()

    companion object {
        private var next = 1
        operator fun invoke(vararg lines: Pair<Product, Int>) = Order(next++, *lines)
    }
}

fun route(start: Slot, stops: List<Slot>): List<Slot> {
    val remaining = stops.toMutableList()
    val path = mutableListOf<Slot>()
    var at = start
    while (remaining.isNotEmpty()) {
        val nearest = remaining.minWith(compareBy<Slot> { it - at }.thenBy { it.row }.thenBy { it.col })
        remaining.remove(nearest)
        path += nearest
        at = nearest
    }
    return path
}

fun main() {
    val hammer = Tool("TL-001", "hammer", 1200)
    val wrench = Tool("TL-002", 900)
    val drill = PowerTool("PT-100", "drill", 8000, 650)
    val vase = Glassware("GL-007", "vase", 2500, 20)
    val glasses = Glassware("GL-008", "glasses", 400, 5)
    val products = listOf(hammer, wrench, drill, vase, glasses)
    println(runCatching { Tool("bad", 1) }.exceptionOrNull()?.message)
    products.forEach { p ->
        println("${p.label.padEnd(24)} 1=${p.price(1)} 10=${p.price(10)}")
    }

    val grid = Grid(3, 4)
    val stock = listOf(hammer to 10, drill to 2, vase to 4, glasses to 30, wrench to 15, hammer to 5)
    val slots = stock.map { (p, q) -> grid.store(p, q) }
    println(slots.map { "${it.row},${it.col}" })
    println(runCatching { grid.store(Glassware("GL-009", "bowl", 300, 0), 1) }.exceptionOrNull()?.message)
    println(grid.render())
    println("units=${grid.totalUnits}")

    val orders = listOf(
        Order(hammer to 3, vase to 1),
        Order(glasses to 12, drill to 1, wrench to 2),
        Order(vase to 10),
    )
    for (order in orders) {
        val stops = order.lines.mapNotNull { (p, _) -> grid.find(p) }
        val path = route(Slot(2, 0), stops)
        var total = 0
        val picked = order.lines.map { (p, q) ->
            val slot = grid.find(p) ?: return@map "${p.sku}: none"
            val got = grid.take(slot, q)
            total += p.price(got)
            "${p.sku}: $got/$q"
        }
        println("order ${order.id} route=${path.joinToString(">") { "${it.row}${it.col}" }} $picked total=$total")
    }
    println(grid.render())
    println(grid[Slot(0, 0)])
    println(grid[Slot(2, 2)])
    val bySku = products.associateBy { it.sku }
    println(bySku["GL-007"] === vase)
    println(products.toSet().size == setOf(Tool("TL-001", 1), hammer).size + 3)
    val (fragile, sturdy) = products.partition { it.fragile }
    println("fragile=$fragile sturdy=$sturdy")
    println(products.sortedWith(compareByDescending<Product> { it.price(1) }.thenBy { it.name }).map { it.name })
    println(products.windowed(2).map { (a, b) -> a.price(1) - b.price(1) })
}
