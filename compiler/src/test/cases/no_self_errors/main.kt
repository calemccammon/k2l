import dev.k2l.lua.NoSelf

@NoSelf
interface Plain {
    fun run()
}

interface WithSelf {
    fun run()

    fun stop()
}

class Both : Plain, WithSelf {
    override fun run() {}

    @NoSelf
    override fun stop() {}

    @NoSelf
    override fun toString() = "both"
}

class Vec(val x: Int) {
    @NoSelf
    operator fun plus(o: Vec) = Vec(x + o.x)

    @NoSelf
    fun Int.scaled() = this * x
}

fun main() {
    Both().run()
}
