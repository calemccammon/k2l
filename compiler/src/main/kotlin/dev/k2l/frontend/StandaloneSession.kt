package dev.k2l.frontend

import com.intellij.openapi.Disposable
import com.intellij.openapi.util.Disposer
import org.jetbrains.kotlin.analysis.api.standalone.buildStandaloneAnalysisAPISession
import org.jetbrains.kotlin.analysis.project.structure.builder.buildKtLibraryModule
import org.jetbrains.kotlin.analysis.project.structure.builder.buildKtSdkModule
import org.jetbrains.kotlin.analysis.project.structure.builder.buildKtSourceModule
import org.jetbrains.kotlin.platform.jvm.JvmPlatforms
import org.jetbrains.kotlin.psi.KtFile
import java.nio.file.Path
import java.nio.file.Paths

/** A parsed and analyzable set of Kotlin sources. Close it to release the IntelliJ core environment. */
class SourceSession private constructor(
    private val disposable: Disposable,
    val files: List<KtFile>,
) : AutoCloseable {
    override fun close() = Disposer.dispose(disposable)

    companion object {
        fun create(sourceRoots: List<Path>, classpath: List<Path> = emptyList()): SourceSession {
            val disposable = Disposer.newDisposable("k2l")
            val platform = JvmPlatforms.defaultJvmPlatform
            val session = buildStandaloneAnalysisAPISession(disposable) {
                buildKtModuleProvider {
                    this.platform = platform
                    val jdk = addModule(buildKtSdkModule {
                        addBinaryRootsFromJdkHome(Paths.get(System.getProperty("java.home")), isJre = true)
                        this.platform = platform
                        libraryName = "jdk"
                    })
                    val libs = addModule(buildKtLibraryModule {
                        addBinaryRoots(listOf(kotlinStdlibJar()) + classpath)
                        this.platform = platform
                        libraryName = "classpath"
                    })
                    addModule(buildKtSourceModule {
                        addSourceRoots(sourceRoots)
                        addRegularDependency(jdk)
                        addRegularDependency(libs)
                        this.platform = platform
                        moduleName = "main"
                    })
                }
            }
            val files = session.modulesWithFiles.values.flatten().filterIsInstance<KtFile>()
            return SourceSession(disposable, files)
        }

        private fun kotlinStdlibJar(): Path =
            Paths.get(KotlinVersion::class.java.protectionDomain.codeSource.location.toURI())
    }
}
