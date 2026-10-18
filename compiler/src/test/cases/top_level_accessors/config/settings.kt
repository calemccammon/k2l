package app.config

val history = mutableListOf<String>()

var name: String = "default"
    set(value) {
        history.add("name: $field -> $value")
        field = value
    }

var volume: Int = 10
    get() = field
    set(v) {
        field = if (v > 100) 100 else v
        history.add("volume=$field")
    }

private var calls = 0

val hits: Int get() = calls

var level = 1
    private set(v) {
        field = v
    }

fun describe(): String = "$name/$volume/$hits"

object Settings {
    fun touch() {
        calls++
        level++
    }
}
