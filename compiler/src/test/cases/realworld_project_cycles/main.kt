package calc

import calc.eval.Value
import calc.eval.builtins
import calc.eval.define
import calc.eval.reserved
import calc.lang.keywords
import calc.lang.run
import calc.report.Stats
import calc.report.resetDepth

// A tiny Lisp calculator whose files import each other: main.kt <-> lang <-> eval, with top-level state on every file of
// the cycle. `trace` lives here, in the entry file, so the entry file is itself imported by the others.

var traceCount = 0
    private set

val traces = mutableListOf<String>()

fun trace(msg: String) {
    traceCount++
    traces += msg
}

fun show(v: Value): String = when (v) {
    is Value.I -> v.n.toString()
    is Value.Q -> "'${v.node}"
}

fun main() {
    println("keywords $keywords reserved $reserved")
    println("${builtins.keys} operators ${calc.lang.operatorSymbols}")
    println(show(run("(+ 1 2 (* 3 4))")))
    println(show(run("(let x 5 (- x 1 1))")))
    println(show(run("(quote (a b))")))
    println(Stats.line())
    resetDepth()
    define("sq") { xs -> xs[0] * xs[0] }
    println(show(run("(sq (max 3 9 4))")))
    println(show(run("(eval [+_2_[sq_3]])")))
    println(runCatching { define("let") { 0 } }.exceptionOrNull()?.message)
    println(runCatching { run("(nope 1)") }.exceptionOrNull()?.message)
    println(Stats.line())
    println("traces $traceCount:")
    traces.forEach { println("  $it") }
}
