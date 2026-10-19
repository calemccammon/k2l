package bank

import kotlin.properties.Delegates

// A small banking domain: account hierarchy, value objects, delegation, lazy/observable properties and audit logs.

data class Money(val cents: Long) : Comparable<Money> {
    operator fun plus(other: Money) = Money(cents + other.cents)
    operator fun minus(other: Money) = Money(cents - other.cents)
    operator fun times(factor: Int) = Money(cents * factor)
    operator fun unaryMinus() = Money(-cents)
    override fun compareTo(other: Money) = cents.compareTo(other.cents)
    val isNegative get() = cents < 0

    override fun toString(): String {
        val sign = if (cents < 0) "-" else ""
        val abs = kotlin.math.abs(cents)
        return "$sign$${abs / 100}.${(abs % 100).toString().padStart(2, '0')}"
    }

    companion object {
        val ZERO = Money(0)
        fun of(amount: String): Money {
            val (whole, frac) = amount.split('.').let { it[0] to it.getOrElse(1) { "0" } }
            return Money(whole.toLong() * 100 + frac.padEnd(2, '0').take(2).toLong())
        }
    }
}

val Int.dollars get() = Money(this * 100L)

class InsufficientFunds(val account: String, val requested: Money, val available: Money) :
    Exception("account $account: requested $requested but only $available available")

class TransferFailed(message: String, cause: Throwable) : RuntimeException(message, cause)

interface Auditable {
    val auditLog: MutableList<String>
    fun audit(entry: String) {
        auditLog += "[${auditLog.size + 1}] $entry"
    }
}

class AuditTrail : Auditable {
    override val auditLog = mutableListOf<String>()
}

enum class Kind { CHECKING, SAVINGS, CREDIT }

abstract class Account(val id: String, val owner: Customer, trail: Auditable = AuditTrail()) : Auditable by trail {
    abstract val kind: Kind
    protected open val overdraftLimit: Money = Money.ZERO

    var balance: Money by Delegates.observable(Money.ZERO) { _, old, new ->
        if (old != new) audit("balance $old -> $new")
    }
        private set

    var frozen by Delegates.vetoable(false) { _, old, new -> !old || new || owner.verified }

    open fun deposit(amount: Money) {
        require(!amount.isNegative && amount != Money.ZERO) { "deposit must be positive, was $amount" }
        check(!frozen) { "account $id is frozen" }
        balance += amount
    }

    open fun withdraw(amount: Money) {
        check(!frozen) { "account $id is frozen" }
        if (balance - amount < -overdraftLimit) throw InsufficientFunds(id, amount, balance + overdraftLimit)
        balance -= amount
    }

    open fun monthEnd() {}

    override fun toString() = "${kind.name.lowercase()} $id (${owner.name}): $balance"

    override fun equals(other: Any?) = other is Account && other.id == id
    override fun hashCode() = id.hashCode()
}

class Checking(id: String, owner: Customer) : Account(id, owner) {
    override val kind = Kind.CHECKING
    override val overdraftLimit = 50.dollars
    private var fees = Money.ZERO

    override fun withdraw(amount: Money) {
        super.withdraw(amount)
        if (balance.isNegative) {
            fees += 5.dollars
            audit("overdraft fee")
        }
    }

    override fun monthEnd() {
        if (fees != Money.ZERO) {
            super.withdraw(fees)
            fees = Money.ZERO
        }
    }
}

class Savings(id: String, owner: Customer, private val ratePercent: Int) : Account(id, owner) {
    override val kind get() = Kind.SAVINGS
    var withdrawalsThisMonth = 0
        private set

    override fun withdraw(amount: Money) {
        if (withdrawalsThisMonth >= 2) throw IllegalStateException("savings $id: withdrawal limit reached")
        super.withdraw(amount)
        withdrawalsThisMonth++
    }

    override fun monthEnd() {
        val interest = Money(balance.cents * ratePercent / 100 / 12)
        if (interest > Money.ZERO) deposit(interest)
        withdrawalsThisMonth = 0
    }
}

class Customer(val name: String, email: String) {
    var email: String = email
        set(value) {
            require('@' in value) { "invalid email '$value'" }
            field = value.trim().lowercase()
        }
    var verified = false
    val initials: String by lazy {
        println("  (computing initials of $name)")
        name.split(' ').filter { it.isNotEmpty() }.joinToString("") { it.first().uppercase() }
    }
}

class Bank(val name: String) {
    private val accounts = linkedMapOf<String, Account>()
    private var nextNumber = 1
    internal val transfers = mutableListOf<Triple<String, String, Money>>()

    fun open(owner: Customer, kind: Kind, rate: Int = 2): Account {
        val id = "${kind.name.first()}-${nextNumber++.toString().padStart(3, '0')}"
        val account = when (kind) {
            Kind.CHECKING -> Checking(id, owner)
            Kind.SAVINGS -> Savings(id, owner, rate)
            Kind.CREDIT -> throw UnsupportedOperationException("credit accounts are not offered")
        }
        accounts[id] = account
        return account
    }

    operator fun get(id: String): Account? = accounts[id]

    fun transfer(from: String, to: String, amount: Money) {
        val source = this[from] ?: throw NoSuchElementException("unknown account $from")
        val target = this[to] ?: throw NoSuchElementException("unknown account $to")
        try {
            source.withdraw(amount)
        } catch (e: InsufficientFunds) {
            throw TransferFailed("transfer $from -> $to failed", e)
        }
        target.deposit(amount)
        transfers += Triple(from, to, amount)
    }

    fun monthEnd() = accounts.values.forEach(Account::monthEnd)

    fun totalHoldings(): Money = accounts.values.fold(Money.ZERO) { acc, a -> acc + a.balance }

    fun report(): List<String> = accounts.values
        .sortedWith(compareByDescending<Account> { it.balance }.thenBy { it.id })
        .map { it.toString() }

    val byOwner: Map<String, List<String>>
        get() = accounts.values.groupBy({ it.owner.name }) { it.id }
}

fun main() {
    val bank = Bank("Lua Savings & Loan")
    val alice = Customer("Alice  van Dyke", "ALICE@example.com")
    val bob = Customer("bob", "bob@example.com")
    println("initials: ${alice.initials} ${alice.initials}")
    try {
        bob.email = "not-an-email"
    } catch (e: IllegalArgumentException) {
        println("rejected: ${e.message}")
    }
    alice.email = "  Alice@Example.COM "
    println("email: ${alice.email}")

    val a1 = bank.open(alice, Kind.CHECKING)
    val a2 = bank.open(alice, Kind.SAVINGS, rate = 12)
    val b1 = bank.open(bob, Kind.CHECKING)
    runCatching { bank.open(bob, Kind.CREDIT) }.onFailure { println("${it::class.simpleName}: ${it.message}") }

    a1.deposit(Money.of("120.5"))
    a2.deposit(1000.dollars)
    b1.deposit(Money.of("15.25"))
    bank.transfer(a2.id, b1.id, 200.dollars)
    b1.withdraw(240.dollars)
    try {
        bank.transfer(b1.id, a1.id, 100.dollars)
    } catch (e: TransferFailed) {
        val cause = e.cause as InsufficientFunds
        println("${e.message}: ${cause.message} [requested ${cause.requested}]")
    }
    listOf<() -> Unit>(
        { a2.withdraw(1.dollars) },
        { a2.withdraw(1.dollars) },
        { a1.deposit(Money.ZERO) },
        { bank.transfer("X-1", a1.id, 1.dollars) },
    ).forEach { op ->
        try {
            op()
        } catch (e: Exception) {
            println("error ${e.javaClass.simpleName}: ${e.message}")
        }
    }

    b1.frozen = true
    b1.frozen = false
    println("bob frozen after unfreeze attempt: ${b1.frozen}")
    bob.verified = true
    b1.frozen = false
    println("bob frozen after verification: ${b1.frozen}")

    bank.monthEnd()
    bank.report().forEach(::println)
    println("holdings: ${bank.totalHoldings()}")
    println("owners: ${bank.byOwner}")
    println("transfers: ${bank.transfers.map { (f, t, m) -> "$f>$t:$m" }}")
    println("b1 audit:")
    b1.auditLog.forEach { println("  $it") }
    println("a2 audit size: ${a2.auditLog.size}, savings withdrawals: ${(a2 as Savings).withdrawalsThisMonth}")
    val set = hashSetOf(a1, bank[a1.id]!!, b1)
    println("distinct accounts: ${set.size}, max money: ${listOf(3.dollars, Money.of("3.01"), -(5.dollars)).max()}")
    println(Money.of("7.5") * 3 == Money.of("22.50"))
}
