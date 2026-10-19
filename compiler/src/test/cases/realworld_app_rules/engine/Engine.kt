package rules.engine

import rules.dsl.ActionScope
import rules.dsl.Rule

class RuleCycleException(val rounds: Int) : RuntimeException("no fixpoint after $rounds rounds")

/** Forward chaining: fire every rule whose condition holds, until nothing changes. */
class Engine(private val rules: List<Rule>, private val maxRounds: Int = 10) {
    var lastRounds = 0
        private set

    fun run(facts: Facts, trace: (String) -> Unit = {}): List<String> {
        val fired = mutableListOf<String>()
        val firedOnce = mutableSetOf<String>()
        var round = 0
        do {
            round++
            if (round > maxRounds) throw RuleCycleException(maxRounds)
            val before = facts.snapshot()
            for (rule in rules) {
                if (rule.once && rule.name in firedOnce) continue
                val holds = try {
                    rule.condition.test(facts)
                } catch (e: IllegalArgumentException) {
                    trace("  ${rule.name}: ${e.message}")
                    false
                }
                if (!holds) continue
                trace("  round $round: ${rule.name}")
                ActionScope(facts, fired).apply(rule.action)
                firedOnce += rule.name
            }
            val changed = facts.snapshot() != before
        } while (changed)
        lastRounds = round
        return fired
    }
}
