// Library collection members called on a type parameter (`C : MutableCollection<in T>`), which has the
// representation of its bound, and on a smart cast to an intersection (`this is Collection<*>` of an Iterable).

fun <T, C : MutableCollection<in T>> Iterable<T>.copyInto(destination: C): C {
    for (element in this) destination.add(element)
    return destination
}

fun <T, C : MutableCollection<in T>> C.addTwice(element: T): C {
    add(element)
    this += element
    return this
}

fun <T, C : MutableCollection<T>> fill(destination: C, vararg elements: T): Int {
    destination.addAll(elements)
    destination += elements.toList()
    return destination.size
}

fun <K, V, M : MutableMap<in K, in V>> M.put2(key: K, value: V): M {
    this[key] = value
    return this
}

fun <K, M : MutableMap<K, MutableList<String>>> M.group(key: K, value: String): M {
    getOrPut(key) { mutableListOf() }.add(value)
    return this
}

fun <L : List<Int>> L.middle(): Int = this[size / 2]

fun <T, S> S.sizeOrDefault(default: Int): Int where S : Iterable<T> = if (this is Collection<*>) size else default

fun <T> Iterable<T>.sizeOr(default: Int): Int = if (this is Collection<*>) size else default

fun <E : Comparable<E>, B : MutableList<E>> B.sortedInPlace(): B {
    sort()
    return this
}

fun main() {
    println(listOf(1, 2, 3).copyInto(mutableListOf<Number>(0.5)))
    println(listOf("a", "b", "a").copyInto(linkedSetOf()))
    println(mutableListOf("x").addTwice("y"))
    println(hashSetOf(1).addTwice(1))
    val target = mutableListOf<String>()
    println(fill(target, "p", "q"))
    println(target)
    println(linkedMapOf("a" to 1).put2("b", 2))
    println(mutableMapOf<Int, MutableList<String>>().group(1, "one").group(2, "two").group(1, "uno"))
    println(listOf(4, 5, 6, 7, 8).middle())
    println(listOf(1, 2).sizeOrDefault<Int, List<Int>>(-1))
    println(listOf(1, 2, 3).sizeOr(-1))
    println(generateSequence(1) { if (it < 4) it + 1 else null }.asIterable().sizeOr(-1))
    println(mutableListOf(3, 1, 2).sortedInPlace())
}
