import kotlin.properties.Delegates
import kotlin.properties.PropertyDelegateProvider
import kotlin.properties.ReadOnlyProperty
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

// Delegating to another property (`by ::other`, `by obj::other`, `by Owner::other`), and calling the getValue/setValue
// of library delegates and provideDelegate explicitly
var topLevel = 1
var alias by ::topLevel

class Settings {
    var width = 10
    var size by this::width
    val doubled: Int by lazy { width * 2 }
}

class Wrapper(val settings: Settings) {
    var width by settings::width
}

class Point(var x: Int)

class Moved(val point: Point) {
    var left by point::x
}

class Upper : ReadOnlyProperty<Any?, String> {
    override fun getValue(thisRef: Any?, property: KProperty<*>): String = property.name.uppercase()
}

val upper = Upper()
val NAME by upper
val providedName by PropertyDelegateProvider<Any?, ReadOnlyProperty<Any?, String>> { _, p -> ReadOnlyProperty { _, _ -> "provided ${p.name}" } }

fun main() {
    println("alias $alias")
    alias = 5
    println("topLevel $topLevel alias $alias")
    topLevel = 7
    println("alias $alias")

    val s = Settings()
    s.size = 30
    println("width ${s.width} size ${s.size} doubled ${s.doubled}")
    val w = Wrapper(s)
    w.width = 42
    println("settings ${s.width} wrapper ${w.width}")
    val m = Moved(Point(3))
    m.left += 4
    println("point ${m.point.x} left ${m.left}")

    // getValue/setValue of library delegates, called directly
    val observed = mutableListOf<String>()
    val observable: ReadWriteProperty<Any?, Int> = Delegates.observable(0) { p, old, new -> observed += "${p.name}: $old -> $new" }
    observable.setValue(null, ::topLevel, 9)
    println("observable ${observable.getValue(null, ::topLevel)} $observed")
    val provider = PropertyDelegateProvider<Any?, ReadOnlyProperty<Any?, String>> { _, property -> ReadOnlyProperty { _, _ -> "provided for ${property.name}" } }
    println(provider.provideDelegate(null, ::topLevel).getValue(null, ::topLevel))
    println(NAME)
    // a property reference's operators called directly
    ::topLevel.setValue(null, ::topLevel, 11)
    println(::topLevel.getValue(null, ::topLevel))
    val p = Point(1)
    Point::x.setValue(p, Point::x, 8)
    println("${p.x} ${Point::x.getValue(p, Point::x)}")
    println(providedName)
}
