package shop

import shop.config.APP_NAME
import shop.config.Settings
import shop.config.bumpVerbosity
import shop.config.currency
import shop.config.describeSettings
import shop.config.profile
import shop.config.startupToken
import shop.config.verbosity
import shop.ext.grandTotal
import shop.ext.lastParsed
import shop.ext.money
import shop.ext.times
import shop.ext.totalCents
import shop.log.dumpJournal
import shop.log.journal
import shop.log.log
import shop.log.sequence
import shop.model.Item
import shop.store.Store
import shop.store.operations
import shop.store.stock

// An inventory tool split over five packages: settings and a journal shared by every file, an item model with a
// companion, pricing extensions declared in one package and used in others, and a store object holding the stock.

fun main() {
    println("start $APP_NAME")
    println(describeSettings())
    profile = "warehouse"
    verbosity = 2
    println(describeSettings())
    println("bumped to ${bumpVerbosity()} then ${bumpVerbosity(3)}; main sees $verbosity")
    verbosity--
    println("verbosity now $verbosity")

    println("journal size before objects: ${journal.size}, sequence $sequence")
    println("token $startupToken again $startupToken")

    Settings["region"] = "south"
    println("keys ${Settings.keys}")
    println("opened at ${Store.opened}")

    Store.receive("T-100, hammer, 1299, 2")
    Store.receive("F-7, coffee, 450")
    Store.receive("T-100, hammer, 1299, 3")
    Store.receive("X-1, mystery, 99, 4")
    println("created ${Item.created} items; last parsed '${Item.lastParsed}'")
    println("stock ${stock.keys} ops $operations")
    println(Store.take("T-100", 4))
    println(Store.take("F-7", 2))
    println(Store.take("F-7", 1))
    println(Store.take("nope", 1))
    println("stock ${stock.values.map { "${it.sku}:${it.qty}" }} ops $operations")
    println(Store.byCategory())

    currency = "USD"
    println("value ${Store.value().money()}")
    val crate = Item("T-9", "nails", 5, 10) * 3
    println("$crate ${crate.totalCents.money()} ${listOf(crate, crate).grandTotal().money()}")
    println((-1234).money())

    val mark = log("done")
    println("journal from $mark: ${dumpJournal(mark - 1)}")
    println("journal head: ${dumpJournal().take(60)}")
}
