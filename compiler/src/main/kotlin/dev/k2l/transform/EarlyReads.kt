package dev.k2l.transform

import com.intellij.psi.PsiElement
import dev.k2l.codegen.*
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.types.KaType
import org.jetbrains.kotlin.idea.references.mainReference
import org.jetbrains.kotlin.lexer.KtTokens
import org.jetbrains.kotlin.psi.*

/**
 * The JVM zeroes an object's fields before any constructor code runs, so code that runs earlier during construction (an
 * initializer or `init` block calling a method, a superclass constructor calling an override) reads `0`, `false` or `null`
 * from a property whose initializer has not run yet. Lua fields are nil until assigned, so the constructor of such a class
 * first stores those values (`self.y = 0`) for the properties that earlier construction code can reach.
 */
internal fun FileTransformer.earlyFieldDefaults(c: KtClassOrObject): Unit = with(session) {
    for (p in earlyReadProperties(c)) {
        val zero = jvmFieldDefault(p.symbol.returnType) ?: continue
        emit(assign(LuaIndex(selfRef(), LuaString(fieldKey(p))), zero))
    }
}

/** What a field of [type] holds before it is initialized, as far as Lua's nil differs from it (`null` stays nil). */
internal fun KaSession.jvmFieldDefault(type: KaType): LuaExpr? = when {
    type.isMarkedNullable -> null

    type.isBooleanType -> LuaBool(false)

    type.isIntegral -> LuaNumber("0")

    type.isDoubleType || type.isFloatType -> LuaNumber("0.0")

    // a non-null String that is null on the JVM prints as "null" (and a Lua concatenation of nil would fail)
    type.isStringType -> LuaString("null")

    else -> null
}

/** The properties of [c] with an initializer that code running before that initializer (see [earlyFieldDefaults]) can read. */
private fun FileTransformer.earlyReadProperties(c: KtClassOrObject): List<KtProperty> {
    val candidates = c.declarations.filterIsInstance<KtProperty>().filter {
        it.initializer != null && it.receiverTypeReference == null && !it.hasModifier(KtTokens.LATEINIT_KEYWORD) && props.hasOwnField(it)
    }
    if (candidates.isEmpty()) return emptyList()
    val reads = ReachableReads(functionsByName())
    // a superclass's constructor runs first, and may call functions that the class overrides
    classes.hierarchy(c).filter { it != c && !(it is KtClass && it.isInterface()) }.forEach { reads.scan(constructionCode(it)) }
    val result = mutableListOf<KtProperty>()
    for (decl in c.declarations) {
        if (decl is KtProperty && decl in candidates && decl in reads.reached) result += decl
        reads.scan(constructionCode(decl))
    }
    return result
}

/** The code of [decl] that runs while its class is constructed: initializers, `init` blocks, secondary constructor bodies. */
private fun constructionCode(decl: KtElement): List<PsiElement> = when (decl) {
    is KtClassOrObject -> decl.declarations.flatMap(::constructionCode)
    is KtProperty -> listOfNotNull(decl.initializer, decl.delegateExpression)
    is KtAnonymousInitializer -> listOfNotNull(decl.body)
    is KtSecondaryConstructor -> listOfNotNull(decl.bodyExpression)
    else -> emptyList()
}

private val FUNCTIONS_BY_NAME = SharedKey<Map<String, List<KtNamedFunction>>>("functionsByName")

private fun FileTransformer.functionsByName(): Map<String, List<KtNamedFunction>> = classes.module.shared.getOrPut(FUNCTIONS_BY_NAME) {
    val result = HashMap<String, MutableList<KtNamedFunction>>()
    classes.module.files.forEach { file ->
        file.accept(object : KtTreeVisitorVoid() {
            override fun visitNamedFunction(function: KtNamedFunction) {
                function.name?.let { result.getOrPut(it) { mutableListOf() } += function }
                super.visitNamedFunction(function)
            }
        })
    }
    result
}

/**
 * The properties that some code reads, directly or through the functions and accessors it calls (overrides included: every
 * function of the module with the called name).
 */
private class ReachableReads(private val functions: Map<String, List<KtNamedFunction>>) {
    val reached = HashSet<PsiElement>()
    private val visited = HashSet<PsiElement>()

    fun scan(roots: List<PsiElement>) {
        val pending = ArrayDeque(roots)
        while (pending.isNotEmpty()) {
            val root = pending.removeFirst()
            if (!visited.add(root)) continue
            root.accept(object : KtTreeVisitorVoid() {
                override fun visitSimpleNameExpression(expression: KtSimpleNameExpression) {
                    when (val target = expression.mainReference.resolve()) {
                        is KtNamedFunction -> functions[target.name].orEmpty().mapNotNullTo(pending) { it.bodyExpression }

                        is KtProperty -> {
                            reached += target
                            listOfNotNull(target.getter, target.setter).mapNotNullTo(pending) { it.bodyExpression }
                        }

                        else -> Unit
                    }
                    super.visitSimpleNameExpression(expression)
                }
            })
        }
    }
}
