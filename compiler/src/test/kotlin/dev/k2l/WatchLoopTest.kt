package dev.k2l

import dev.k2l.frontend.SourceModule
import dev.k2l.frontend.SourceSession
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.condition.EnabledIf
import org.junit.jupiter.api.io.TempDir
import java.nio.file.Files
import java.nio.file.Path

@EnabledIf(TARGET_FREE)
class WatchLoopTest {
    @TempDir
    lateinit var dir: Path

    private val src get() = dir.resolve("src")
    private val out get() = dir.resolve("out")
    private var builds = 0
    private var loop: WatchLoop? = null

    @AfterEach
    fun close() {
        loop?.close()
    }

    private fun newLoop(): WatchLoop {
        Files.createDirectories(src)
        Files.writeString(src.resolve("main.kt"), "fun main() { println(\"one\") }\n")
        return WatchLoop(paths = { listOf(src) }, debounceMillis = 100, rebuild = ::build).also { loop = it }
    }

    private fun build() {
        builds++
        val module = SourceModule("main", listOf(src))
        SourceSession.create(listOf(module)).use { session ->
            val result = K2lCompiler().compile(session, module)
            if (!result.hasErrors) result.writeTo(out)
        }
    }

    @Test
    fun `rebuilds when a Kotlin file changes, is created or is deleted`() {
        val loop = newLoop()
        loop.start()
        assertEquals(1, builds)
        assertTrue(Files.readString(out.resolve("main.lua")).contains("\"one\""))

        Files.writeString(src.resolve("main.kt"), "fun main() { println(\"two\") }\n")
        assertTrue(loop.step(TIMEOUT))
        assertEquals(2, builds)
        assertTrue(Files.readString(out.resolve("main.lua")).contains("\"two\""))

        // A file in a directory that did not exist when the watch started.
        Files.createDirectories(src.resolve("util"))
        Files.writeString(src.resolve("util/strings.kt"), "package util\nfun shout(s: String) = s.uppercase()\n")
        while (loop.step(SHORT) && !Files.exists(out.resolve("util/strings.lua"))) continue
        assertTrue(Files.exists(out.resolve("util/strings.lua")))
        val buildsBefore = builds
        Files.writeString(src.resolve("util/strings.kt"), "package util\nfun shout(s: String) = s.uppercase() + \"!\"\n")
        assertTrue(loop.step(TIMEOUT))
        assertTrue(Files.readString(out.resolve("util/strings.lua")).contains("\"!\""))
        assertTrue(builds > buildsBefore)
    }

    @Test
    fun `a burst of writes causes one rebuild and other files are ignored`() {
        val loop = newLoop()
        loop.start()
        repeat(5) { Files.writeString(src.resolve("main.kt"), "fun main() { println(\"v$it\") }\n") }
        assertTrue(loop.step(TIMEOUT))
        assertEquals(2, builds)
        assertFalse(loop.step(SHORT), "no further change was made")

        Files.writeString(src.resolve("notes.txt"), "not Kotlin")
        assertFalse(loop.step(SHORT), "a .txt file is not a source")
        assertEquals(2, builds)
    }

    @Test
    fun `watches a project file`() {
        Files.createDirectories(src)
        Files.writeString(src.resolve("main.kt"), "fun main() {}\n")
        val project = dir.resolve("k2l.json")
        Files.writeString(project, "{}")
        val loop = WatchLoop(paths = { listOf(project, src) }, debounceMillis = 100, rebuild = ::build).also { loop = it }
        loop.start()
        Files.writeString(project, "{\"luaTarget\": \"5.3\"}")
        assertTrue(loop.step(TIMEOUT))
        assertEquals(2, builds)
    }

    private companion object {
        const val TIMEOUT = 15_000L
        const val SHORT = 1_000L
    }
}
