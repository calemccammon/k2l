package corp.staff

val trace = mutableListOf<String>()

interface Payable {
    val monthly: Int
    val currency: String get() = "EUR"
    fun payslip(month: Int = 1): String = "$month: $monthly $currency"
}

interface Reportable {
    fun report(indent: String = ""): List<String>
}

/** The base of every employee; `toString` uses the runtime class name. */
abstract class Employee(val name: String, protected val baseSalary: Int) : Payable, Reportable {
    open val title: String = "employee"
    private val badge = nextBadge++
    val tag = "${name.take(3).uppercase()}-$badge"

    init {
        trace += "Employee($name) title=$title"
    }

    constructor(name: String) : this(name, DEFAULT_SALARY) {
        trace += "Employee secondary($name)"
    }

    override val monthly: Int get() = baseSalary / 12

    override fun report(indent: String): List<String> = listOf("$indent$this")

    override fun toString() = "${this::class.simpleName}($name, $title, $monthly)"

    override fun equals(other: Any?) = other is Employee && other.tag == tag
    override fun hashCode() = tag.hashCode()

    companion object {
        const val DEFAULT_SALARY = 36_000
        private var nextBadge = 100
        fun resetBadges() {
            nextBadge = 100
        }
    }
}

open class Engineer(name: String, salary: Int, val level: Int = 1) : Employee(name, salary) {
    override val title: String = "engineer L$level"
    protected open val bonusRate = 0.1

    init {
        trace += "Engineer($name) level=$level bonus=$bonusRate"
    }

    override val monthly: Int get() = super.monthly + (super.monthly * bonusRate).toInt()
}

class Lead(name: String, salary: Int) : Engineer(name, salary, level = 3) {
    override val bonusRate = 0.25
    override val title get() = "lead (" + super.title + ")"
    override val currency = "USD"

    override fun payslip(month: Int) = "lead " + super.payslip(month)
}

class Intern(name: String) : Employee(name) {
    override val title = "intern"
    var mentor: Employee? = null

    override fun report(indent: String) = super.report(indent) + listOfNotNull(mentor?.let { "$indent  mentored by ${it.name}" })
}

class Manager(name: String, salary: Int, reports: List<Employee> = emptyList()) : Employee(name, salary) {
    private val team = reports.toMutableList()
    override val title = "manager"

    operator fun plusAssign(e: Employee) {
        team += e
    }

    operator fun contains(e: Employee): Boolean = e in team || team.any { it is Manager && e in it }

    override fun report(indent: String): List<String> = super.report(indent) + team.flatMap { it.report("$indent  ") }

    val headcount: Int get() = 1 + team.sumOf { if (it is Manager) it.headcount else 1 }

    fun everyone(): Sequence<Employee> = sequence {
        yield(this@Manager)
        for (e in team) if (e is Manager) yieldAll(e.everyone()) else yield(e)
    }
}

fun Employee.Companion.intern(name: String, mentor: Employee): Intern = Intern(name).also { it.mentor = mentor }
