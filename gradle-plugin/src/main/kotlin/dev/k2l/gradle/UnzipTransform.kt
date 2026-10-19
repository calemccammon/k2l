package dev.k2l.gradle

import org.gradle.api.artifacts.transform.CacheableTransform
import org.gradle.api.artifacts.transform.InputArtifact
import org.gradle.api.artifacts.transform.TransformAction
import org.gradle.api.artifacts.transform.TransformOutputs
import org.gradle.api.artifacts.transform.TransformParameters
import org.gradle.api.file.FileSystemLocation
import org.gradle.api.provider.Provider
import org.gradle.api.tasks.PathSensitive
import org.gradle.api.tasks.PathSensitivity
import java.util.zip.ZipInputStream

/** Unpacks the published `compiler-<version>-runtime-libs.zip` into a directory of jars. */
@CacheableTransform
abstract class UnzipTransform : TransformAction<TransformParameters.None> {
    @get:InputArtifact
    @get:PathSensitive(PathSensitivity.NAME_ONLY)
    abstract val inputArtifact: Provider<FileSystemLocation>

    override fun transform(outputs: TransformOutputs) {
        val dir = outputs.dir("k2l-runtime")
        ZipInputStream(inputArtifact.get().asFile.inputStream().buffered()).use { zip ->
            generateSequence { zip.nextEntry }.filterNot { it.isDirectory }.forEach { entry ->
                // Entries are flat jar names; never let a crafted name escape the output directory.
                val target = dir.resolve(entry.name.substringAfterLast('/'))
                target.outputStream().use { zip.copyTo(it) }
            }
        }
    }
}
