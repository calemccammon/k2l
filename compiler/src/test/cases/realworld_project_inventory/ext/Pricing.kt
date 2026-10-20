package shop.ext

import shop.config.TAX_PERCENT
import shop.config.currency
import shop.model.Item

val Item.totalCents: Int get() = cents * qty

fun Item.withTax(): Int = totalCents + totalCents * TAX_PERCENT / 100

fun Int.money(): String {
    val sign = if (this < 0) "-" else ""
    val abs = if (this < 0) -this else this
    return "$sign${abs / 100}.${(abs % 100).toString().padStart(2, '0')} $currency"
}

fun Iterable<Item>.grandTotal(): Int = sumOf { it.withTax() }

operator fun Item.times(n: Int): Item = copy(qty = qty * n)

var Item.Companion.lastParsed: String
    get() = lastParsedLine
    set(value) {
        lastParsedLine = value
    }

private var lastParsedLine = "-"
