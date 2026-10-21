import java.util.Objects
import java.util.Stack
import java.util.StringJoiner

// java.util.Stack, StringJoiner and Objects, and statics of Boolean, Character, Integer, Long and Double
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

/** Balanced brackets with a Stack, as ported Java code does it. */
fun balanced(s: String): Boolean {
    val stack = Stack<Char>()
    for (c in s) {
        when (c) {
            '(', '[', '{' -> stack.push(c)
            ')' -> if (stack.empty() || stack.pop() != '(') return false
            ']' -> if (stack.empty() || stack.pop() != '[') return false
            '}' -> if (stack.empty() || stack.pop() != '{') return false
        }
    }
    return stack.isEmpty()
}

fun main() {
    val stack = Stack<Int>()
    t("push") { listOf(stack.push(1), stack.push(2), stack.push(3)) }
    t("stack") { stack }
    t("peek") { stack.peek() }
    t("search") { listOf(stack.search(3), stack.search(1), stack.search(9)) }
    t("pop") { listOf(stack.pop(), stack.pop()) }
    t("size/empty") { "${stack.size} ${stack.empty()} ${stack.isEmpty()}" }
    t("as list") { stack.map { it * 10 } + stack.size }
    stack.pop()
    t("pop empty") { stack.pop() }
    t("peek empty") {
        try {
            stack.peek()
        } catch (e: RuntimeException) {
            "empty: ${e::class.simpleName}"
        }
    }
    t("balanced") { listOf(balanced("([]{})"), balanced("(]"), balanced("(("), balanced("")) }

    val joiner = StringJoiner(", ", "{", "}")
    t("empty joiner") { joiner.toString() }
    joiner.add("a").add("b")
    joiner.add("c")
    t("joiner") { joiner }
    t("length") { joiner.length() }
    val plain = StringJoiner("-")
    plain.setEmptyValue("EMPTY")
    t("empty value") { "$plain" }
    plain.add("x").add("y")
    t("merge") { joiner.merge(plain).toString() }

    val name: String? = null
    t("requireNonNull") { Objects.requireNonNull("ok") }
    t("requireNonNull null") { Objects.requireNonNull(name, "name is required") }
    t("requireNonNull supplier") { Objects.requireNonNull(name) { "supplied message" } }
    t("isNull/nonNull") { listOf(Objects.isNull(name), Objects.nonNull(name), Objects.nonNull("x")) }
    t("toString") { listOf(Objects.toString(name), Objects.toString(name, "default"), Objects.toString(42, "default")) }
    t("requireNonNullElse") { Objects.requireNonNullElse(name, "fallback") }
    t("checkIndex") { Objects.checkIndex(2, 3) }
    t("checkIndex out") { Objects.checkIndex(3, 3) }
    t("compare") { listOf(Objects.compare("a", "b", naturalOrder()), Objects.compare(2, 1, compareBy { it })) }

    t("Boolean") {
        listOf(
            java.lang.Boolean.compare(true, false), java.lang.Boolean.compare(false, false),
            java.lang.Boolean.logicalAnd(true, false), java.lang.Boolean.logicalOr(true, false),
            java.lang.Boolean.logicalXor(true, true), java.lang.Boolean.valueOf("TRUE"), java.lang.Boolean.hashCode(true),
        )
    }
    t("Character") {
        listOf(Character.forDigit(7, 10), Character.forDigit(11, 16), Character.digit('7', 10), Character.digit('z', 10), Character.digit('f', 16))
    }
    t("hashCode") { listOf(Integer.hashCode(-7), java.lang.Long.hashCode(5_000_000_000L), java.lang.Double.hashCode(1.5), Character.hashCode('A')) }
    t("Double") { listOf(java.lang.Double.max(1.5, -2.5), java.lang.Double.min(1.5, -2.5), java.lang.Double.sum(0.25, 0.5)) }
}
