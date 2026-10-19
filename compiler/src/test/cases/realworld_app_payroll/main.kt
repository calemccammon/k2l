package corp

import corp.pay.Bonus
import corp.pay.Deduction
import corp.pay.Ledger
import corp.pay.Payroll
import corp.pay.Raise
import corp.staff.Employee
import corp.staff.Engineer
import corp.staff.Intern
import corp.staff.Lead
import corp.staff.Manager
import corp.staff.Payable
import corp.staff.intern
import corp.staff.trace

// A payroll run over an org chart: class hierarchies with open/overridden properties, init order, sealed adjustments.

class Contractor(val company: String, override val monthly: Int) : Payable {
    override val currency get() = "GBP"
    override fun toString() = "Contractor($company)"
}

fun printTrace(title: String) {
    println("$title:")
    trace.forEach { println("  $it") }
    trace.clear()
}

fun main() {
    val ada = Lead("Ada", 120_000)
    printTrace("lead")
    val bo = Engineer("Bo", 72_000, level = 2)
    val cy = Engineer("Cy", 60_000)
    printTrace("engineers")
    val dee = Employee.intern("Dee", mentor = bo)
    printTrace("intern")
    val eng = Manager("Eve", 96_000, listOf(ada, bo, cy))
    eng += dee
    val ceo = Manager("Fay", 180_000)
    ceo += eng
    ceo += Intern("Gus")
    printTrace("managers")

    ceo.report().forEach(::println)
    println("headcount ${ceo.headcount}, everyone: ${ceo.everyone().map { it.tag }.toList()}")
    println("${dee in eng} ${dee in ceo} ${ceo in eng} ${ada.payslip()} | ${bo.payslip(3)} | ${ceo.payslip(month = 12)}")
    println("titles: ${ceo.everyone().map(Employee::title).toList()}")
    println("currencies: ${listOf<Payable>(ada, bo, Contractor("Acme", 9000)).map { it.currency }}")

    val ledger = Ledger<Employee>()
    ledger.add(ada, Raise(10), Bonus(500, "launch"))
    ledger.add(bo, Bonus(200, "on call"), Deduction(150, "laptop"), Bonus(100, "referral"))
    ledger.add(dee, Raise(5, "good start"))
    val payroll = Payroll(ledger)
    ceo.everyone().filter { ledger[it].isNotEmpty() }.forEach { println(payroll.explain(it)) }
    println(payroll.run(ceo.everyone().asIterable()))
    println("bonuses ${payroll.bonuses}, bo's bonuses ${ledger.total<Bonus>(bo) { it.amount }}, deductions ${ledger.total<Deduction>(bo) { it.amount }}")

    val other = Engineer("Ada", 1)
    println("${ada == other} ${ada == ada} ${setOf(ada, bo, ada, cy).size} ${ada.hashCode() == "ADA-100".hashCode()}")
    printTrace("other")
    val byTitle = ceo.everyone().groupBy { it::class.simpleName }.mapValues { (_, v) -> v.map { it.name } }
    println(byTitle)
    val ctor: (String) -> Intern = ::Intern
    val bound = ada::payslip
    println("${ctor("Hal").title} ${bound(7)} ${listOf(1, 2).map(ada::payslip)}")
    println(Employee.DEFAULT_SALARY / 12)
}
