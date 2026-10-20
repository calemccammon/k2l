package generics.variance

// Variance in a small event and ranking library: producers (`out`), consumers (`in`), star projections, `where` bounds
// and recursive bounds `T : Comparable<T>`.

interface Producer<out T> {
    fun produce(): T
}

interface Consumer<in T> {
    fun consume(item: T)
}

open class Animal(val name: String) : Comparable<Animal> {
    open val sound = "..."
    override fun compareTo(other: Animal) = name.compareTo(other.name)
    override fun toString() = "${this::class.simpleName}($name)"
}

class Dog(name: String, val tricks: Int = 0) : Animal(name) {
    override val sound = "woof"
}

class Cat(name: String, val lives: Int = 9) : Animal(name) {
    override val sound = "meow"
}

class Shelter<out T : Animal>(private val animals: List<T>) : Producer<T> {
    private var next = 0
    override fun produce(): T = animals[next++ % animals.size]
    fun all(): List<T> = animals
}

class Logger<in T>(private val prefix: String, private val render: (T) -> String) : Consumer<T> {
    val lines = mutableListOf<String>()
    override fun consume(item: T) {
        lines += "$prefix ${render(item)}"
    }
}

fun <T> transfer(from: Producer<T>, to: Consumer<T>, n: Int) = repeat(n) { to.consume(from.produce()) }

fun copyInto(source: List<out Animal>, target: MutableList<in Animal>) {
    for (a in source) target += a
}

fun describeAll(items: Collection<*>): String = items.joinToString { item ->
    when (item) {
        null -> "null"
        is Animal -> "animal ${item.name}"
        is Comparable<*> -> "comparable $item"
        else -> "other ${item::class.simpleName}"
    }
}

fun sizes(groups: Map<String, List<*>>): Map<String, Int> = groups.mapValues { (_, v) -> v.size }

fun <T : Comparable<T>> maxOf3(a: T, b: T, c: T): T = maxOf(a, maxOf(b, c))

fun <T : Comparable<T>> List<T>.isSorted(): Boolean = zipWithNext().all { (a, b) -> a <= b }

fun <T : Comparable<T>> List<T>.insertionSorted(): List<T> {
    val out = toMutableList()
    for (i in 1 until out.size) {
        val x = out[i]
        var j = i - 1
        while (j >= 0 && out[j] > x) {
            out[j + 1] = out[j]
            j--
        }
        out[j + 1] = x
    }
    return out
}

fun <K, V> topBy(entries: Map<K, V>, n: Int): List<K> where K : Comparable<K>, V : Comparable<V>, V : Number =
    entries.entries.sortedWith(compareByDescending<Map.Entry<K, V>> { it.value }.thenBy { it.key }).take(n).map { it.key }

fun <T> joinWhere(items: Iterable<T>): String where T : CharSequence, T : Comparable<T> =
    items.sorted().joinToString("+") { "${it.length}:$it" }

data class Version(val major: Int, val minor: Int, val patch: Int) : Comparable<Version> {
    override fun compareTo(other: Version) = compareValuesBy(this, other, Version::major, Version::minor, Version::patch)
    override fun toString() = "$major.$minor.$patch"

    companion object {
        fun parse(s: String): Version = s.split('.').map(String::toInt).let { (a, b, c) -> Version(a, b, c) }
    }
}

class Range<T : Comparable<T>>(val start: T, val end: T) {
    init {
        require(start <= end) { "empty range $start..$end" }
    }

    operator fun contains(x: T) = x >= start && x <= end
    fun clamp(x: T): T = if (x < start) start else if (x > end) end else x
    fun intersect(other: Range<T>): Range<T>? {
        val s = maxOf(start, other.start)
        val e = minOf(end, other.end)
        return if (s <= e) Range(s, e) else null
    }

    override fun toString() = "[$start, $end]"
}

abstract class Shape<Self : Shape<Self>> : Comparable<Self> {
    abstract val area: Double
    abstract fun scaled(k: Double): Self
    override fun compareTo(other: Self) = area.compareTo(other.area)
}

class Square(val side: Double) : Shape<Square>() {
    override val area get() = side * side
    override fun scaled(k: Double) = Square(side * k)
    override fun toString() = "Square($side)"
}

fun <S : Shape<S>> largestAfterScaling(shapes: List<S>, k: Double): S = shapes.map { it.scaled(k) }.max()

fun main() {
    println("== producers and consumers")
    val dogs = Shelter(listOf(Dog("rex", 3), Dog("fido")))
    val animals: Producer<Animal> = dogs
    val anyLog = Logger<Any>("any:") { it.toString() }
    val animalLog: Consumer<Animal> = Logger<Animal>("animal:") { "${it.name} says ${it.sound}" }
    transfer(animals, animalLog, 3)
    val dogLog: Consumer<Dog> = anyLog
    transfer(dogs, dogLog, 2)
    transfer(Shelter(listOf(Cat("tom", 7))), anyLog, 1)
    println((animalLog as Logger<*>).lines)
    println(anyLog.lines)

    println("== projections")
    val zoo = mutableListOf<Any>("keeper")
    copyInto(dogs.all(), zoo)
    copyInto(listOf(Cat("kit")), zoo)
    println(zoo)
    println(describeAll(listOf(Dog("a"), 3, "s", null, 2.5, listOf(1))))
    println(sizes(mapOf("dogs" to dogs.all(), "mixed" to listOf(1, "a", null), "none" to emptyList<Nothing>())))
    val unknown: List<*> = listOf(Cat("z"), Dog("y"))
    val firstAnimal = unknown.first() as? Animal
    println("first=${firstAnimal?.name} sound=${firstAnimal?.sound} sorted=${unknown.filterIsInstance<Animal>().sorted()}")

    println("== recursive bounds")
    println("max3=${maxOf3(3, 9, 4)} ${maxOf3("pear", "apple", "fig")} ${maxOf3(Dog("b"), Cat("c"), Dog("a"))}")
    val versions = listOf("1.10.0", "1.2.3", "1.2.10", "0.9.9", "2.0.0").map(Version::parse)
    println("sorted=${versions.insertionSorted()} isSorted=${versions.isSorted()} ${versions.sorted().isSorted()}")
    val supported = Range(Version(1, 2, 0), Version(1, 10, 0))
    println("in=${versions.filter { it in supported }} clamp=${supported.clamp(Version(3, 0, 0))}")
    println("intersect=${supported.intersect(Range(Version(1, 5, 0), Version(2, 0, 0)))} none=${Range(1, 3).intersect(Range(5, 9))}")
    try {
        Range("z", "a")
    } catch (e: IllegalArgumentException) {
        println("error: ${e.message}")
    }
    println("largest=${largestAfterScaling(listOf(Square(1.0), Square(3.0), Square(2.0)), 0.5)}")

    println("== where")
    println(topBy(mapOf("b" to 3, "a" to 3, "c" to 9, "d" to 1), 3))
    println(topBy(mapOf(2 to 0.5, 1 to 1.5), 5))
    println(joinWhere(listOf("gamma", "alpha", "beta")))
    println(joinWhere(listOf(StringBuilder("x").toString(), "yy")))
}
