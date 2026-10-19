package corp.pay

import corp.staff.Employee
import corp.staff.Payable

sealed interface Adjustment {
    val reason: String
}

data class Bonus(val amount: Int, override val reason: String) : Adjustment
data class Deduction(val amount: Int, override val reason: String) : Adjustment
data class Raise(val percent: Int, override val reason: String = "annual review") : Adjustment

/** A generic ledger keyed by any payable; entries are kept per payee in order. */
class Ledger<P : Payable> {
    private val entries = LinkedHashMap<P, MutableList<Adjustment>>()

    operator fun get(p: P): List<Adjustment> = entries[p].orEmpty()

    fun add(p: P, vararg adjustments: Adjustment) {
        entries.getOrPut(p) { mutableListOf() }.addAll(adjustments)
    }

    fun payees(): Set<P> = entries.keys

    inline fun <reified A : Adjustment> total(p: P, amount: (A) -> Int): Int = this[p].filterIsInstance<A>().sumOf(amount)
}

class Payroll(private val ledger: Ledger<Employee>) {
    /** Net pay for one month: base, raises compounded, bonuses, deductions. */
    fun net(e: Employee): Int {
        var pay = e.monthly
        for (adj in ledger[e]) {
            pay = when (adj) {
                is Raise -> pay + pay * adj.percent / 100
                is Bonus -> pay + adj.amount
                is Deduction -> pay - adj.amount
            }
        }
        return pay
    }

    fun run(people: Iterable<Employee>): Map<String, Int> = people.associate { it.name to net(it) }

    fun explain(e: Employee): String {
        val parts = ledger[e].map {
            when (it) {
                is Bonus -> "+${it.amount} (${it.reason})"
                is Deduction -> "-${it.amount} (${it.reason})"
                is Raise -> "+${it.percent}% (${it.reason})"
            }
        }
        return "${e.name}: ${e.monthly}" + parts.joinToString("") { " $it" } + " = ${net(e)}"
    }

    val bonuses get() = ledger.payees().sumOf { e -> ledger.total<Bonus>(e) { it.amount } }
}
