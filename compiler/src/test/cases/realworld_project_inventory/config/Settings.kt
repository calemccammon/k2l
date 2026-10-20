package shop.config

import shop.log.log

const val APP_NAME = "inventory"
const val TAX_PERCENT = 8

var verbosity = 1

var currency = "EUR"

lateinit var profile: String

val startupToken: Int by lazy { log("computing startupToken") * 100 }

fun describeSettings(): String {
    val p = if (::profile.isInitialized) profile else "<unset>"
    return "$APP_NAME v=$verbosity cur=$currency profile=$p"
}

fun bumpVerbosity(by: Int = 1): Int {
    verbosity += by
    return verbosity
}

object Settings {
    private val values = linkedMapOf<String, String>()

    init {
        log("Settings object init")
        values["region"] = "north"
    }

    operator fun get(key: String): String? = values[key]

    operator fun set(key: String, value: String) {
        log("Settings[$key] = $value")
        values[key] = value
    }

    val keys: List<String> get() = values.keys.toList()
}
