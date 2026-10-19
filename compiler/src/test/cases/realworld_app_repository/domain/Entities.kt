package shop.domain

/** Every stored thing has an id that orders it. */
interface Entity<ID : Comparable<ID>> {
    val id: ID
}

interface Named {
    val name: String
    fun label(): String = name.replaceFirstChar { it.uppercaseChar() }
}

interface Versioned {
    val version: Int
}

@JvmInline
value class Sku(val code: String) : Comparable<Sku> {
    init {
        require(code.length == 6) { "SKU must have 6 characters: $code" }
    }

    override fun compareTo(other: Sku): Int = code.compareTo(other.code)
    override fun toString(): String = "SKU:$code"
}

data class CustomerId(val region: String, val number: Int) : Comparable<CustomerId> {
    override fun compareTo(other: CustomerId): Int = compareValuesBy(this, other, CustomerId::region, CustomerId::number)
    override fun toString() = "$region-$number"
}

data class Product(override val id: Sku, override val name: String, val priceCents: Long, override val version: Int = 1) :
    Entity<Sku>,
    Named,
    Versioned

data class Customer(override val id: CustomerId, override val name: String, val vip: Boolean = false) :
    Entity<CustomerId>,
    Named {
    override fun label(): String = if (vip) "*${super.label()}*" else super.label()
}

data class Order(override val id: Int, val customer: CustomerId, val lines: List<Pair<Sku, Int>>) : Entity<Int> {
    fun quantity(): Int = lines.sumOf { it.second }
}

/** A money amount in cents, printed as dollars. */
@JvmInline
value class Money(val cents: Long) : Comparable<Money> {
    operator fun plus(other: Money) = Money(cents + other.cents)
    operator fun times(n: Int) = Money(cents * n)
    override fun compareTo(other: Money) = cents.compareTo(other.cents)
    override fun toString(): String {
        val abs = if (cents < 0) -cents else cents
        val sign = if (cents < 0) "-" else ""
        return "$sign$" + (abs / 100) + "." + (abs % 100).toString().padStart(2, '0')
    }

    companion object {
        val ZERO = Money(0)
    }
}

val Product.price: Money get() = Money(priceCents)
