package dev.k2l

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.io.TempDir
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.nio.file.Files
import java.nio.file.Path

class CliTest {
    @TempDir
    lateinit var dir: Path

    private class Run(val status: Int, val out: String, val err: String)

    private fun k2l(vararg args: String): Run {
        val out = ByteArrayOutputStream()
        val err = ByteArrayOutputStream()
        val status = runCli(arrayOf(*args), PrintStream(out, true, Charsets.UTF_8), PrintStream(err, true, Charsets.UTF_8))
        return Run(status, out.toString(Charsets.UTF_8), err.toString(Charsets.UTF_8))
    }

    private fun write(path: String, text: String): Path = dir.resolve(path).also {
        Files.createDirectories(it.parent)
        Files.writeString(it, text)
    }

    private val src get() = dir.resolve("src").toString()
    private val out get() = dir.resolve("out")

    @Test
    fun checkReportsUnsupportedConstructsWithoutWritingFiles() {
        write("src/main.kt", "import java.util.Vector\n\nclass Numbers : Vector<Int>()\n\nfun main() {\n    println(Numbers().size)\n}\n")
        write("src/other.kt", "fun twice(x: Int) = x * 2\n")
        val run = k2l("--check", "-o", out.toString(), src)
        assertEquals(1, run.status, run.err)
        assertTrue(run.err.contains("main.kt:3:17: error: Extending 'Vector<Int>()' is not supported yet\n"), run.err)
        // The source line, the span underlined, then the workaround.
        assertTrue(
            run.err.contains("class Numbers : Vector<Int>()\n                ^^^^^^^^^^^^^\n  hint: extend java.util.ArrayList"),
            run.err,
        )
        assertTrue(run.err.contains("k2l: checked 2 file(s): 1 error, 0 warnings"), run.err)
        assertFalse(Files.exists(out), "--check must not write anything")
    }

    @Test
    fun checkOfACleanProgramSucceeds() {
        write("src/main.kt", "fun main() {\n    println(\"hi\")\n}\n")
        val run = k2l("--check", "-o", out.toString(), src)
        assertEquals(0, run.status, run.err)
        assertTrue(run.err.contains("k2l: checked 1 file(s): 0 errors, 0 warnings"), run.err)
        assertFalse(Files.exists(out))
    }

    @Test
    fun failedBuildSummarizesAndWritesNothing() {
        write("src/main.kt", "fun main() {\n    val x: Int = \"text\"\n}\n")
        val run = k2l("-o", out.toString(), src)
        assertEquals(1, run.status, run.err)
        assertTrue(run.err.contains("main.kt:2:"), run.err)
        assertTrue(run.err.contains("    val x: Int = \"text\"\n"), run.err)
        assertTrue(run.err.contains("k2l: 1 error, 0 warnings; no files written"), run.err)
        assertFalse(Files.exists(out))
    }

    @Test
    fun aConstructReachedTwiceIsReportedOnce() {
        // `x[1] += 2` is transformed as a read and as a write, each of which used to report the same error.
        val source = """
            |class Box {
            |    operator fun Int.get(i: Int) = this + i
            |    operator fun Int.set(i: Int, v: Int) {}
            |    fun go(x: Int) {
            |        x[1] += 2
            |    }
            |}
            |
            |fun main() {
            |    Box().go(1)
            |}
            |
        """.trimMargin()
        write("src/main.kt", source)
        val run = k2l("--check", src)
        assertEquals(1, run.status, run.err)
        assertEquals(1, Regex("error: An index operator declared as a member extension").findAll(run.err).count(), run.err)
    }

    @Test
    fun aSharedHintIsPrintedOnce() {
        write(
            "src/main.kt",
            "fun main() {\n    val a = StringBuilder().appendCodePoint(65)\n    val b = StringBuilder().appendCodePoint(66)\n}\n",
        )
        val run = k2l("--check", src)
        assertEquals(
            2,
            Regex("without --strings utf16").findAll(
                run.err.lines().filter {
                    "error:" in it
                }.joinToString("\n"),
            ).count(),
            run.err,
        )
        assertEquals(1, Regex("hint: compile with --strings utf16").findAll(run.err).count(), run.err)
    }

    @Test
    fun buildWritesLua() {
        write("src/main.kt", "fun main() {\n    println(\"hi\")\n}\n")
        val run = k2l("-o", out.toString(), src)
        assertEquals(0, run.status, run.err)
        assertTrue(Files.isRegularFile(out.resolve("main.lua")))
        assertFalse(Files.exists(out.resolve("main.lua.map")), "no source maps unless asked for")
    }

    @Test
    fun mistypedProjectKeyGetsASuggestion() {
        val project = write("k2l.json", "{\n  // comments and trailing commas are fine\n  \"srcDir\": [\"src\"],\n}\n")
        val run = k2l("-p", project.toString())
        assertEquals(USAGE_ERROR, run.status)
        assertTrue(run.err.contains("'srcDir' (did you mean 'srcDirs'?)"), run.err)
    }

    @Test
    fun projectValueOfTheWrongTypeIsAnError() {
        val project = write("k2l.json", "{\"srcDirs\": [\"src\"], \"sourceMap\": \"yes\"}")
        val run = k2l("-p", project.toString())
        assertEquals(USAGE_ERROR, run.status)
        assertTrue(run.err.contains("'sourceMap' in $project must be true or false, not \"yes\""), run.err)
    }

    @Test
    fun invalidJsonIsReportedBriefly() {
        val project = write("k2l.json", "{\"srcDirs\": [\"src\"] \"outDir\": \"x\"}")
        val run = k2l("-p", project.toString())
        assertEquals(USAGE_ERROR, run.status)
        assertTrue(run.err.startsWith("k2l: $project is not valid JSON: "), run.err)
        assertEquals(2, run.err.lines().count { it.isNotEmpty() }, run.err)
    }

    @Test
    fun badCommandLines() {
        assertTrue(k2l("--sourcemap", src).err.contains("unknown option --sourcemap (did you mean --source-map?)"))
        assertTrue(k2l("--out=x", src).err.contains("write the value after a space: --out x"))
        val missing = k2l(dir.resolve("nowhere").toString())
        assertEquals(USAGE_ERROR, missing.status)
        assertTrue(missing.err.contains("source directory ${dir.resolve("nowhere")} not found"), missing.err)
        val help = k2l("--help")
        assertEquals(0, help.status)
        assertTrue(help.out.contains("--check"), help.out)
    }

    @Test
    fun watchModeDefaultsToSourceMapsUnlessSetExplicitly() {
        assertFalse(parseArgs(arrayOf(src)).sourceMapEnabled)
        assertTrue(parseArgs(arrayOf("--watch", src)).sourceMapEnabled)
        assertFalse(parseArgs(arrayOf("--watch", "--no-source-map", src)).sourceMapEnabled)
        assertTrue(parseArgs(arrayOf("--source-map", src)).sourceMapEnabled)
        val off = write("k2l.json", "{\"srcDirs\": [\"src\"], \"sourceMap\": false}")
        assertFalse(parseArgs(arrayOf("-p", off.toString(), "--watch")).sourceMapEnabled)
        assertTrue(parseArgs(arrayOf("-p", off.toString(), "--source-map")).sourceMapEnabled)
    }
}
