// String.format details found by the realworld_text_* programs: relative indices (%<s), %h, %g choosing its form
// after rounding, zero padding after the 0x of %#x, %x/%o of negative Bytes, Shorts and Longs, %c of code points,
// the Locale overload of format(null, ...) and java.util.Formatter's exception classes and messages.

fun t(f: () -> String) {
    try {
        println(f())
    } catch (e: IllegalArgumentException) {
        println(e)
    }
}

fun main() {
    t { String.format("%2\$s %1\$s %2\$s %<s %s %s", "a", "b") }
    t { String.format("%s %<S %<10s| %d %<x %<o", "kotlin", 255) }
    t { String.format("%h %h %h %H %h %h", "hello", 42, 1.5, "Kotlin", null, true) }
    t { String.format("%10h|%-10H|%.3h", "hello", "hello", "hello") }
    t { String.format("%g %g %.2g %g %g %.3g", 999.9999, 99999.95, 0.000099999, 1e-5, 0.0001, 9.9951) }
    t { String.format("%G %.1g %.0g %g %g", 1234567.0, 0.95, 5.5, -123.456, 100000.0) }
    t { String.format("%#010x %#06X %#o %08X %#x", 0xBEEF, 255, 8, 0xBEEF, 0) }
    val b: Byte = -1
    val s: Short = -2
    val l = -3L
    t { String.format("%x %x %x %o %o %X", b, s, l, b, l, Long.MIN_VALUE) }
    t { String.format("%x %x %d %d", (-128).toByte(), Short.MIN_VALUE, b, s) }
    val nb: Byte? = -16
    t { String.format("%02x:%02x:%02x", nb, 10.toByte(), 0xAB.toByte()) }
    t { "%08x %x".format(-1L shl 4, (1L shl 52) - 1) }
    t { String.format("%c%c%c %c|%3c|%-3c|", 72, 0xE9, 0x20AC, 0x1F600, 'x', 'y') }
    t { String.format("%.2b %B %b %5b|", true, false, null, "x") }
    t { "%s %s".format(null, 2) }
    t { "%s".format(null) }
    t { "[%s]".format(null, "x") }
    t { String.format("%q", 1) }
    t { String.format("abc %") }
    t { String.format("%5%|%-5%|%n|") }
    t { String.format("%-d", 1) }
    t { String.format("%0s", "x") }
    t { String.format("%d", "s") }
    t { String.format("%f", "s") }
    t { String.format("%x", true) }
    t { String.format("%.2d", 1) }
    t { String.format("%.2x", 1) }
    t { String.format("%<s", 1) }
    t { String.format("%s %s", 1) }
    t { String.format("%3\$s", 1) }
    try {
        String.format("%s %s %s", "only one")
    } catch (e: java.util.MissingFormatArgumentException) {
        println("caught MissingFormatArgumentException: ${e.message}")
    }
    try {
        String.format("%z")
    } catch (e: java.util.IllegalFormatException) {
        println("caught IllegalFormatException: ${e.message}")
    }
}
