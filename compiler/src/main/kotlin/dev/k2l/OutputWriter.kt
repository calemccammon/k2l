package dev.k2l

import java.nio.file.Files
import java.nio.file.Path

/** Writes every generated file below [out], plus a `<file>.lua.map` next to each file that has a source map. */
fun CompileResult.writeTo(out: Path) {
    for (output in outputs) {
        val path = out.resolve(output.path)
        Files.createDirectories(path.parent)
        Files.writeString(path, output.code)
        output.sourceMap?.let { map ->
            Files.writeString(path.resolveSibling(path.fileName.toString() + ".map"), map.toJson(path.parent))
        }
    }
}
