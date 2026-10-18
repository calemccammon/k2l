package dev.k2l

import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.StandardWatchEventKinds.ENTRY_CREATE
import java.nio.file.StandardWatchEventKinds.ENTRY_DELETE
import java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY
import java.nio.file.StandardWatchEventKinds.OVERFLOW
import java.nio.file.WatchEvent
import java.nio.file.WatchKey
import java.util.concurrent.TimeUnit

/**
 * Runs [rebuild] once, then again whenever a Kotlin file below one of the directories [paths] returns, or one of the
 * plain files it names, changes. Changes that arrive within [debounceMillis] of each other cause one rebuild.
 * [paths] is asked again after every rebuild, so new directories (or an edited project file) are picked up.
 *
 * Tests drive it with [start] and [step]; [run] is the command-line loop.
 */
class WatchLoop(
    private val paths: () -> List<Path>,
    private val rebuild: () -> Unit,
    private val debounceMillis: Long = DEFAULT_DEBOUNCE_MILLIS,
) : AutoCloseable {
    private val service = java.nio.file.FileSystems.getDefault().newWatchService()
    private val directories = HashMap<WatchKey, Path>()
    private val registered = HashSet<Path>()
    private var files: Set<Path> = emptySet()

    /** Builds once and starts watching. */
    fun start() {
        rebuildNow()
    }

    /**
     * Waits up to [timeoutMillis] for a relevant change and rebuilds if one arrives.
     * Returns whether it rebuilt.
     */
    fun step(timeoutMillis: Long): Boolean {
        if (!awaitChange(timeoutMillis)) return false
        rebuildNow()
        return true
    }

    /** Watches until the process is interrupted. */
    fun run(): Nothing {
        start()
        while (true) step(TimeUnit.DAYS.toMillis(1))
    }

    override fun close() = service.close()

    private fun rebuildNow() {
        try {
            rebuild()
        } catch (@Suppress("TooGenericExceptionCaught") e: Exception) {
            // A crashing build must not end the watch session.
            System.err.println("k2l: build failed: $e")
        }
        register(paths())
    }

    private fun register(roots: List<Path>) {
        val absolute = roots.map { it.toAbsolutePath().normalize() }
        files = absolute.filter { !Files.isDirectory(it) }.toSet()
        absolute.forEach { root ->
            if (Files.isDirectory(root)) {
                Files.walk(root).use { tree ->
                    tree.filter { Files.isDirectory(it) }.toList()
                }.forEach(::watch)
            } else {
                root.parent?.let(::watch)
            }
        }
    }

    private fun watch(dir: Path) {
        if (!registered.add(dir)) return
        try {
            directories[dir.register(service, ENTRY_CREATE, ENTRY_MODIFY, ENTRY_DELETE)] = dir
        } catch (e: IOException) {
            registered.remove(dir)
            System.err.println("k2l: cannot watch $dir: ${e.message}")
        }
    }

    /** Blocks until a relevant event arrives (false on timeout), then waits for the burst of events to settle. */
    private fun awaitChange(timeoutMillis: Long): Boolean {
        val deadline = System.nanoTime() + TimeUnit.MILLISECONDS.toNanos(timeoutMillis)
        while (true) {
            val remaining = TimeUnit.NANOSECONDS.toMillis(deadline - System.nanoTime())
            val key = service.poll(maxOf(remaining, 0), TimeUnit.MILLISECONDS) ?: return false
            if (handle(key)) {
                settle()
                return true
            }
        }
    }

    private fun settle() {
        while (true) {
            val key = service.poll(debounceMillis, TimeUnit.MILLISECONDS) ?: return
            handle(key)
        }
    }

    /** Processes [key]'s events; true if any of them is a change that needs a rebuild. */
    private fun handle(key: WatchKey): Boolean {
        val dir = directories[key]
        val relevant = key.pollEvents().map { isRelevant(dir, it) }.any { it }
        if (!key.reset()) {
            directories.remove(key)?.let(registered::remove)
        }
        return relevant
    }

    private fun isRelevant(dir: Path?, event: WatchEvent<*>): Boolean {
        if (event.kind() == OVERFLOW) return true
        val path = dir?.resolve(event.context() as Path)?.normalize() ?: return false
        if (event.kind() == ENTRY_CREATE && Files.isDirectory(path)) {
            Files.walk(path).use { tree -> tree.filter { Files.isDirectory(it) }.toList() }.forEach(::watch)
            return true
        }
        return path in files || path.fileName.toString().endsWith(".kt") ||
            (event.kind() == ENTRY_DELETE && '.' !in path.fileName.toString())
    }

    private companion object {
        const val DEFAULT_DEBOUNCE_MILLIS = 150L
    }
}
