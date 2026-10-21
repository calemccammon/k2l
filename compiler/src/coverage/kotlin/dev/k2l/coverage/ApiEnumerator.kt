package dev.k2l.coverage

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.jetbrains.kotlin.analysis.api.KaExperimentalApi
import org.jetbrains.kotlin.analysis.api.KaSession
import org.jetbrains.kotlin.analysis.api.analyze
import org.jetbrains.kotlin.analysis.api.annotations.KaAnnotated
import org.jetbrains.kotlin.analysis.api.symbols.KaCallableSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaClassKind
import org.jetbrains.kotlin.analysis.api.symbols.KaConstructorSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaEnumEntrySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedClassSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaNamedFunctionSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaPropertySymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbol
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolModality
import org.jetbrains.kotlin.analysis.api.symbols.KaSymbolVisibility
import org.jetbrains.kotlin.analysis.api.types.KaClassType
import org.jetbrains.kotlin.analysis.api.types.KaTypeParameterType
import org.jetbrains.kotlin.name.ClassId
import org.jetbrains.kotlin.name.FqName
import java.io.File

/** Lists the public API of the [Area]s, with the probes [ProbeWriter] writes for it. */
object ApiEnumerator {
    fun enumerate(work: File, areas: List<Area>): List<Api> {
        work.mkdirs()
        File(work, "Stub.kt").writeText("fun main() {}\n")
        val module = SourceModule("enumerate", listOf(work.toPath()))
        return SourceSession.create(listOf(module)).use { session ->
            analyze(session.files(module.name).single()) { areas.flatMap { Walker(this, it).apis() } }
        }
    }

    private class Walker(private val session: KaSession, private val area: Area) {
        private val writer = ProbeWriter(session)
        private val apis = mutableListOf<Api>()

        fun apis(): List<Api> = with(session) {
            for (name in area.packages) {
                val pkg = findPackage(FqName(name)) ?: error("no package $name")
                for (callable in pkg.packageScope.callables) add(callable, null)
                for (cls in pkg.packageScope.classifiers.filterIsInstance<KaNamedClassSymbol>()) {
                    if (included(cls)) classMembers(cls)
                }
            }
            for (id in area.classes) classMembers(findClass(ClassId.fromString(id)) as? KaNamedClassSymbol ?: error("no class $id"))
            apis.distinctBy { it.key + "\n" + it.signature }.sortedWith(compareBy({ it.key }, { it.signature }))
        }

        private fun KaSession.included(cls: KaNamedClassSymbol) = cls.visibility == KaSymbolVisibility.PUBLIC &&
            !cls.name.asString().startsWith("Abstract") && cls.classKind != KaClassKind.ANNOTATION_CLASS &&
            cls.name.asString() !in area.excludedClasses &&
            !cls.isInner

        private fun KaSession.classMembers(cls: KaNamedClassSymbol) {
            val statics = cls.staticDeclaredMemberScope.callables.filter { it !is KaEnumEntrySymbol }
            val members = if (area.staticsOnly) emptySequence() else cls.declaredMemberScope.callables
            for (callable in statics + members) add(callable, cls)
            if (!area.staticsOnly) for (c in cls.declaredMemberScope.constructors) add(c, cls)
            val nested = (cls.declaredMemberScope.classifiers + cls.staticDeclaredMemberScope.classifiers)
                .filterIsInstance<KaNamedClassSymbol>()
            for (inner in nested.distinct()) if (included(inner) && !area.staticsOnly) classMembers(inner)
        }

        private fun KaSession.add(symbol: KaCallableSymbol, owner: KaNamedClassSymbol?) {
            if (symbol !is KaNamedFunctionSymbol && symbol !is KaPropertySymbol && symbol !is KaConstructorSymbol) return
            if (symbol.visibility != KaSymbolVisibility.PUBLIC) return
            // a constructor of an abstract class is called by its subclasses, not by programs
            if (symbol is KaConstructorSymbol && owner?.modality in ABSTRACT) return
            val key = keyOf(symbol, owner)
            val signature = signatureOf(symbol)
            val id = symbol.callableId?.toString()
            val skipped = when {
                isDeprecated(symbol) -> "deprecated"
                requiresOptIn(symbol) || (owner != null && requiresOptIn(owner)) -> "experimental (opt-in)"
                else -> null
            }
            if (skipped != null) {
                apis += Api(area.name, key, signature, emptyList(), skipped, id)
                return
            }
            apis += try {
                Api(area.name, key, signature, writer.probes(symbol, owner), callableId = id)
            } catch (e: NotProbeable) {
                Api(area.name, key, signature, emptyList(), "no probe: ${e.message}", id)
            }
        }

        @OptIn(KaExperimentalApi::class)
        private fun KaSession.isDeprecated(symbol: KaSymbol) = symbol.deprecation != null

        /** Annotated with an opt-in marker (`@ExperimentalTime`): an annotation class that is itself `@RequiresOptIn`. */
        private fun KaSession.requiresOptIn(symbol: KaSymbol): Boolean = (symbol as? KaAnnotated)?.annotations.orEmpty().any { annotation ->
            val cls = annotation.classId?.let { findClass(it) } ?: return@any false
            (cls as KaAnnotated).annotations.any { it.classId?.asString() == "kotlin/RequiresOptIn" }
        }

        /**
         * The report's name for a callable's overloads: `Iterable.chunked`, `ArrayList.<init>`, `listOf`; the primitive
         * arrays share `*Array.sum`.
         */
        private fun KaSession.keyOf(symbol: KaCallableSymbol, owner: KaNamedClassSymbol?): String {
            val name = if (symbol is KaConstructorSymbol) "<init>" else symbol.callableId!!.callableName.asString()
            val receiver = symbol.receiverParameter?.returnType?.let { t ->
                when (val r = t.lowerBoundIfFlexible()) {
                    is KaClassType -> r.classId.relativeClassName.asString().let { if (it in PRIMITIVE_ARRAYS) "*Array" else it }

                    // `C : Iterable<T>` of `C.onEach` is named by its bound
                    is KaTypeParameterType ->
                        (r.symbol.upperBounds.singleOrNull() as? KaClassType)?.takeIf {
                            !it.isAnyType
                        }?.classId?.relativeClassName?.asString()
                            ?: r.name.asString()

                    else -> "T"
                }
            }
            val ownerName = owner?.classId?.relativeClassName?.asString()
            return listOfNotNull(ownerName, receiver, name).joinToString(".")
        }

        private fun KaSession.signatureOf(symbol: KaCallableSymbol): String {
            val types = TypeSource(this, short = true)
            val receiver = symbol.receiverParameter?.returnType?.let { types.render(it)?.let { r -> "$r." } }.orEmpty()
            val typeParams = typeParametersOf(symbol).takeIf { it.isNotEmpty() && symbol !is KaConstructorSymbol }
                ?.joinToString(", ", "<", "> ") { it.name.asString() }.orEmpty()
            val name = if (symbol is KaConstructorSymbol) "constructor" else symbol.callableId!!.callableName.asString()
            val static = if ((symbol as? KaNamedFunctionSymbol)?.isStatic == true ||
                (symbol as? KaPropertySymbol)?.isStatic == true
            ) {
                "static "
            } else {
                ""
            }
            return when (symbol) {
                is KaPropertySymbol -> "${static}val $typeParams$receiver$name: ${types.render(symbol.returnType)}"

                is KaFunctionSymbol -> {
                    val params = symbol.valueParameters.joinToString { p ->
                        (if (p.isVararg) "vararg " else "") + "${p.name}: ${types.render(p.returnType)}" +
                            if (p.hasDefaultValue) " = ..." else ""
                    }
                    val result = if (symbol is KaConstructorSymbol) "" else ": ${types.render(symbol.returnType)}"
                    "${static}fun $typeParams$receiver$name($params)$result"
                }

                else -> name
            }
        }

        companion object {
            private val ABSTRACT = setOf(KaSymbolModality.ABSTRACT, KaSymbolModality.SEALED)

            private val PRIMITIVE_ARRAYS =
                listOf("Int", "Long", "Short", "Byte", "Char", "Float", "Double", "Boolean").map { "${it}Array" }.toSet()
        }
    }
}
