package generics.reified

import kotlin.reflect.KClass
import kotlin.reflect.KType
import kotlin.reflect.typeOf

// Inline reified helpers of a small serialization library: casts by type, a registry of codecs keyed by `T::class`,
// typed lookups in a heterogeneous bag, and an event dispatcher filtered by event type.

inline fun <reified T> Any?.castOrNull(): T? = this as? T

inline fun <reified T : Any> Any?.castOr(default: T): T = this as? T ?: default

inline fun <reified T> List<*>.countOf(): Int = count { it is T }

inline fun <reified T> Iterable<*>.firstOfType(): T? = firstOrNull { it is T } as T?

inline fun <reified T : Any> typeName(): String = T::class.simpleName ?: "?"

interface Codec<T : Any> {
    fun encode(value: T): String
    fun decode(text: String): T
}

class Registry {
    private val codecs = linkedMapOf<KClass<*>, Codec<*>>()

    fun <T : Any> register(type: KClass<T>, codec: Codec<T>) {
        check(type !in codecs) { "codec for ${type.simpleName} already registered" }
        codecs[type] = codec
    }

    inline fun <reified T : Any> register(codec: Codec<T>) = register(T::class, codec)

    inline fun <reified T : Any> register(crossinline encode: (T) -> String, crossinline decode: (String) -> T) =
        register(T::class, object : Codec<T> {
            override fun encode(value: T) = encode(value)
            override fun decode(text: String) = decode(text)
        })

    @Suppress("UNCHECKED_CAST")
    fun <T : Any> codecFor(type: KClass<T>): Codec<T> =
        codecs[type] as Codec<T>? ?: throw IllegalArgumentException("no codec for ${type.simpleName}")

    inline fun <reified T : Any> encode(value: T): String = codecFor(T::class).encode(value)

    inline fun <reified T : Any> decode(text: String): T = codecFor(T::class).decode(text)

    inline fun <reified T : Any> decodeList(text: String): List<T> =
        if (text.isEmpty()) emptyList() else text.split(";").map { decode<T>(it) }

    @Suppress("UNCHECKED_CAST")
    fun encodeAny(value: Any): String {
        val codec = codecs[value::class] as Codec<Any>? ?: return "<${value::class.simpleName}?>"
        return "${value::class.simpleName}:${codec.encode(value)}"
    }

    val types get() = codecs.keys.map { it.simpleName }
}

data class Point(val x: Int, val y: Int)
data class Color(val r: Int, val g: Int, val b: Int) {
    override fun toString() = "#%02x%02x%02x".format(r, g, b)
}
enum class Level { LOW, MID, HIGH }

object PointCodec : Codec<Point> {
    override fun encode(value: Point) = "${value.x},${value.y}"
    override fun decode(text: String) = text.split(',').let { (x, y) -> Point(x.trim().toInt(), y.trim().toInt()) }
}

class Bag {
    private val items = mutableListOf<Any>()
    fun add(vararg xs: Any) = apply { items.addAll(xs) }
    inline fun <reified T : Any> all(): List<T> = items().filterIsInstance<T>()
    inline fun <reified T : Any> one(): T = all<T>().singleOrNull() ?: error("expected one ${T::class.simpleName}, found ${all<T>().size}")
    fun items(): List<Any> = items
}

sealed class Event(val at: Int)
class Click(at: Int, val x: Int, val y: Int) : Event(at)
class Key(at: Int, val char: Char) : Event(at)
class Tick(at: Int) : Event(at)

class Dispatcher {
    val handlers = mutableListOf<Pair<KClass<out Event>, (Event) -> Unit>>()

    inline fun <reified E : Event> on(noinline handler: (E) -> Unit) {
        @Suppress("UNCHECKED_CAST")
        handlers += E::class to (handler as (Event) -> Unit)
    }

    fun dispatch(e: Event): Int {
        val matching = handlers.filter { (type, _) -> type.isInstance(e) }
        matching.forEach { (_, h) -> h(e) }
        return matching.size
    }
}

/** Default values keyed by the full type, so `List<Int>` and `List<String>` get different entries. */
class Defaults {
    private val values = HashMap<KType, Any?>()

    inline fun <reified T> put(value: T) = put(typeOf<T>(), value)

    fun put(type: KType, value: Any?) {
        values[type] = value
    }

    @Suppress("UNCHECKED_CAST")
    inline fun <reified T> get(): T = lookup(typeOf<T>()) as T

    fun lookup(type: KType): Any? = if (type in values) values[type] else throw NoSuchElementException("no default for $type")
}

fun main() {
    println("== casts")
    val things: List<Any?> = listOf(1, "two", 2.5, null, true, listOf(5), Level.LOW)
    println(things.map { it.castOrNull<Int>() })
    println(things.map { it.castOr("-") })
    println("strings=${things.countOf<String>()} numbers=${things.countOf<Number>()} lists=${things.countOf<List<*>>()}")
    println("firstEnum=${things.firstOfType<Level>()} firstBoolean=${things.firstOfType<Boolean>()} firstPoint=${things.firstOfType<Point>()}")
    println("names: ${typeName<Point>()} ${typeName<Level>()} ${typeName<String>()}")

    println("== registry")
    val registry = Registry()
    registry.register(PointCodec)
    registry.register<Color>({ it.toString() }, { s -> s.removePrefix("#").chunked(2).map { it.toInt(16) }.let { (r, g, b) -> Color(r, g, b) } })
    registry.register<Level>({ it.name.lowercase() }, { Level.valueOf(it.uppercase()) })
    registry.register<Int>({ it.toString(16) }, { it.toInt(16) })
    println("types=${registry.types}")
    println(registry.encode(Point(3, -4)) + " " + registry.encode(Color(255, 128, 0)) + " " + registry.encode(Level.HIGH))
    val p = registry.decode<Point>(" 7, 8")
    val c = registry.decode<Color>("#0a0b0c")
    println("decoded $p ${p.x + p.y} $c ${c.g} ${registry.decode<Level>("mid").ordinal} ${registry.decode<Int>("ff") + 1}")
    println("list=${registry.decodeList<Point>("1,2;3,4;5,6").sumOf { it.x * it.y }} empty=${registry.decodeList<Level>("")}")
    println(listOf(Point(1, 1), Level.LOW, 255, "text", Color(1, 2, 3)).joinToString(" ") { registry.encodeAny(it) })
    try {
        registry.decode<String>("x")
    } catch (e: IllegalArgumentException) {
        println("error: ${e.message}")
    }
    try {
        registry.register(PointCodec)
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }

    println("== bag")
    val bag = Bag().add(Point(0, 0), "label", Point(2, 2), Level.MID, 42)
    println("points=${bag.all<Point>()} level=${bag.one<Level>()} int=${bag.one<Int>() * 2} any=${bag.all<Any>().size}")
    try {
        bag.one<Point>()
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }

    println("== dispatcher")
    val d = Dispatcher()
    val log = mutableListOf<String>()
    d.on<Click> { log += "click ${it.x},${it.y}@${it.at}" }
    d.on<Key> { log += "key ${it.char.uppercaseChar()}@${it.at}" }
    d.on<Event> { log += "any@${it.at}" }
    val counts = listOf(Click(1, 10, 20), Key(2, 'q'), Tick(3), Click(4, 0, 0)).map(d::dispatch)
    println("counts=$counts")
    log.forEach(::println)

    println("== defaults by type")
    val defaults = Defaults()
    defaults.put(0)
    defaults.put(listOf("x"))
    defaults.put(listOf(1, 2))
    defaults.put<String?>(null)
    println("int=${defaults.get<Int>() + 1} strings=${defaults.get<List<String>>()} ints=${defaults.get<List<Int>>().sum()}")
    println("nullable=${defaults.get<String?>()} type=${typeOf<Map<String, List<Point>>>()}")
    try {
        defaults.get<List<Level>>()
    } catch (e: NoSuchElementException) {
        println("error: ${e.message}")
    }
}
