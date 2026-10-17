fun describe(x: Int) = "int $x"
fun describe(x: String) = "string $x"
fun describe(x: Int, y: Int) = "pair $x,$y"

open class Printer {
    open fun print(x: Int) = "Printer.int $x"
    open fun print(x: String) = "Printer.string $x"
}

class LoudPrinter : Printer() {
    override fun print(x: String) = "LOUD " + super.print(x).uppercase()
    fun print(x: Boolean) = "LoudPrinter.bool $x"
}

fun main() {
    println(describe(1))
    println(describe("a"))
    println(describe(1, 2))
    val p: Printer = LoudPrinter()
    println(p.print(3))
    println(p.print("hey"))
    val lp = LoudPrinter()
    println(lp.print(true))
    println(Printer().print("plain"))
}
