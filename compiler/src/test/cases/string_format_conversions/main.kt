// String.format rejects an argument its conversion does not take with java.util.Formatter's IllegalFormatConversionException,
// by the class of the argument's static type: %f of an Int, %d of a Double, %c of a Long or a String, ...

import java.math.BigDecimal
import java.math.BigInteger

class Point(val x: Int) {
    override fun toString() = "Point($x)"
}

fun attempt(label: String, block: () -> String) {
    try {
        println("$label: ${block()}")
    } catch (e: IllegalArgumentException) {
        println("$label: ${e::class.simpleName} ${e.message}")
    }
}

fun main() {
    val i = 5
    val l = 7L
    val d = 2.0
    val f = 1.5f
    val c = 'x'
    val s = "y"
    val b = true
    val sh: Short = 3
    val by: Byte = 4
    val bi = BigInteger.TEN
    val bd = BigDecimal("1234.5")
    val u = 5u
    val p = Point(1)
    val none: Int? = null
    val some: Int? = 6
    attempt("%f Int") { "%f".format(i) }
    attempt("%e Int") { String.format("%e", i) }
    attempt("%g Long") { "%g".format(l) }
    attempt("%c Long") { "%c".format(l) }
    attempt("%d Double") { String.format("%d", d) }
    attempt("%x Double") { "%x".format(d) }
    attempt("%c Double") { "%c".format(d) }
    attempt("%d Float") { "%d".format(f) }
    attempt("%x Char") { "%x".format(c) }
    attempt("%f Char") { "%f".format(c) }
    attempt("%c String") { "%c".format(s) }
    attempt("%d String") { "%d".format(s) }
    attempt("%c Boolean") { "%c".format(b) }
    attempt("%e Short") { "%e".format(sh) }
    attempt("%f Byte") { "%f".format(by) }
    attempt("%d BigDecimal") { "%d".format(bd) }
    attempt("%f BigInteger") { "%f".format(bi) }
    attempt("%d UInt") { "%d".format(u) }
    attempt("%d Point") { "%d".format(p) }
    attempt("%f null") { "%f".format(none) }
    attempt("%f Int?") { "%f".format(some) }
    attempt("%X Int?") { "%X".format(some) }
    // what each conversion takes
    attempt("taken") { "%d %s %c %.1f %x %c %c %e %o".format(i, s, c, d, by, sh, 65, f, l) }
    attempt("BigDecimal") { "%f|%.1f|%,.3f|%12.0f|%(.2f".format(bd, bd, bd, bd, bd.negate()) }
    attempt("BigInteger") { "%d %x %,d".format(bi, bi, bi.pow(4)) }
    attempt("strings") { "%s %s %s %b %h".format(i, d, c, i, s) }
    attempt("locale") { String.format(java.util.Locale.GERMANY, "%,.2f %f", bd, i) }
    attempt("locale ok") { String.format(java.util.Locale.GERMANY, "%,.2f %d", bd, i) }
    // the specifier that rejects its argument decides, in order
    attempt("second") { "%s %f".format(i, i) }
    attempt("indexed") { "%1\$s %1\$d %1\$f".format(i) }
    attempt("previous") { "%d %<f".format(i) }
    attempt("before missing") { "%f %s".format(i) }
    attempt("missing before") { "%s %s %f".format(d, d) }
    // a format that is not a literal checks every argument
    val formats = listOf("%f", "%d", "%c")
    for (format in formats) {
        attempt("dynamic $format Int") { String.format(format, i) }
        attempt("dynamic $format Double") { format.format(d) }
        attempt("dynamic $format Char") { format.format(c) }
    }
    // without a static type the value decides where it can
    val values = listOf<Any?>(true, p, bd, bi, 2.5, "text")
    for (v in values) attempt("Any %c $v") { "%c".format(v) }
    for (v in values) attempt("Any %d $v") { "%d".format(v) }
}
