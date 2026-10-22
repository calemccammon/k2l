// withSign, rotations and single bits (the IEEE 754 bit patterns, toBits/fromBits/ulp/nextUp, are not supported)
import kotlin.math.sign
import kotlin.math.withSign

fun main() {
    println(3.5.withSign(-1.0))
    println((-3.5).withSign(1.0))
    println(2.0.withSign(-0.0))
    println(0.0.withSign(-2.0))
    println(5.0.withSign(-3))
    println(2.5f.withSign(-1f))
    println(0x12345678.rotateLeft(8))
    println(0x12345678.rotateRight(8))
    println((-1).rotateLeft(5))
    println(1.rotateRight(1))
    println(0x12345678.rotateLeft(0))
    println(0x12345678.rotateLeft(32))
    println(0x12345678.rotateLeft(-4))
    println(1.rotateLeft(31))
    println(100.takeHighestOneBit())
    println((-5).takeHighestOneBit())
    println(0.takeHighestOneBit())
    println(96.takeLowestOneBit())
    println(Int.MIN_VALUE.takeLowestOneBit())
    println(0.takeLowestOneBit())
    println(3.sign)
    println((-2.5).sign)
}
