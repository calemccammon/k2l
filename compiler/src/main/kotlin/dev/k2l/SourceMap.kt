package dev.k2l

import java.nio.file.Path

/** A position in a Kotlin source file, 1-based. */
data class Origin(val line: Int, val column: Int)

/** One generated Lua line (1-based) starting at [luaColumn] (0-based) that came from [origin]. */
data class LineMapping(val luaLine: Int, val luaColumn: Int, val origin: Origin)

/**
 * Maps the lines of one generated Lua file ([luaFile], relative to the output directory) to positions in
 * the Kotlin file at [sourcePath]. [lines] are sorted by Lua line, one entry per statement line.
 */
class SourceMap(val luaFile: String, val sourcePath: Path, val lines: List<LineMapping>) {
    /** Source Map v3 JSON, with `sources` relative to [mapDir], the directory the `.map` file is written to. */
    fun toJson(mapDir: Path): String {
        val source = runCatching {
            mapDir.toAbsolutePath().normalize().relativize(sourcePath).toString()
        }.getOrDefault(sourcePath.toString())
        val file = luaFile.substringAfterLast('/')
        return buildString {
            append("{\"version\":3,\"file\":").append(jsonString(file))
            append(",\"sources\":[").append(jsonString(source.replace('\\', '/'))).append("],\"names\":[],\"mappings\":")
            append(jsonString(mappings())).append("}\n")
        }
    }

    /** The VLQ `mappings` field: `;` separates generated lines, each segment is `[column, source, line, column]` deltas. */
    fun mappings(): String {
        val sb = StringBuilder()
        var line = 1
        var srcLine = 0
        var srcColumn = 0
        for (m in lines) {
            while (line < m.luaLine) {
                sb.append(';')
                line++
            }
            // Each Lua line has one segment, at the start of its statement.
            Vlq.encode(sb, m.luaColumn)
            Vlq.encode(sb, 0)
            Vlq.encode(sb, m.origin.line - 1 - srcLine)
            Vlq.encode(sb, m.origin.column - 1 - srcColumn)
            srcLine = m.origin.line - 1
            srcColumn = m.origin.column - 1
        }
        return sb.toString()
    }

    /** Flat `"dLua dKotlin ..."` deltas of (Lua line, Kotlin line) pairs: the compact table the Lua runtime embeds. */
    fun runtimeTable(): String {
        var luaLine = 0
        var ktLine = 0
        return lines.joinToString(" ") { m ->
            val entry = "${m.luaLine - luaLine} ${m.origin.line - ktLine}"
            luaLine = m.luaLine
            ktLine = m.origin.line
            entry
        }
    }

    private fun jsonString(s: String) = buildString {
        append('"')
        for (c in s) {
            when {
                c == '"' -> append("\\\"")
                c == '\\' -> append("\\\\")
                c < ' ' -> append("\\u%04x".format(c.code))
                else -> append(c)
            }
        }
        append('"')
    }

    companion object {
        /** Decodes a `mappings` string into generated line, generated column and source position (lines and columns 1-based). */
        fun decode(mappings: String): List<LineMapping> {
            val result = mutableListOf<LineMapping>()
            var srcLine = 0
            var srcColumn = 0
            mappings.split(';').forEachIndexed { index, lineText ->
                var genColumn = 0
                for (segment in lineText.split(',').filter { it.isNotEmpty() }) {
                    val fields = Vlq.decode(segment)
                    genColumn += fields[0]
                    if (fields.size >= FULL_SEGMENT) {
                        val lineDelta = fields[2]
                        val columnDelta = fields[3]
                        srcLine += lineDelta
                        srcColumn += columnDelta
                        result += LineMapping(index + 1, genColumn, Origin(srcLine + 1, srcColumn + 1))
                    }
                }
            }
            return result
        }
    }
}

private const val FULL_SEGMENT = 4

/** Base64 variable-length quantities as used by Source Map v3. */
internal object Vlq {
    private const val ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    private const val CONTINUATION = 32
    private const val PAYLOAD_BITS = 5
    private const val PAYLOAD_MASK = 31

    fun encode(sb: StringBuilder, value: Int) {
        var rest = if (value < 0) (-value shl 1) or 1 else value shl 1
        do {
            var digit = rest and PAYLOAD_MASK
            rest = rest ushr PAYLOAD_BITS
            if (rest > 0) digit = digit or CONTINUATION
            sb.append(ALPHABET[digit])
        } while (rest > 0)
    }

    fun decode(segment: String): List<Int> {
        val values = mutableListOf<Int>()
        var shift = 0
        var acc = 0
        for (c in segment) {
            val digit = ALPHABET.indexOf(c)
            require(digit >= 0) { "invalid base64 VLQ character '$c'" }
            acc += (digit and PAYLOAD_MASK) shl shift
            if (digit and CONTINUATION != 0) {
                shift += PAYLOAD_BITS
            } else {
                values += if (acc and 1 == 1) -(acc ushr 1) else acc ushr 1
                shift = 0
                acc = 0
            }
        }
        return values
    }
}
