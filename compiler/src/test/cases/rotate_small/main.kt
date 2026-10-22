fun main() {
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

    val bytes = listOf<Byte>(1, 2, -128, 127)
    println(bytes.map { it.rotateRight(1) })

    println(1.rotateLeft(31))
}
