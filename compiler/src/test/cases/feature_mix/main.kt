import kotlin.properties.Delegates

// Interactions between inner classes, enum entry bodies, open accessors,
// extension properties and delegated properties.

interface Priced { val price: Int }

enum class Size(val factor: Int) : Priced {
    SMALL(1) {
        override val price get() = base * factor
    },
    LARGE(3) {
        override val price: Int
            get() = base * factor - discount
        val discount by lazy { println("computing discount"); 2 }
    };

    open val base: Int get() = 10
}

val Priced.label: String get() = "costs $price"

class Shop(val name: String) {
    var sales by Delegates.observable(0) { _, old, new -> println("$name sales $old -> $new") }

    inner class Till(val id: Int) {
        val cache by lazy { "$name/till$id" }

        fun sell(size: Size) {
            sales += size.price
            println("$cache sold ${size.name}: ${size.label}")
        }
    }
}

val Shop.Till.tag: String get() = "#$id"

open class Item(open val title: String) {
    open val shown: String get() = title
}

class Special(title: String) : Item(title) {
    override val shown: String get() = "*" + super.shown + "*"
}

fun main() {
    val shop = Shop("corner")
    val till = shop.Till(1)
    till.sell(Size.SMALL)
    till.sell(Size.LARGE)
    till.sell(Size.LARGE)
    println(till.tag)
    println(Size.entries.map { it.label })
    val items: List<Item> = listOf(Item("plain"), Special("fancy"))
    for (item in items) println(item.shown)
    println(shop.sales)
}
