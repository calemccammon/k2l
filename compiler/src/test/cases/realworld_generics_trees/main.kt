package generics.trees

// Sealed generic hierarchies: a persistent binary search tree `Tree<out T>` with a `Nothing`-typed empty case, a rose
// tree with functor-style map/fold, and a generic expression tree evaluated in different domains.

sealed interface Tree<out T> {
    data object Empty : Tree<Nothing>
    data class Node<out T>(val left: Tree<T>, val value: T, val right: Tree<T>) : Tree<T>
}

fun <T : Comparable<T>> Tree<T>.insert(x: T): Tree<T> = when (this) {
    Tree.Empty -> Tree.Node(Tree.Empty, x, Tree.Empty)
    is Tree.Node -> when {
        x < value -> copy(left = left.insert(x))
        x > value -> copy(right = right.insert(x))
        else -> this
    }
}

operator fun <T : Comparable<T>> Tree<T>.contains(x: T): Boolean = when (this) {
    Tree.Empty -> false
    is Tree.Node -> if (x == value) true else if (x < value) x in left else x in right
}

fun <T> Tree<T>.inOrder(): List<T> = when (this) {
    Tree.Empty -> emptyList()
    is Tree.Node -> left.inOrder() + value + right.inOrder()
}

val Tree<*>.height: Int
    get() = when (this) {
        Tree.Empty -> 0
        is Tree.Node<*> -> 1 + maxOf(left.height, right.height)
    }

fun <T, R> Tree<T>.map(f: (T) -> R): Tree<R> = when (this) {
    Tree.Empty -> Tree.Empty
    is Tree.Node -> Tree.Node(left.map(f), f(value), right.map(f))
}

fun <T, R> Tree<T>.fold(empty: R, combine: (R, T, R) -> R): R = when (this) {
    Tree.Empty -> empty
    is Tree.Node -> combine(left.fold(empty, combine), value, right.fold(empty, combine))
}

fun <T : Comparable<T>> treeOf(vararg xs: T): Tree<T> = xs.fold(Tree.Empty as Tree<T>) { t, x -> t.insert(x) }

fun Tree<*>.render(): String = when (this) {
    Tree.Empty -> "."
    is Tree.Node<*> -> if (left == Tree.Empty && right == Tree.Empty) "$value" else "($value ${left.render()} ${right.render()})"
}

data class Rose<out T>(val value: T, val children: List<Rose<T>> = emptyList()) {
    fun <R> map(f: (T) -> R): Rose<R> = Rose(f(value), children.map { it.map(f) })
    fun <R> fold(f: (T, List<R>) -> R): R = f(value, children.map { it.fold(f) })
    fun flatten(): Sequence<T> = sequence {
        yield(value)
        for (c in children) yieldAll(c.flatten())
    }

    fun paths(): List<List<T>> = if (children.isEmpty()) listOf(listOf(value)) else children.flatMap { c -> c.paths().map { listOf(value) + it } }
}

fun <T> rose(value: T, vararg children: Rose<T>) = Rose(value, children.toList())

sealed class Expr<out T> {
    data class Lit<out T>(val value: T) : Expr<T>()
    data class Var(val name: String) : Expr<Nothing>()
    data class Bin<out T>(val op: Char, val left: Expr<T>, val right: Expr<T>) : Expr<T>()
    data class Neg<out T>(val inner: Expr<T>) : Expr<T>()
}

interface Domain<T> {
    fun plus(a: T, b: T): T
    fun times(a: T, b: T): T
    fun negate(a: T): T
    fun show(a: T): String = a.toString()
}

object Ints : Domain<Int> {
    override fun plus(a: Int, b: Int) = a + b
    override fun times(a: Int, b: Int) = a * b
    override fun negate(a: Int) = -a
}

object Bools : Domain<Boolean> {
    override fun plus(a: Boolean, b: Boolean) = a || b
    override fun times(a: Boolean, b: Boolean) = a && b
    override fun negate(a: Boolean) = !a
    override fun show(a: Boolean) = if (a) "T" else "F"
}

object Texts : Domain<String> {
    override fun plus(a: String, b: String) = "$a|$b"
    override fun times(a: String, b: String) = a.flatMap { x -> b.map { y -> "$x$y" } }.joinToString("")
    override fun negate(a: String) = a.reversed()
}

fun <T> Expr<T>.eval(d: Domain<T>, env: Map<String, T>): T = when (this) {
    is Expr.Lit -> value
    is Expr.Var -> env[name] ?: throw IllegalArgumentException("unbound variable $name")
    is Expr.Neg -> d.negate(inner.eval(d, env))
    is Expr.Bin -> when (op) {
        '+' -> d.plus(left.eval(d, env), right.eval(d, env))
        '*' -> d.times(left.eval(d, env), right.eval(d, env))
        else -> throw UnsupportedOperationException("operator $op")
    }
}

fun Expr<*>.variables(): Set<String> = when (this) {
    is Expr.Lit<*> -> emptySet()
    is Expr.Var -> setOf(name)
    is Expr.Neg<*> -> inner.variables()
    is Expr.Bin<*> -> left.variables() + right.variables()
}

fun <T> Expr<T>.show(): String = when (this) {
    is Expr.Lit -> "$value"
    is Expr.Var -> name
    is Expr.Neg -> "-${inner.show()}"
    is Expr.Bin -> "(${left.show()} $op ${right.show()})"
}

fun main() {
    println("== search tree")
    val t = treeOf(50, 30, 70, 20, 40, 60, 80, 30, 65)
    println("inOrder=${t.inOrder()} height=${t.height} size=${t.fold(0) { l, _, r -> l + 1 + r }}")
    println("render=${t.render()}")
    println("contains 65=${65 in t} 66=${66 in t} sum=${t.fold(0) { l, v, r -> l + v + r }}")
    val labels: Tree<String> = t.map { "n$it" }
    val anyTree: Tree<Any> = labels
    println("labels=${labels.inOrder().take(3)} any height=${anyTree.height} empty=${Tree.Empty.inOrder()} ${Tree.Empty.height}")
    val words = treeOf("pear", "apple", "fig", "kiwi", "banana")
    println("words=${words.inOrder()} max=${words.fold<String, String?>(null) { l, v, r -> r ?: v ?: l }} render=${words.render()}")
    println("equal=${treeOf(2, 1, 3) == treeOf(2, 3, 1)} ${treeOf(1, 2, 3) == treeOf(2, 1, 3)} empty=${Tree.Empty}")

    println("== rose tree")
    val org = rose("ceo", rose("cto", rose("dev1"), rose("dev2")), rose("cfo", rose("acct")), rose("coo"))
    println("flatten=${org.flatten().toList()}")
    println("paths=${org.paths().map { it.joinToString("/") }}")
    println("lengths=${org.map { it.length }.fold<Int> { v, cs -> v + cs.sum() }}")
    println("depth=${org.fold<Int> { _, cs -> 1 + (cs.maxOrNull() ?: 0) }} leaves=${org.fold<Int> { _, cs -> if (cs.isEmpty()) 1 else cs.sum() }}")
    println("upper=${org.map(String::uppercase).children.map { it.value }}")

    println("== expressions")
    val e: Expr<Int> = Expr.Bin('+', Expr.Bin('*', Expr.Var("x"), Expr.Lit(3)), Expr.Neg(Expr.Var("y")))
    println("${e.show()} = ${e.eval(Ints, mapOf("x" to 4, "y" to 5))} vars=${e.variables()}")
    val b: Expr<Boolean> = Expr.Bin('*', Expr.Var("p"), Expr.Neg(Expr.Bin('+', Expr.Var("q"), Expr.Lit(false))))
    for (p in listOf(true, false)) for (q in listOf(true, false)) {
        print("${Bools.show(b.eval(Bools, mapOf("p" to p, "q" to q)))} ")
    }
    println()
    val s: Expr<String> = Expr.Bin('+', Expr.Bin('*', Expr.Lit("ab"), Expr.Var("v")), Expr.Neg(Expr.Lit("xyz")))
    println("${s.show()} = ${Texts.show(s.eval(Texts, mapOf("v" to "12")))}")
    val shared: Expr<Nothing> = Expr.Var("z")
    val reused: List<Expr<Any>> = listOf(shared, Expr.Lit(1), Expr.Lit("a"))
    println("reused=${reused.map { it.show() }} vars=${reused.flatMap { it.variables() }}")
    try {
        e.eval(Ints, mapOf("x" to 1))
    } catch (ex: IllegalArgumentException) {
        println("error: ${ex.message}")
    }
    try {
        Expr.Bin('/', Expr.Lit(1), Expr.Lit(2)).eval(Ints, emptyMap())
    } catch (ex: UnsupportedOperationException) {
        println("error: ${ex.message}")
    }
}
