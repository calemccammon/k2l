package ui

interface Ticker {
    fun start()

    fun running(): Boolean

    fun status() = if (running()) "running" else "stopped"
}

fun ticker(step: () -> Boolean): Ticker {
    var on = false
    return object : Ticker {
        override fun start() {
            on = step()
        }

        override fun running() = on
    }
}

open class Clock(private val name: String) : Ticker {
    private var ticks = 0

    override fun start() {
        ticks++
    }

    override fun running() = ticks > 0

    open fun label() = "$name:$ticks"
}

class Alarm(name: String) : Clock(name) {
    override fun label() = "alarm " + super.label()
}

// Inherits status() from the interface.
object Heart : Ticker {
    var beats = 0

    override fun start() {
        beats++
    }

    override fun running() = beats > 0
}
