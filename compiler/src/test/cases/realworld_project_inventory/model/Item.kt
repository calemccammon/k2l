package shop.model

import shop.config.TAX_PERCENT
import shop.log.log

data class Item(val sku: String, val name: String, val cents: Int, val qty: Int = 1) {
    init {
        created++
    }

    companion object {
        var created = 0
            private set

        val DEFAULT_QTY: Int

        init {
            log("Item companion init (tax $TAX_PERCENT%)")
            DEFAULT_QTY = 1
        }

        fun parse(line: String): Item {
            val parts = line.split(',').map { it.trim() }
            return Item(parts[0], parts[1], parts[2].toInt(), parts.getOrNull(3)?.toInt() ?: DEFAULT_QTY)
        }
    }
}

enum class Category(val prefix: String) {
    TOOLS("T"),
    FOOD("F"),
    MISC("");

    companion object {
        fun of(item: Item): Category = entries.firstOrNull { it.prefix.isNotEmpty() && item.sku.startsWith(it.prefix) } ?: MISC
    }
}
