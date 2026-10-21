// Char.directionality and CharDirectionality (ASCII characters)
fun main() {
    println(CharDirectionality.entries.joinToString { "${it.name}=${it.value}" })
    println(CharDirectionality.values().size)
    println(CharDirectionality.valueOf("WHITESPACE").ordinal)
    println((0 until 128).map { it.toChar() }.groupBy { it.directionality }.mapValues { it.value.size })
    println("a1 +,\t\n#".map { it.directionality })
    println(listOf('a'.directionality == CharDirectionality.LEFT_TO_RIGHT, '5'.directionality.value))
}
