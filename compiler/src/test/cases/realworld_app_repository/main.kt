package shop

import shop.domain.Customer
import shop.domain.CustomerId
import shop.domain.Entity
import shop.domain.Money
import shop.domain.Named
import shop.domain.Order
import shop.domain.Product
import shop.domain.Sku
import shop.domain.price
import shop.query.Spec
import shop.query.and
import shop.query.or
import shop.query.bucket
import shop.query.firstByKey
import shop.query.maxValue
import shop.query.nameStarts
import shop.query.pages
import shop.query.query
import shop.storage.BoundedRepository
import shop.storage.ConflictException
import shop.storage.ReadRepository
import shop.storage.Repository
import shop.storage.SortedRepository
import shop.storage.WriteRepository
import shop.storage.copyAll
import shop.storage.describe
import shop.storage.require as need

// An online shop's storage layer: generic repositories with variance, specs, queries and reports.

class ProductRepository : SortedRepository<Product, Sku>("product") {
    override fun validate(entity: Product): String? = when {
        entity.priceCents <= 0 -> "price must be positive"
        entity.name.isBlank() -> "name is blank"
        else -> null
    }
}

class AuditLog : WriteRepository<Entity<*>> {
    val seen = mutableListOf<String>()
    override fun save(entity: Entity<*>) {
        seen += "${entity::class.simpleName}(${entity.id})"
    }
}

class Pricing(private val products: ReadRepository<Product, Sku>) {
    fun total(order: Order): Money = order.lines.fold(Money.ZERO) { acc, (sku, qty) -> acc + products.need(sku).price * qty }
}

fun <T> printAll(title: String, items: Collection<T>, show: (T) -> String = { it.toString() }) {
    println("$title (${items.size}):")
    items.forEach { println("  ${show(it)}") }
}

fun countNamed(repo: ReadRepository<Entity<*>, *>): Int = repo.all().count { it is Named }

fun main() {
    val products = ProductRepository()
    listOf(
        Product(Sku("KB0001"), "keyboard", 4999),
        Product(Sku("MS0001"), "mouse", 1999),
        Product(Sku("MN0002"), "monitor", 18900),
        Product(Sku("CB0003"), "cable", 499),
        Product(Sku("HD0001"), "headset", 7450),
    ).forEach(products::save)
    println(products)

    try {
        products.save(Product(Sku("XX0000"), "free", 0))
    } catch (e: IllegalArgumentException) {
        println("rejected: ${e.message}")
    }
    try {
        products.save(Product(Sku("KB0001"), "keyboard", 5499, version = 1))
    } catch (e: ConflictException) {
        println("conflict on ${e.entityId}: ${e.message}")
    }
    products.save(Product(Sku("KB0001"), "keyboard", 5499, version = 2))
    try {
        Sku("bad")
    } catch (e: IllegalArgumentException) {
        println("bad sku: ${e.message}")
    }

    printAll("all products", products.all()) { "${it.id} ${it.label()} ${it.price} v${it.version}" }
    printAll("range HD..MS", products.range(Sku("HD0000"), Sku("MS0000"))) { it.name }

    val customers = BoundedRepository<Customer, CustomerId>("customer", capacity = 3)
    customers.save(Customer(CustomerId("eu", 7), "ines"))
    customers.save(Customer(CustomerId("us", 2), "bob", vip = true))
    customers.save(Customer(CustomerId("eu", 3), "olga"))
    customers.save(Customer(CustomerId("ap", 1), "kenji"))
    println(customers.history())
    printAll("customers", customers.all().sortedBy { it.id }) { "${it.id} ${it.label()}" }

    val cheap = Spec<Product> { it.priceCents < 5000 }
    val m: Spec<Named> = nameStarts("m")
    println("cheap or m*: " + products.query().where(cheap or m).orderBy { it.name }.run().map { it.name })
    println("not cheap: " + products.query().where(!cheap).run().map { it.name })
    println("cheap and m*, by price desc: " + products.query().where(cheap and m).orderByDescending(compareBy { it.priceCents }).run())
    println("priciest: " + products.query().orderByDescending(compareBy(Product::priceCents)).first()?.name)
    println("top 2: " + products.query().orderBy { -it.priceCents }.limit(2).run().map { it.id })

    val pricing = Pricing(products)
    val orders = SortedRepository<Order, Int>("order")
    orders.save(Order(3, CustomerId("eu", 7), listOf(Sku("KB0001") to 1, Sku("CB0003") to 3)))
    orders.save(Order(1, CustomerId("us", 2), listOf(Sku("MN0002") to 2)))
    orders.save(Order(2, CustomerId("eu", 3), listOf(Sku("MS0001") to 1, Sku("HD0001") to 1, Sku("CB0003") to 1)))
    printAll("orders", orders.all()) { "#${it.id} ${it.customer} qty=${it.quantity()} total=${pricing.total(it)}" }
    try {
        pricing.total(Order(9, CustomerId("eu", 7), listOf(Sku("ZZ9999") to 1)))
    } catch (e: NoSuchElementException) {
        println("pricing failed: ${e.message}")
    }

    val totals = orders.all().associate { it.id to pricing.total(it) }
    println("totals: $totals, max ${totals.values.max()}, sum ${totals.values.fold(Money.ZERO, Money::plus)}")
    println("first by key: ${totals.firstByKey()}")
    println("max name: ${products.all().maxValue { it.name }}, max price: ${products.all().maxValue { it.price }}")
    println("buckets: " + products.all().bucket { it.priceCents / 5000 }.mapValues { (_, v) -> v.map { it.name } })
    println("pages: " + products.all().map { it.name }.pages(2))

    val audit = AuditLog()
    println("copied ${copyAll(products, audit)} products, ${copyAll(customers, audit)} customers")
    println(audit.seen)
    val anyRepo: ReadRepository<Entity<*>, *> = products
    println("named: ${countNamed(anyRepo)}, ${anyRepo.describe()}, ${orders.describe()}")
    val repos: List<Repository<*, *>> = listOf(products, customers, orders)
    for (r in repos) println("$r: ${r.history().takeLast(2)}")
    val byKind = repos.groupBy { it.kind.length }
    println(byKind.mapValues { (_, v) -> v.map { it.kind } })
    val first: Entity<*>? = products.find(Sku("CB0003"))
    println("found ${(first as? Product)?.name} ${first is Named} ${first is Comparable<*>}")
}
