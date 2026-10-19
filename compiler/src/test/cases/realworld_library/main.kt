package lib

import lib.model.Book
import lib.model.Dvd
import lib.model.Factory
import lib.model.Genre
import lib.model.Media
import lib.model.Member
import lib.model.parse
import lib.service.Clock
import lib.service.Desk
import lib.service.LibraryException
import lib.service.Outbox
import lib.service.desksOpened

// A lending library across packages: parsing records, loans, fees, reports and validation rules.

class SimClock : Clock {
    override var today = 1
    fun advance(days: Int) {
        today += days
    }
}

fun interface Rule {
    fun check(media: Media): String?
}

fun rules(minTitle: Int): List<Rule> = listOf(
    Rule { if (it.title.length < minTitle) "title too short" else null },
    object : Rule {
        override fun check(media: Media) = if (media.id.any(Char::isLowerCase)) "id must be upper case" else null
        override fun toString() = "IdRule"
    },
)

/** Each call evaluates the same object expression. */
private fun counter(start: Int) = object {
    var n = start
    fun next() = n++
}

fun announce() {
    println("  [announcement] library opens")
}

fun main() {
    val records = listOf(
        "id=B1; title=Dune; author=Frank Herbert; isbn=978-0441; genre=fiction",
        "id=B2; title=A Brief History of Time; author=Stephen Hawking; genre=science",
        "id=B3; title=Gruffalo; genre=kids",
        "id=D1; title=Alien; minutes=117",
        "id=d2; title=Up",
    )
    val factories: Map<Char, Factory<out Media>> = mapOf('B' to Book, 'D' to Dvd, 'd' to Dvd)
    val items = records.map { line ->
        val prefix = line.substringAfter("id=").first()
        factories.getValue(prefix).parse(line)
    }
    println(items)
    println(items.sorted().map { it.title })
    val ruleSet = rules(3)
    for (m in items) {
        val problems = ruleSet.mapNotNull { it.check(m) }
        if (problems.isNotEmpty()) println("${m.id}: $problems")
    }
    println(ruleSet.last())

    val clock = SimClock()
    val outbox = Outbox("mail to")
    val desk = Desk(clock, outbox)
    desk.stock(*items.toTypedArray())
    val ann = Member("Ann", 1)
    val ben = Member("Ben", 2)

    val attempts = listOf("B1" to ann, "D1" to ann, "B1" to ben, "X9" to ben, "B3" to ann, "B2" to ann, "d2" to ben)
    for ((id, member) in attempts) {
        try {
            val loan = desk.checkout(member, id)
            println("${member.name} borrows ${loan.media.title}, due d${loan.due}")
        } catch (e: LibraryException) {
            println("refused: ${e.message}")
        }
    }
    clock.advance(10)
    println("overdue at d${clock.today}: ${desk.overdue().map { it.media.id }}")
    outbox.use {
        println("fees: ${listOf("D1", "d2").map(desk::checkin)}")
        clock.advance(20)
        println("fee B3: ${desk.checkin("B3")}")
    }
    println("outbox closed: ${outbox.closed}")
    runCatching { desk.notify(ann, "late") }.onFailure { println("after close: ${it.message}") }
    println("fines: ${listOf(ann, ben).associate { it.name to it.fines }}")
    desk.Report("inventory").lines().forEach(::println)
    println(desk.available.joinToString { it.id })
    println(desk.log())

    val genres = items.filterIsInstance<Book>().groupingBy { it.genre }.eachCount()
    println(Genre.entries.associateWith { genres[it] ?: 0 })
    val longest = items.maxBy { (it as? Dvd)?.minutes ?: 0 }
    println(longest.describe())

    val c1 = counter(10)
    val c2 = counter(20)
    println("${c1.next()} ${c1.next()} ${c2.next()} same class: ${c1.javaClass == c2.javaClass}")
    println(c1::class.java.name)
    val opening: () -> Any = ::announce
    println("result: ${opening()}")
    val actions = listOf<() -> Any?>(::announce, { "lambda" })
    println(actions.map { it() })
    println("desks opened: $desksOpened")
    items.forEach label@{
        if (it is Dvd) return@label
        print("${it.id} ")
    }
    println()
    val summary = with(StringBuilder()) {
        items.groupBy { it::class.simpleName }.forEach { (k, v) -> append("$k=${v.size};") }
        toString()
    }
    println(summary)
}
