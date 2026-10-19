package rules

import rules.dsl.ruleSet
import rules.engine.Engine
import rules.engine.Facts
import rules.engine.RuleCycleException
import rules.engine.Value
import rules.engine.toValue

// An insurance quote engine: rules written in a Kotlin DSL, forward chaining over facts.

val tiers = listOf("bronze" to 0.0, "silver" to 0.1, "gold" to 0.2)

val quoteRules = ruleSet {
    rule("base premium") {
        priority = 100
        once = true
        whenever { +"age" atLeast 18 }
        then {
            "premium" becomes 500
            note("base premium set")
        }
    }
    rule("young driver") {
        priority = 90
        once = true
        whenever { (+"age" lt 25) and fact("premium").isSet }
        then {
            "premium" becomes "premium"() * 1.5
            note("young driver surcharge")
        }
    }
    rule("claims") {
        priority = 80
        once = true
        whenever { (+"claims" gt 2) or (+"points" gt 6) }
        then {
            "risk" becomes "high"
            note("high risk: claims=${"claims"()} points=${"points"()}")
        }
    }
    rule("high risk") {
        priority = 70
        once = true
        whenever { (+"risk" eq "high") and fact("premium").isSet }
        then {
            "premium" becomes "premium"() + 250.toValue()
            "manualReview" becomes true
        }
    }
    each(tiers) { (tier, discount) ->
        rule("discount $tier") {
            priority = 60
            once = true
            whenever { (+"tier" eq tier) and !fact("risk").isSet and fact("premium").isSet }
            then {
                if (discount > 0) "premium" becomes "premium"() * (1 - discount)
                note("$tier discount ${(discount * 100).toInt()}%")
            }
        }
    }
    rule("label") {
        priority = 10
        whenever { fact("premium").isSet and !fact("label").isSet }
        then {
            "label" becomes ("quote: ".toValue() + "premium"())
        }
    }
    rule("cleanup") {
        priority = 5
        once = true
        whenever { fact("manualReview").isTrue }
        then {
            drop("tier")
            note("tier dropped for review")
        }
    }
    rule("mid age") {
        whenever { +"age" `in` 30.0..50.0 }
        then { "band" becomes "mid" }
    }
}

fun quote(name: String, vararg facts: Pair<String, Value>) {
    println("== $name")
    val memory = Facts(mapOf(*facts))
    val engine = Engine(quoteRules)
    val notes = engine.run(memory) { println(it) }
    println("notes: $notes")
    println("facts: $memory (${engine.lastRounds} rounds)")
    memory.trail.forEach { println("  $it") }
}

fun main() {
    quoteRules.forEach { println(it) }
    quote("ada", "age" to 34.toValue(), "claims" to 0.toValue(), "points" to 1.toValue(), "tier" to "gold".toValue())
    quote("tom", "age" to 21.toValue(), "claims" to 3.toValue(), "points" to 0.toValue(), "tier" to "silver".toValue())
    quote("kid", "age" to 16.toValue(), "tier" to "bronze".toValue())
    quote("odd", "age" to "forty".toValue(), "claims" to 1.toValue(), "points" to 9.toValue())

    val looping = ruleSet {
        rule("ping") {
            whenever { fact("x").isSet }
            then { "x" becomes ("x"() as Value.Num).v + 1 }
        }
    }
    try {
        Engine(looping, maxRounds = 4).run(Facts(mapOf("x" to 0.toValue())))
    } catch (e: RuleCycleException) {
        println("cycle: ${e.message} after ${e.rounds}")
    }
    try {
        ruleSet { rule("broken") { whenever { always() } } }
    } catch (e: IllegalStateException) {
        println("invalid: ${e.message}")
    }
    try {
        ruleSet { rule("no condition") { then { note("x") } } }
    } catch (e: IllegalStateException) {
        println("invalid: ${e.message}")
    }
    val f = Facts()
    f += "a" to 1.toValue()
    f["b"] = "two".toValue()
    f["a"] = 1.toValue()
    f -= "zzz"
    println("$f ${"a" in f} ${f["c"]} ${f["a"] < f["a"] + 1.toValue()} ${Value.Missing}")
    println(listOf(3.toValue(), 1.5.toValue(), (-2).toValue()).sorted())
    println(listOf("pear".toValue(), "apple".toValue()).maxOrNull())
    try {
        listOf(1.toValue(), "x".toValue()).sorted()
    } catch (e: IllegalArgumentException) {
        println("sort failed: ${e.message}")
    }
}
