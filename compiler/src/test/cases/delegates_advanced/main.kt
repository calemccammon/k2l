import kotlin.properties.ReadOnlyProperty
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

// provideDelegate: runs once, where the property is initialized, and decides the real delegate
class Logged(private val tag: String) {
    operator fun provideDelegate(thisRef: Any?, property: KProperty<*>): Cell {
        println("providing $tag.${property.name} for ${if (thisRef == null) "nothing" else "an object"}")
        return Cell(tag + ":" + property.name)
    }
}

class Cell(private val label: String) {
    private var stored = 0

    operator fun getValue(thisRef: Any?, property: KProperty<*>): Int {
        println("get $label")
        return stored
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: Int) {
        println("set $label = $value")
        stored = value
    }
}

// delegates defined as extension operators
class Bare(var raw: String)

operator fun Bare.getValue(thisRef: Any?, property: KProperty<*>): String = "${property.name}=$raw"

operator fun Bare.setValue(thisRef: Any?, property: KProperty<*>, value: String) {
    raw = value.uppercase()
}

class Counter(var n: Int)

operator fun Counter.getValue(thisRef: Any?, property: KProperty<*>): Int = n++

// provideDelegate as an extension, returning a library delegate type
class Named(val prefix: String)

class Fixed(private val text: String) : ReadOnlyProperty<Any?, String> {
    override fun getValue(thisRef: Any?, property: KProperty<*>): String = text
}

operator fun Named.provideDelegate(thisRef: Any?, property: KProperty<*>): ReadOnlyProperty<Any?, String> =
    Fixed(prefix + property.name)

// open and overriding delegated properties
open class Base {
    open val title: String by lazy {
        println("base title")
        "base"
    }
    open var level: Int by Cell("base-level")

    fun describe() = "$title/$level"
}

class Derived : Base() {
    override val title: String by lazy {
        println("derived title")
        "derived"
    }
    override var level: Int by Cell("derived-level")

    fun superTitle() = super.title
}

// override a plain property with a delegated one, and the other way round
open class Plain {
    open val size: Int = 1
    open val note: String by lazy { "from lazy" }
}

class Delegating : Plain() {
    override val size: Int by lazy { 42 }
    override val note: String = "plain now"
}

interface HasName {
    val name: String
}

class Lazily : HasName {
    override val name: String by lazy { "lazy name" }
}

class Members {
    var tracked by Logged("member")
    val bare by Bare("x")
    var settable by Bare("y")
    val counter by Counter(10)
    val greeting by Named("hi-")
}

val top by Logged("top")
var topBare by Bare("z")

fun main() {
    val m = Members()
    println("created")
    m.tracked = 5
    println(m.tracked)
    println(m.bare)
    m.settable = "abc"
    println(m.settable)
    println(m.counter)
    println(m.counter)
    println(m.greeting)

    println(top)
    println(topBare)
    topBare = "q"
    println(topBare)

    var local by Logged("local")
    local = 3
    println(local)
    val localBare by Bare("l")
    println(localBare)

    val b = Base()
    println(b.describe())
    b.level = 2
    println(b.level)
    val d = Derived()
    println(d.describe())
    d.level = 7
    println(d.level)
    println(d.superTitle())
    val asBase: Base = d
    println(asBase.title)
    println(asBase.level)

    val dg = Delegating()
    println(dg.size)
    println(dg.note)
    val plain: Plain = dg
    println(plain.size)
    println(plain.note)
    println(Plain().note)

    val named: HasName = Lazily()
    println(named.name)
}
