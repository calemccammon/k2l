package app.lib

import kotlin.reflect.KProperty

class Logged<T>(private var value: T) {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): T {
        println("get ${property.name}")
        return value
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, newValue: T) {
        println("set ${property.name} = $newValue")
        value = newValue
    }
}

val shared: Int by lazy {
    println("computing shared")
    99
}

var sharedLogged: String by Logged("init")
