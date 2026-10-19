// The java.lang box statics that code ported from Java uses.

fun main() {
    println("${Integer.bitCount(255)} ${Integer.bitCount(-1)} ${Integer.highestOneBit(100)} ${Integer.lowestOneBit(96)}")
    println("${Integer.numberOfTrailingZeros(96)} ${Integer.numberOfLeadingZeros(1)} ${Integer.numberOfTrailingZeros(0)}")
    println("${Integer.rotateLeft(1, 33)} ${Integer.rotateRight(1, 1)} ${Integer.signum(-5)} ${Integer.signum(0)} ${Integer.signum(9)}")
    println("${Integer.max(3, 4)} ${Integer.min(3, 4)} ${Integer.toUnsignedString(-1)} ${Integer.toUnsignedString(255, 16)}")
    println("${java.lang.Long.bitCount(255L)} ${java.lang.Long.numberOfTrailingZeros(1L shl 20)} ${java.lang.Long.highestOneBit(1000L)}")
    println("${java.lang.Long.toBinaryString(10L)} ${java.lang.Long.toHexString(255L)} ${java.lang.Long.toOctalString(64L)}")
    println("${java.lang.Long.toHexString(-1L)} ${java.lang.Long.toBinaryString(-8L).length} ${java.lang.Long.toHexString(-4096L)}")
    println("${java.lang.Long.max(3L, 4L)} ${java.lang.Long.min(-3L, 4L)} ${java.lang.Long.signum(-5L)}")
    println("${Character.getNumericValue('7')} ${Character.getNumericValue('a')} ${Character.getNumericValue('Z')} ${Character.getNumericValue('-')}")
    println("${java.lang.Double.isNaN(0.0 / 0.0)} ${java.lang.Double.isNaN(1.0)} ${java.lang.Double.isInfinite(1.0 / 0.0)} ${java.lang.Double.isFinite(2.0)}")
    println("${java.lang.Double.valueOf("2.5") + 1} ${java.lang.Double.valueOf(4.0)} ${java.lang.Double.toString(2.0)} ${java.lang.Double.toString(0.1)}")
    println("${java.lang.Boolean.parseBoolean("TRUE")} ${java.lang.Boolean.parseBoolean("yes")} ${java.lang.Boolean.toString(false)} ${Character.toString('x')}")
    println("${java.lang.String.valueOf(3.5)} ${java.lang.String.valueOf(7)} ${java.lang.String.valueOf(true)} ${java.lang.String.valueOf('c')}")
    println("${java.lang.String.join("-", "x", "y", "z")} ${java.lang.String.join(", ", listOf("a", "b"))} [${java.lang.String.join("/")}]")
}
