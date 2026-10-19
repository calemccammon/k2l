fun main() {
    val ub: UByte = 0x81u
    println(ub.rotateLeft(1))
    println(ub.rotateLeft(0))
    println(ub.rotateLeft(3))
    println(ub.rotateLeft(8))
    println(ub.rotateLeft(9))
    println(ub.rotateLeft(-1))
    println(ub.rotateRight(1))
    println(ub.rotateRight(3))
    println(ub.rotateRight(-3))
    println(ub.rotateRight(17))
    println(0xF0u.toUByte().rotateLeft(4))
    println(0u.toUByte().rotateLeft(5))
    println(255u.toUByte().rotateRight(2))

    val us: UShort = 0x8001u
    println(us.rotateLeft(1))
    println(us.rotateLeft(4))
    println(us.rotateLeft(16))
    println(us.rotateLeft(-1))
    println(us.rotateRight(1))
    println(us.rotateRight(5))
    println(us.rotateRight(20))
    println(0x1234u.toUShort().rotateLeft(8))
    println(0xFFFFu.toUShort().rotateRight(3))

    val b: Byte = -127
    println(b.rotateLeft(1))
    println(b.rotateLeft(0))
    println(b.rotateLeft(4))
    println(b.rotateLeft(9))
    println(b.rotateLeft(-1))
    println(b.rotateRight(1))
    println(b.rotateRight(3))
    println(b.rotateRight(-2))
    println(127.toByte().rotateLeft(1))
    println((-1).toByte().rotateLeft(3))
    println(0.toByte().rotateRight(3))

    val s: Short = -32767
    println(s.rotateLeft(1))
    println(s.rotateLeft(0))
    println(s.rotateLeft(8))
    println(s.rotateLeft(17))
    println(s.rotateLeft(-1))
    println(s.rotateRight(1))
    println(s.rotateRight(6))
    println(32767.toShort().rotateLeft(1))
    println((-1).toShort().rotateRight(5))

    val values = listOf<UByte>(1u, 2u, 128u, 255u)
    println(values.map { it.rotateLeft(7) })
    val bytes = listOf<Byte>(1, 2, -128, 127)
    println(bytes.map { it.rotateRight(1) })

    // Int and UInt keep working
    println(1.rotateLeft(31))
    println(0x80000000u.rotateLeft(1))
}
