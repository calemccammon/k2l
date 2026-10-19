package rules.dsl

import rules.engine.Facts
import rules.engine.Value
import rules.engine.toValue

@DslMarker
annotation class RuleDsl

/** A condition over the facts, with a description for explanations. */
class Condition(val text: String, val test: (Facts) -> Boolean) {
    infix fun and(other: Condition) = Condition("($text and ${other.text})") { test(it) && other.test(it) }
    infix fun or(other: Condition) = Condition("($text or ${other.text})") { test(it) || other.test(it) }
    operator fun not() = Condition("not $text") { !test(it) }
    override fun toString() = text
}

/** A reference to a fact by name, used on the left of comparisons inside `whenever { }`. */
class FactRef(val name: String) {
    infix fun gt(n: Number) = Condition("$name > $n") { it[name] > n.toDouble().toValue() }
    infix fun lt(n: Number) = Condition("$name < $n") { it[name] < n.toDouble().toValue() }
    infix fun atLeast(n: Number) = Condition("$name >= $n") { it[name] >= n.toDouble().toValue() }
    infix fun eq(s: String) = Condition("$name == \"$s\"") { it[name] == s.toValue() }
    infix fun `in`(range: ClosedFloatingPointRange<Double>) = Condition("$name in ${range.start}..${range.endInclusive}") {
        (it[name] as? Value.Num)?.v?.let { v -> v in range } ?: false
    }
    val isSet get() = Condition("$name is set") { name in it }
    val isTrue get() = Condition("$name") { it[name] == Value.Flag(true) }
}

@RuleDsl
class ConditionScope {
    operator fun String.unaryPlus() = FactRef(this)
    fun fact(name: String) = FactRef(name)
    fun always() = Condition("always") { true }
}

@RuleDsl
class ActionScope(private val facts: Facts, private val fired: MutableList<String>) {
    infix fun String.becomes(value: Value) {
        facts[this] = value
    }

    infix fun String.becomes(value: Number) = this becomes value.toDouble().toValue()
    infix fun String.becomes(value: String) = this becomes value.toValue()
    infix fun String.becomes(value: Boolean) = this becomes value.toValue()

    operator fun String.invoke(): Value = facts[this]

    fun note(text: String) {
        fired += text
    }

    fun drop(name: String) {
        facts -= name
    }
}

class Rule(
    val name: String,
    val priority: Int,
    val condition: Condition,
    val action: ActionScope.() -> Unit,
    val once: Boolean,
) {
    override fun toString() = "rule '$name' (p$priority) when $condition"
}

@RuleDsl
class RuleBuilder(private val name: String) {
    var priority = 0
    var once = false
    private var condition: Condition? = null
    private var action: (ActionScope.() -> Unit)? = null

    fun whenever(block: ConditionScope.() -> Condition) {
        condition = ConditionScope().block()
    }

    fun then(block: ActionScope.() -> Unit) {
        action = block
    }

    fun build(): Rule = Rule(
        name,
        priority,
        condition ?: error("rule '$name' has no condition"),
        action ?: throw IllegalStateException("rule '$name' has no action"),
        once,
    )
}

@RuleDsl
class RuleSetBuilder {
    internal val rules = mutableListOf<Rule>()

    fun rule(name: String, block: RuleBuilder.() -> Unit) {
        rules += RuleBuilder(name).apply(block).build()
    }

    /** Several similar rules from a table. */
    fun <T> each(items: Iterable<T>, block: RuleSetBuilder.(T) -> Unit) {
        for (item in items) block(item)
    }
}

fun ruleSet(block: RuleSetBuilder.() -> Unit): List<Rule> = RuleSetBuilder().apply(block).rules.sortedByDescending { it.priority }
