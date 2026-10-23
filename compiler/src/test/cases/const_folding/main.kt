package app

// Each const val is written as its value where it is defined; lib/check.lua reads the definitions.
object Limits {
    const val MAX = 20
    const val HALF = MAX / 2
    const val NEGATIVE_HALF = -7 / 2
    const val REMAINDER = -7 % 3
    const val WRAPPED = Int.MAX_VALUE + 1
    const val SHIFTED = 1 shl 31
    const val BIG = 1L shl 40
    const val LONG_WRAPPED = Long.MAX_VALUE + 1
    const val THIRD = 1.0 / 3
    const val SUM = 0.1 + 0.2
    const val WHOLE = MAX * 1.5
    const val FLOAT = 0.1f * 3
    const val NEXT = 'a' + 2
    const val LABEL = "max=" + MAX + " third=" + THIRD + " whole=" + WHOLE
    const val FLAG = MAX > 10 && HALF == 10
}

class Box {
    companion object {
        const val SIZE = (Limits.HALF * 3)
    }
}

const val AREA = Box.SIZE * Box.SIZE

fun main() {
    println(Limits.HALF)
    println(Limits.NEGATIVE_HALF)
    println(Limits.REMAINDER)
    println(Limits.WRAPPED)
    println(Limits.SHIFTED)
    println(Limits.BIG)
    println(Limits.LONG_WRAPPED)
    println(Limits.THIRD)
    println(Limits.SUM)
    println(Limits.WHOLE)
    println(Limits.FLOAT)
    println(Limits.NEXT)
    println(Limits.LABEL)
    println(Limits.FLAG)
    println(Box.SIZE)
    println(AREA)
}
