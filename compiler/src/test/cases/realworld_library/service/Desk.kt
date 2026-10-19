package lib.service

import lib.model.Loan
import lib.model.MAX_LOANS
import lib.model.Media
import lib.model.Member

class LibraryException(message: String) : Exception(message)

interface Clock {
    val today: Int
}

interface Notifier {
    fun notify(member: Member, text: String)
}

/** Collects notifications; a [Closeable] so the desk can flush it with `use`. */
class Outbox(private val prefix: String) : Notifier, AutoCloseable {
    private val messages = mutableListOf<String>()
    var closed = false
        private set

    override fun notify(member: Member, text: String) {
        check(!closed) { "outbox closed" }
        messages += "$prefix ${member.name}: $text"
    }

    override fun close() {
        closed = true
        messages.forEach(::println)
        messages.clear()
    }
}

var desksOpened = 0
    private set

class Desk(private val clock: Clock, notifier: Notifier) : Notifier by notifier {
    private val shelf = sortedMapOf<String, Media>()
    private val history = mutableListOf<String>()
    private val active = mutableListOf<Loan>()

    init {
        desksOpened++
    }

    fun stock(vararg items: Media) = items.forEach { shelf[it.id] = it }

    val available: List<Media> get() = shelf.values.filter { m -> active.none { it.media == m } }

    fun checkout(member: Member, id: String): Loan {
        val media = shelf[id] ?: throw LibraryException("no such item $id")
        if (!member.canBorrow) throw LibraryException("${member.name} cannot borrow (loans=${member.loans.size}/$MAX_LOANS, fines=${member.fines})")
        if (active.any { it.media == media }) throw LibraryException("$media is already on loan")
        return Loan(media, member, clock.today).also {
            active += it
            member.loans += it
            history += "out ${media.id} ${member.name} d${clock.today}"
        }
    }

    fun checkin(id: String): Int {
        val loan = active.find { it.media.id == id } ?: throw LibraryException("$id is not on loan")
        active -= loan
        loan.member.loans -= loan
        val late = (clock.today - loan.due).coerceAtLeast(0)
        val fee = late * loan.media.lateFeePerDay
        if (fee > 0) {
            loan.member.fines += fee
            notify(loan.member, "late by $late days, fee $fee")
        }
        history += "in ${loan.media.id} late=$late"
        return fee
    }

    fun overdue(): List<Loan> = active.filter { it.due < clock.today }.sortedBy { it.due }

    fun log(): List<String> = history.toList()

    inner class Report(val title: String) {
        fun lines(): List<String> = buildList {
            add("== $title (day ${clock.today})")
            shelf.values.forEach { m ->
                val loan = active.firstOrNull { it.media == m }
                add("${m.describe()} -> ${loan?.let { "${it.member.name} due d${it.due}" } ?: "available"}")
            }
        }
    }
}
