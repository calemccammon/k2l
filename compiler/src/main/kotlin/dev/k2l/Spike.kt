package dev.k2l

import dev.k2l.frontend.SourceSession
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.resolution.successfulFunctionCallOrNull
import org.jetbrains.kotlin.analysis.api.resolution.symbol
import org.jetbrains.kotlin.psi.KtCallExpression
import org.jetbrains.kotlin.psi.KtTreeVisitorVoid
import java.nio.file.Paths
import kotlin.system.exitProcess

/** Milestone 1: prove we can resolve calls and types in a standalone session. */
fun main(args: Array<String>) {
    val roots = args.map { Paths.get(it) }.ifEmpty { listOf(Paths.get("examples/hello")) }
    SourceSession.create(roots).use { session ->
        for (file in session.files) {
            println("== ${file.virtualFile.path}")
            analyze(file) {
                file.accept(object : KtTreeVisitorVoid() {
                    override fun visitCallExpression(expression: KtCallExpression) {
                        super.visitCallExpression(expression)
                        val call = expression.resolveToCall()?.successfulFunctionCallOrNull()
                        println("${expression.text.lineSequence().first()}  ->  ${call?.symbol?.callableId}  : ${expression.expressionType}")
                    }
                })
            }
        }
    }
    // IntelliJ leaves non-daemon pool threads behind.
    exitProcess(0)
}
