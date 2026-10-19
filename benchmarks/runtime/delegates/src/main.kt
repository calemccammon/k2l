import kotlin.properties.Delegates
import kotlin.reflect.KProperty

class Boxed(var v: Int) {
    operator fun getValue(thisRef: Any?, p: KProperty<*>): Int = v
    operator fun setValue(thisRef: Any?, p: KProperty<*>, value: Int) { v = value }
}

class Holder {
    var a: Int by Boxed(0)
    val lz: Int by lazy { 42 }
    var obs: Int by Delegates.observable(0) { _, _, _ -> }
}

fun main() {
    val h = Holder()
    var s = 0L
    for (i in 0 until 1000000) {
        h.a = i
        s += h.a
        s += h.lz
        h.obs = i
        s += h.obs
    }
    println(s)
}
