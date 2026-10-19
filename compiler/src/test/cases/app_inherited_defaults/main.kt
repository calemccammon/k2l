// Overrides inherit the default arguments of the function they override, also through several levels and with parameters
// renamed; a default may read earlier parameters and members.
interface Report {
    fun render(indent: String = "", width: Int = indent.length + 10): String
}

abstract class Base(val name: String) : Report {
    open fun greet(greeting: String = "hello", target: String = name.uppercase()) = "$greeting $target"
}

open class Leaf(name: String) : Base(name) {
    override fun render(indent: String, width: Int) = "$indent$name/$width"
    override fun greet(greeting: String, target: String) = "leaf: " + super.greet(greeting, target)
}

class Branch(name: String, private val kids: List<Report>) : Leaf(name) {
    override fun render(prefix: String, max: Int): String =
        (listOf("$prefix$name/$max") + kids.map { it.render("$prefix  ") }).joinToString("\n")

    override fun greet(hi: String, who: String) = "branch: $hi $who"
}

fun main() {
    val tree = Branch("root", listOf(Leaf("a"), Branch("b", listOf(Leaf("c")))))
    println(tree.render())
    println(tree.render(">"))
    val r: Report = Leaf("x")
    println(r.render() + " " + r.render(width = 3))
    println(Leaf("y").greet() + " | " + Leaf("y").greet("hi") + " | " + tree.greet() + " | " + tree.greet(who = "you"))
}
