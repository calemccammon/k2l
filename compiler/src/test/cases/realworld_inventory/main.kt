// A warehouse inventory service: a value class-like Money type with operators, sealed events
// replayed into state, a builder DSL with lambdas with receivers, validation with require/check
// and custom exceptions.

data class Money(val cents: Long) : Comparable<Money> {
    operator fun plus(o: Money) = Money(cents + o.cents)
    operator fun minus(o: Money) = Money(cents - o.cents)
    operator fun times(n: Int) = Money(cents * n)
    operator fun div(n: Int) = Money(cents / n)
    override fun compareTo(other: Money) = cents.compareTo(other.cents)
    override fun toString(): String {
        val sign = if (cents < 0) "-" else ""
        val abs = Math.abs(cents)
        return "$sign$${abs / 100}.${(abs % 100).toString().padStart(2, '0')}"
    }

    companion object {
        val ZERO = Money(0)
        fun parse(s: String): Money {
            val (whole, frac) = s.removePrefix("$").split('.').let { it[0] to it.getOrElse(1) { "0" } }
            return Money(whole.toLong() * 100 + frac.padEnd(2, '0').take(2).toLong())
        }
    }
}

val Int.dollars get() = Money(this * 100L)
fun Iterable<Money>.sum() = fold(Money.ZERO, Money::plus)

enum class Category(val code: String, val perishable: Boolean = false) {
    PRODUCE("PRD", perishable = true), DAIRY("DRY", perishable = true), HARDWARE("HWR"), BOOKS("BKS");

    override fun toString() = "$name[$code]"
}

data class Product(val sku: String, val name: String, val category: Category, val price: Money)

class OutOfStockException(val sku: String, val requested: Int, val available: Int) :
    RuntimeException("Cannot take $requested of $sku: only $available left")

sealed interface Event {
    val sku: String

    data class Received(override val sku: String, val qty: Int) : Event
    data class Shipped(override val sku: String, val qty: Int, val order: String) : Event
    data class Adjusted(override val sku: String, val delta: Int, val reason: String) : Event
    data class PriceChanged(override val sku: String, val newPrice: Money) : Event
}

class Inventory {
    private val products = linkedMapOf<String, Product>()
    private val stock = mutableMapOf<String, Int>()
    private val log = mutableListOf<Event>()
    val events: List<Event> get() = log

    fun register(product: Product) {
        require(product.sku !in products) { "duplicate sku ${product.sku}" }
        require(product.price > Money.ZERO) { "price must be positive" }
        products[product.sku] = product
    }

    fun product(sku: String) = products[sku] ?: throw NoSuchElementException("unknown sku $sku")

    fun quantity(sku: String) = stock[sku] ?: 0

    fun apply(event: Event) {
        product(event.sku)
        when (event) {
            is Event.Received -> {
                require(event.qty > 0) { "received quantity must be positive" }
                stock.merge(event.sku, event.qty, Int::plus)
            }
            is Event.Shipped -> {
                val have = quantity(event.sku)
                if (have < event.qty) throw OutOfStockException(event.sku, event.qty, have)
                stock[event.sku] = have - event.qty
            }
            is Event.Adjusted -> stock[event.sku] = (quantity(event.sku) + event.delta).coerceAtLeast(0)
            is Event.PriceChanged -> products[event.sku] = product(event.sku).copy(price = event.newPrice)
        }
        log += event
        check(stock.values.all { it >= 0 }) { "negative stock" }
    }

    fun value(): Money = products.values.map { it.price * quantity(it.sku) }.sum()

    fun report(): String = buildString {
        appendLine("%-6s %-14s %-12s %5s %10s".format("SKU", "Name", "Category", "Qty", "Value"))
        products.values.sortedWith(compareBy<Product> { it.category }.thenByDescending { quantity(it.sku) }.thenBy { it.sku })
            .forEach { p ->
                val qty = quantity(p.sku)
                appendLine("%-6s %-14s %-12s %5d %10s".format(p.sku, p.name, p.category, qty, p.price * qty))
            }
        append("Total value: ${value()}")
    }
}

// --- an order DSL ---
class OrderLine(val sku: String, val qty: Int)

class OrderBuilder(private val id: String) {
    private val lines = mutableListOf<OrderLine>()
    var customer: String = "anonymous"
    var express = false

    infix fun Int.of(sku: String) {
        lines += OrderLine(sku, this)
    }

    fun build(): Order {
        check(lines.isNotEmpty()) { "order $id has no lines" }
        return Order(id, customer, express, lines.groupBy { it.sku }.map { (sku, ls) -> OrderLine(sku, ls.sumOf { it.qty }) })
    }
}

data class Order(val id: String, val customer: String, val express: Boolean, val lines: List<OrderLine>)

fun order(id: String, block: OrderBuilder.() -> Unit): Order = OrderBuilder(id).apply(block).build()

fun Inventory.fulfil(order: Order): Result<Money> = runCatching {
    // check everything first so a failed order ships nothing
    order.lines.forEach { line ->
        val have = quantity(line.sku)
        if (have < line.qty) throw OutOfStockException(line.sku, line.qty, have)
    }
    order.lines.map { line ->
        apply(Event.Shipped(line.sku, line.qty, order.id))
        product(line.sku).price * line.qty
    }.sum().let { if (order.express) it + 15.dollars else it }
}

fun main() {
    val inv = Inventory()
    listOf(
        Product("A100", "Apples (kg)", Category.PRODUCE, Money.parse("3.49")),
        Product("M200", "Milk 1L", Category.DAIRY, Money.parse("$1.2")),
        Product("H300", "Hammer", Category.HARDWARE, 18.dollars),
        Product("H301", "Nails x100", Category.HARDWARE, Money.parse("4.05")),
        Product("B400", "Kotlin Book", Category.BOOKS, Money.parse("39.99")),
    ).forEach(inv::register)

    for (attempt in listOf(Product("A100", "Dup", Category.BOOKS, 1.dollars), Product("Z1", "Free", Category.BOOKS, Money.ZERO))) {
        try {
            inv.register(attempt)
        } catch (e: IllegalArgumentException) {
            println("rejected ${attempt.sku}: ${e.message}")
        }
    }

    val incoming = listOf(
        Event.Received("A100", 50), Event.Received("M200", 24), Event.Received("H300", 5),
        Event.Received("H301", 40), Event.Received("B400", 3), Event.Adjusted("A100", -4, "bruised"),
        Event.PriceChanged("M200", Money.parse("1.35")), Event.Received("H300", 2),
    )
    incoming.forEach(inv::apply)
    println(inv.report())

    val orders = listOf(
        order("ORD-1") {
            customer = "Ada"
            2 of "H300"
            10 of "H301"
            5 of "H301"
        },
        order("ORD-2") {
            customer = "Grace"
            express = true
            4 of "B400"
        },
        order("ORD-3") {
            express = true
            12 of "M200"
            1 of "B400"
        },
    )
    for (o in orders) {
        inv.fulfil(o)
            .onSuccess { println("${o.id} for ${o.customer}: charged $it (${o.lines.joinToString { l -> "${l.qty}x${l.sku}" }})") }
            .onFailure { e ->
                when (e) {
                    is OutOfStockException -> println("${o.id} failed: ${e.message} [short by ${e.requested - e.available}]")
                    else -> throw e
                }
            }
    }
    println(runCatching { order("ORD-4") { customer = "nobody" } }.exceptionOrNull())
    println(runCatching { inv.apply(Event.Received("NOPE", 1)) }.exceptionOrNull())
    println(runCatching { inv.apply(Event.Received("A100", 0)) }.exceptionOrNull()?.message)
    inv.apply(Event.Adjusted("H301", -1000, "flood"))
    println()
    println(inv.report())

    val shipped = inv.events.filterIsInstance<Event.Shipped>()
    println("\nshipped by order: ${shipped.groupBy({ it.order }, { "${it.sku}x${it.qty}" })}")
    val countsByType = inv.events.groupingBy { it::class.simpleName ?: "?" }.eachCount().toSortedMap()
    println("event counts: $countsByType")
    val perishableValue = Category.entries.filter { it.perishable }
        .associateWith { cat -> inv.events.map { it.sku }.distinct().map(inv::product).filter { it.category == cat }.map { it.price * inv.quantity(it.sku) }.sum() }
    println("perishable value: $perishableValue")
    val prices = inv.events.mapNotNull { (it as? Event.PriceChanged)?.newPrice }
    println("price changes: $prices, max product price ${listOf("A100", "H300", "B400").map { inv.product(it).price }.maxOrNull()}")
    println("money math: ${10.dollars / 3} ${Money(-250)} ${Money.parse("0.5") * 3} ${(1..4).map { it.dollars }.sum()}")
    val (sku, name, category) = inv.product("B400")
    println("destructured: $sku / $name / $category / ${category.ordinal} / ${Category.valueOf("DAIRY").code}")
    with(inv.product("A100")) {
        println("with: $name costs $price, perishable=${category.perishable}")
    }
    inv.product("H300").takeIf { inv.quantity(it.sku) > 0 }?.let { println("in stock: ${it.name}") } ?: println("hammers sold out")
}
