package shop.log

// The journal every other file writes to; its own state is plain, so its init order is unobservable.

val journal = mutableListOf<String>()

var sequence = 0
    private set

fun log(message: String): Int {
    sequence++
    journal += "$sequence $message"
    println("[log] $message")
    return sequence
}

fun dumpJournal(from: Int = 0): String = journal.drop(from).joinToString(" | ")
