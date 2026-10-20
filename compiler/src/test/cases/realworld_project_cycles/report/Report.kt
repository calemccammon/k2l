package calc.report

import calc.eval.evaluations
import calc.lang.maxDepth
import calc.lang.parsedNodes
import calc.traceCount

// Not on the cycle itself, but reads state that the files on it mutate.

object Stats {
    var reports = 0

    fun line(): String {
        reports++
        return "report#$reports nodes=$parsedNodes evals=$evaluations depth=$maxDepth traces=$traceCount"
    }
}

fun resetDepth() {
    maxDepth = 0
}
