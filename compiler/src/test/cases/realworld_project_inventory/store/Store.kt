package shop.store

import shop.config.Settings
import shop.config.verbosity
import shop.ext.lastParsed
import shop.ext.withTax
import shop.log.log
import shop.model.Category
import shop.model.Item

var operations = 0

val stock: MutableMap<String, Item> = linkedMapOf()

// On the JVM this runs when StoreKt is first touched (the first `operations++`), not when the program starts.
val fileStamp = log("Store.kt top-level init")

object Store {
    val opened: Int = log("Store object init, region=${Settings["region"]}")

    fun receive(line: String): Item {
        val item = Item.parse(line)
        Item.lastParsed = line
        operations++
        val existing = stock[item.sku]
        stock[item.sku] = if (existing == null) item else existing.copy(qty = existing.qty + item.qty)
        if (verbosity > 1) log("received ${item.sku} x${item.qty}")
        return item
    }

    fun take(sku: String, qty: Int): Boolean {
        val item = stock[sku] ?: return false
        operations++
        if (item.qty < qty) return false
        if (item.qty == qty) stock.remove(sku) else stock[sku] = item.copy(qty = item.qty - qty)
        return true
    }

    fun byCategory(): Map<Category, List<String>> = stock.values.groupBy({ Category.of(it) }, { it.sku })

    fun value(): Int = stock.values.sumOf { it.withTax() }
}
