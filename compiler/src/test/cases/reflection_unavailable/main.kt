data class D(val x: Int)
object O
sealed class S
open class Op
abstract class Ab

fun probe(name: String, f: () -> Any?) {
    try {
        println("$name = ${f()}")
    } catch (e: Throwable) {
        println("$name threw ${e::class.simpleName}")
    }
}

fun main() {
    probe("isData") { D::class.isData }
    probe("objectInstance") { O::class.objectInstance }
    probe("sealedSubclasses") { S::class.sealedSubclasses }
    probe("isOpen") { Op::class.isOpen }
    probe("isAbstract") { Ab::class.isAbstract }
    probe("isFinal") { D::class.isFinal }
    probe("isSealed") { S::class.isSealed }
    probe("isCompanion") { D::class.isCompanion }
    probe("isInner") { D::class.isInner }
    probe("supertypes") { D::class.supertypes }
}
