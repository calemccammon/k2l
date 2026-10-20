// Collections and boxed arrays to primitive arrays (toCharArray(), toIntArray(), ...) and back.
import java.util.LinkedList

fun kind(x: Any): String = when (x) {
    is CharArray -> "CharArray"
    is IntArray -> "IntArray"
    is LongArray -> "LongArray"
    is DoubleArray -> "DoubleArray"
    is FloatArray -> "FloatArray"
    is BooleanArray -> "BooleanArray"
    is ByteArray -> "ByteArray"
    is ShortArray -> "ShortArray"
    else -> "other"
}

fun main() {
    val list: List<Char> = listOf('a', 'b', 'c')
    val ca = list.toCharArray()
    println("${kind(ca)} ${ca.concatToString()} ${ca.size}")
    val col: Collection<Char> = setOf('x', 'y')
    println(col.toCharArray().joinToString())
    println(kind(listOf(1, 2, 3).toIntArray()) + " " + listOf(1, 2, 3).toIntArray().sum())
    println(kind(listOf(1L, 2L).toLongArray()) + " " + listOf(1L, 2L).toLongArray().sum())
    println(kind(listOf(1.5, 2.0).toDoubleArray()) + " " + listOf(1.5, 2.0).toDoubleArray().sum())
    println(kind(listOf(1.5f, 2.0f).toFloatArray()) + " " + listOf(1.5f, 2.0f).toFloatArray().sum())
    println(kind(listOf(true, false).toBooleanArray()) + " " + listOf(true, false).toBooleanArray().toList())
    println(kind(listOf<Byte>(1, 2).toByteArray()) + " " + listOf<Byte>(1, 2).toByteArray().toList())
    println(kind(listOf<Short>(1, 2).toShortArray()) + " " + listOf<Short>(1, 2).toShortArray().toList())

    // other collections
    val dq = ArrayDeque(listOf('c', 'a', 'b'))
    println(dq.toCharArray().sorted())
    val jdq = java.util.ArrayDeque(listOf('z', 'y'))
    println(jdq.toCharArray().contentToString())
    println(LinkedList(listOf(3, 4)).toIntArray().contentToString())
    val m = mapOf('k' to 1.5, 'j' to 2.5)
    println(m.keys.toCharArray().concatToString() + " " + m.values.toDoubleArray().sum())
    println(listOf('a', 'b', 'c', 'd').subList(1, 3).toCharArray().concatToString())
    println(hashSetOf(1L, 2L).toLongArray().sum())
    println(mutableListOf(true).toBooleanArray().contentToString())
    println(listOf(1.25f).toFloatArray().contentToString())
    println(emptyList<Char>().toCharArray().size)

    // boxed arrays
    println(arrayOf('q', 'r').toCharArray().concatToString())
    println(kind(arrayOf(1, 2).toIntArray()) + " " + arrayOf(1, 2).toIntArray().toList())
    println(arrayOf(1.5, 2.5).toDoubleArray().contentToString())
    println(arrayOf(true).toBooleanArray().contentToString())
    println(arrayOf(7L).toLongArray().contentToString())
    println(arrayOf<Byte>(7).toByteArray().contentToString())

    // and back
    val chars = "hello".toList().sortedDescending().toCharArray()
    println(String(chars))
    println(chars.contentEquals(charArrayOf('o', 'l', 'l', 'h', 'e')))
    println('l' in chars)
    println(chars.toHashSet().size)
    println(chars.toList().joinToString(""))
    println(chars.toMutableList().apply { add('!') })
    println(chars.toSet())
    println(chars.asList())
    println(chars.reversed())
    val boxed: Array<Char> = chars.toTypedArray()
    println(boxed.toCharArray().contentToString())
    println(chars.indexOf('h'))
    println(chars.copyOf(2).concatToString())
    println(intArrayOf(1, 2).toList())
    println(intArrayOf(1, 2).toTypedArray().toList())
    println(setOf(1, 2).toIntArray().toList())
    println(listOf('a').toTypedArray().toCharArray().concatToString())
    println(sequenceOf('a', 'b').toList().toCharArray().size)
    println("abc".toList().toCharArray().concatToString())
}
