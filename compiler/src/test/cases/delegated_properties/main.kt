package app

import app.lib.shared
import app.lib.sharedLogged
import kotlin.properties.Delegates
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

// A user delegate that reports what it is asked
class Tracking(private var value: Int) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): Int {
        println("read ${property.name} (${if (thisRef == null) "no owner" else "owned"})")
        return value
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, newValue: Int) {
        println("write ${property.name}: $value -> $newValue")
        value = newValue
    }
}

class Uppercase {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): String = property.name.uppercase()
}

// A delegate implementing the library interface
class Clamped(private val max: Int) : ReadWriteProperty<Any?, Int> {
    private var value = 0

    override fun getValue(thisRef: Any?, property: KProperty<*>): Int = value

    override fun setValue(thisRef: Any?, property: KProperty<*>, value: Int) {
        this.value = if (value > max) max else value
    }
}

val topLazy: String by lazy {
    println("computing topLazy")
    "top"
}

var topObservable: Int by Delegates.observable(0) { prop, old, new ->
    println("${prop.name}: $old -> $new")
}

class Settings(val source: String) {
    val greeting: String by lazy {
        println("building greeting for $source")
        "hello $source"
    }
    var volume: Int by Delegates.observable(5) { property, oldValue, newValue ->
        println("${property.name} changed from $oldValue to $newValue")
    }
    var positive: Int by Delegates.vetoable(1) { _, old, new ->
        println("veto? $old -> $new")
        new > 0
    }
    var name: String by Delegates.notNull()
    var tracked: Int by Tracking(10)
    var clamped: Int by Clamped(100)
    val upper by Uppercase()

    fun bump() {
        volume += 1
        tracked = tracked + 1
    }
}

class Config(map: MutableMap<String, Any?>) {
    var host: String by map
    var port: Int by map
}

class User(val map: Map<String, Any?>) {
    val name: String by map
    val age: Int by map
}

object Registry {
    val items: List<String> by lazy {
        println("loading registry")
        listOf("a", "b")
    }
    var hits: Int by Delegates.observable(0) { _, _, new -> println("hits=$new") }
}

class WithCompanion {
    companion object {
        val instance: String by lazy {
            println("creating instance")
            "singleton"
        }
    }
}

fun main() {
    // lazy: evaluated once, and only on first access
    val lazyLocal by lazy {
        println("computing lazyLocal")
        42
    }
    println("before lazyLocal")
    println(lazyLocal)
    println(lazyLocal)

    val explicit: Lazy<Int> = lazy { 7 }
    println(explicit.isInitialized())
    println(explicit.value)
    println(explicit.isInitialized())
    println(explicit.value + 1)

    val modeLazy by lazy(LazyThreadSafetyMode.NONE) { "no sync" }
    println(modeLazy)

    println("before topLazy")
    println(topLazy)
    println(topLazy)

    // top-level observable
    topObservable = 3
    topObservable += 2
    println(topObservable)

    // local observable and vetoable
    var counter by Delegates.observable(10) { p, o, n -> println("local ${p.name} $o -> $n") }
    counter++
    counter = counter * 2
    println(counter)
    var limited by Delegates.vetoable(0) { _, _, new -> new < 100 }
    limited = 50
    limited = 500
    println(limited)

    // members
    val s = Settings("test")
    println("settings created")
    println(s.greeting)
    println(s.greeting)
    println(s.volume)
    s.volume = 8
    s.bump()
    println(s.volume)
    s.positive = 5
    s.positive = -3
    println(s.positive)
    s.positive += 10
    println(s.positive)

    try {
        println(s.name)
    } catch (e: IllegalStateException) {
        println("caught: ${e.message}")
    }
    s.name = "Ada"
    println(s.name)

    println(s.tracked)
    s.tracked = 20
    s.tracked += 5
    println(s.tracked)
    s.clamped = 500
    println(s.clamped)
    s.clamped = 7
    println(s.clamped)
    println(s.upper)

    val other = Settings("other")
    println(other.greeting)
    println(s.greeting)

    // user delegates for locals
    var local by Tracking(1)
    println(local)
    local = 2
    println(local)
    val tag by Uppercase()
    println(tag)

    // maps
    val config = Config(mutableMapOf("host" to "localhost", "port" to 8080))
    println("${config.host}:${config.port}")
    config.port = 9090
    config.host = "example.org"
    println("${config.host}:${config.port}")
    val user = User(mapOf("name" to "Grace", "age" to 36))
    println("${user.name} is ${user.age}")
    val backing = mutableMapOf<String, Any?>("title" to "Dr")
    var title: String by backing
    println(title)
    title = "Prof"
    println(backing["title"])

    // objects and companions
    println("before registry")
    println(Registry.items.size)
    println(Registry.items)
    Registry.hits = 2
    println(WithCompanion.instance)
    println(WithCompanion.instance)

    // from another file
    println("before shared")
    println(shared)
    println(shared)
    println(sharedLogged)
    sharedLogged = "changed"
    println(sharedLogged)

    // a lazy whose initializer throws is retried
    var attempts = 0
    val flaky by lazy {
        attempts++
        if (attempts < 2) throw IllegalStateException("not yet")
        "ok after $attempts"
    }
    try {
        println(flaky)
    } catch (e: IllegalStateException) {
        println("first: ${e.message}")
    }
    println(flaky)
    println(flaky)
}
