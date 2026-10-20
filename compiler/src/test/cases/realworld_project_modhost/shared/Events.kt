package mods.shared

// State shared by the mods; the Lua driver calls into it too (`Events:fire("x")`, an object, so with `:`).

object Events {
    private val listeners = linkedMapOf<String, MutableList<(String) -> Unit>>()
    val fired = mutableListOf<String>()

    fun on(name: String, listener: (String) -> Unit) {
        listeners.getOrPut(name) { mutableListOf() } += listener
    }

    fun fire(name: String, detail: String = "-"): Int {
        fired += name
        val ls = listeners[name].orEmpty()
        ls.forEach { it(detail) }
        return ls.size
    }
}

class Version(val major: Int, val minor: Int) : Comparable<Version> {
    override fun compareTo(other: Version) = compareValuesBy(this, other, { it.major }, { it.minor })

    override fun toString() = "$major.$minor"

    companion object {
        fun parse(s: String): Version {
            val (a, b) = s.split('.').map { it.toInt() }
            return Version(a, b)
        }
    }
}
