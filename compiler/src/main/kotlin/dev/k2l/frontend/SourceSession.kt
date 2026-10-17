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

/** A Kotlin source module to transpile: its files live under [roots]. */
data class SourceModule(val name: String, val roots: List<Path>)

/** Parsed, analyzable source modules. Close it to release the IntelliJ core environment. */
class SourceSession private constructor(
    private val disposable: Disposable,
    val modules: List<SourceModule>,
    private val filesByModule: Map<String, List<KtFile>>,
) : AutoCloseable {
    fun files(module: String): List<KtFile> = filesByModule[module].orEmpty().sortedBy { it.virtualFile.path }

    override fun close() = Disposer.dispose(disposable)

    companion object {
        fun create(modules: List<SourceModule>, classpath: List<Path> = emptyList()): SourceSession {
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
                        addBinaryRoots(listOf(kotlinStdlibJar(), luaApiJar()) + classpath)
                        this.platform = platform
                        libraryName = "classpath"
                    })
                    for (module in modules) {
                        addModule(buildKtSourceModule {
                            addSourceRoots(module.roots)
                            addRegularDependency(jdk)
                            addRegularDependency(libs)
                            this.platform = platform
                            moduleName = module.name
                        })
                    }
                }
            }
            val files = session.modulesWithFiles.entries.associate { (module, files) ->
                module.name to files.filterIsInstance<KtFile>()
            }
            return SourceSession(disposable, modules, files)
        }

        private fun kotlinStdlibJar(): Path =
            Paths.get(KotlinVersion::class.java.protectionDomain.codeSource.location.toURI())

        /** dev.k2l.lua: @LuaExternal, LuaTable and the Lua standard library bindings. */
        private fun luaApiJar(): Path =
            Paths.get(dev.k2l.lua.LuaExternal::class.java.protectionDomain.codeSource.location.toURI())
    }
}
