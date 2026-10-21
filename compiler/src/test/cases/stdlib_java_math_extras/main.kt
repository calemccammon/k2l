// java.lang.Math's ceilDiv, ceilMod, the *Exact divisions, clamp, fma, scalb, getExponent, multiplyFull and multiplyHigh
fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: Exception) {
        println("$label EXC ${e::class.simpleName}: ${e.message}")
    }
}

/** Doubles and Floats printed by their static type (a list of them in an `Any` cannot tell 1.0 from 1 on every target). */
fun d(vararg xs: Double) = xs.joinToString(prefix = "[", postfix = "]")

fun fl(vararg xs: Float) = xs.joinToString(prefix = "[", postfix = "]")

fun main() {
    t("ceilDiv") { listOf(Math.ceilDiv(7, 2), Math.ceilDiv(-7, 2), Math.ceilDiv(7, -2), Math.ceilDiv(-7, -2), Math.ceilDiv(6, 3), Math.ceilDiv(Int.MIN_VALUE, -1)) }
    t("ceilDiv long") { listOf(Math.ceilDiv(7L, 2L), Math.ceilDiv(-7L, 2L), Math.ceilDiv(10_000_000_001L, 10L), Math.ceilDiv(9L, 4)) }
    t("ceilMod") { listOf(Math.ceilMod(7, 2), Math.ceilMod(-7, 2), Math.ceilMod(7, -2), Math.ceilMod(-7, -2), Math.ceilMod(6, 3)) }
    t("ceilMod long") { listOf(Math.ceilMod(7L, 2L), Math.ceilMod(-7L, 3L), Math.ceilMod(9L, 4)) }
    t("ceilDiv zero") { Math.ceilDiv(1, 0) }
    t("ceilDiv long zero") { Math.ceilDiv(1L, 0L) }
    t("divideExact") { listOf(Math.divideExact(7, 2), Math.divideExact(-7, 2), Math.divideExact(7L, -2L), Math.divideExact(-9L, -2L)) }
    t("divideExact overflow") { Math.divideExact(Int.MIN_VALUE, -1) }
    t("divideExact long overflow") { Math.divideExact(Long.MIN_VALUE, -1L) }
    t("divideExact zero") { Math.divideExact(3, 0) }
    t("floorDivExact") { listOf(Math.floorDivExact(-7, 2), Math.floorDivExact(7, -2), Math.floorDivExact(-7L, 2L)) }
    t("floorDivExact overflow") { Math.floorDivExact(Int.MIN_VALUE, -1) }
    t("floorDivExact long overflow") { Math.floorDivExact(Long.MIN_VALUE, -1L) }
    t("ceilDivExact") { listOf(Math.ceilDivExact(-7, 2), Math.ceilDivExact(7, 2), Math.ceilDivExact(7L, 2L)) }
    t("ceilDivExact overflow") { Math.ceilDivExact(Int.MIN_VALUE, -1) }

    t("clamp int") { listOf(Math.clamp(5L, 1, 10), Math.clamp(-5L, 1, 10), Math.clamp(50L, 1, 10), Math.clamp(3_000_000_000L, 0, Int.MAX_VALUE)) }
    t("clamp long") { listOf(Math.clamp(5L, 1L, 10L), Math.clamp(-5L, 1L, 10L), Math.clamp(50_000_000_000L, 1L, 10_000_000_000L)) }
    t("clamp double") { d(Math.clamp(1.5, 0.0, 1.0), Math.clamp(-1.5, 0.0, 1.0), Math.clamp(0.25, 0.0, 1.0), Math.clamp(Double.NaN, 0.0, 1.0), Math.clamp(-0.0, 0.0, 1.0), Math.clamp(0.0, -0.0, 0.0)) }
    t("clamp float") { fl(Math.clamp(2.5f, 0f, 1f), Math.clamp(0.1f, 0f, 1f), Math.clamp(-3f, -2f, 2f)) }
    t("clamp reversed") { Math.clamp(5L, 10, 1) }
    t("clamp long reversed") { Math.clamp(5L, 10L, 1L) }
    t("clamp double reversed") { Math.clamp(5.0, 2.5, 1.0) }
    t("clamp zeros") { Math.clamp(5.0, 0.0, -0.0) }
    t("clamp float reversed") { Math.clamp(5f, 0.1f, 0.05f) }
    t("clamp NaN min") { Math.clamp(5.0, Double.NaN, 1.0) }
    t("clamp NaN max") { Math.clamp(5.0, 1.0, Double.NaN) }

    t("fma") { d(Math.fma(2.0, 3.0, 4.0), Math.fma(0.1, 10.0, -1.0), Math.fma(1.0 + 1e-15, 1.0 - 1e-15, -1.0), Math.fma(-0.0, 1.0, 0.0), Math.fma(Double.POSITIVE_INFINITY, 0.0, 1.0)) }
    t("fma float") { fl(Math.fma(2f, 3f, 4f), Math.fma(0.1f, 10f, -1f), Math.fma(1.5f, 1.5f, 0.25f)) }
    t("fma vs plain") { "${0.1 * 10.0 - 1.0}" }

    t("getExponent") { listOf(1.0, 2.0, 3.99, 0.5, 1e-300, 1e300, 0.0, Double.MIN_VALUE, 2.2250738585072014E-308, Double.NaN, Double.NEGATIVE_INFINITY, -1024.0).map { Math.getExponent(it) } }
    t("getExponent float") { listOf(1f, 3f, 0.1f, 0f, Float.MIN_VALUE, 1.17549435E-38f, Float.MAX_VALUE, Float.NaN).map { Math.getExponent(it) } }
    t("scalb") { d(Math.scalb(1.0, 10), Math.scalb(3.0, -1), Math.scalb(1.0, 1024), Math.scalb(1.0, -1074), Math.scalb(1.0, -1075), Math.scalb(Double.MAX_VALUE, -2000), Math.scalb(1.5, -1073), Math.scalb(-0.0, 5)) }
    t("scalb float") { fl(Math.scalb(1f, 10), Math.scalb(3f, -2), Math.scalb(1f, 128), Math.scalb(1f, -149), Math.scalb(1f, -150), Math.scalb(1f, 300)) }

    t("multiplyFull") { listOf(Math.multiplyFull(100000, 100000), Math.multiplyFull(-46341, 46341), Math.multiplyFull(7, -6)) }
    t("multiplyHigh") { listOf(Math.multiplyHigh(1L shl 40, 1L shl 40), Math.multiplyHigh(-(1L shl 40), 1L shl 40), Math.multiplyHigh(3L, 5L), Math.multiplyHigh(-3L, 5L)) }
    t("unsignedMultiplyHigh") { listOf(Math.unsignedMultiplyHigh(1L shl 40, 1L shl 40), Math.unsignedMultiplyHigh(3L, 5L), Math.unsignedMultiplyHigh(-3L, 5L)) }
    t("StrictMath") { "${StrictMath.ceilDiv(7, 2)} ${StrictMath.scalb(1.0, 3)} ${StrictMath.getExponent(8.0)}" }
}
