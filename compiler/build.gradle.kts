import org.gradle.process.ExecOperations
import java.io.ByteArrayOutputStream
import javax.inject.Inject

plugins {
    alias(libs.plugins.kotlin.jvm)
    application
}

kotlin {
    jvmToolchain(21)
}

dependencies {
    // kotlin-compiler bundles a shrunk IntelliJ core; the unshrunk API must come first on the classpath.
    implementation(libs.intellij.core) { isTransitive = false }
    // The Analysis API "-for-ide" jars have POMs pointing at unpublished modules, so add them
    // non-transitively next to the compiler (same approach as Dokka).
    implementation(libs.kotlin.compiler) { isTransitive = false }
    libs.bundles.analysis.api.get().forEach {
        implementation("${it.module}:${it.version}") { isTransitive = false }
    }
    implementation(libs.caffeine)
    implementation(libs.coroutines.core) { isTransitive = false }
    implementation(libs.serialization.json)
    // The interop annotations; also put on the classpath of every transpiled program.
    implementation(project(":lua-api"))

    testImplementation(platform(libs.junit.bom))
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly(libs.junit.launcher)
}

application {
    applicationName = "k2l"
    mainClass.set("dev.k2l.MainKt")
    // The Analysis API indexes the whole classpath at startup.
    applicationDefaultJvmArgs = listOf("-Xss8m", "-XX:+UseParallelGC")
}

tasks.named<JavaExec>("run") {
    workingDir = rootDir
}

val testCases = layout.projectDirectory.dir("src/test/cases")

tasks.test {
    useJUnitPlatform()
    maxHeapSize = "2g"
    inputs.dir(testCases)
    systemProperty("k2l.casesDir", testCases.asFile.absolutePath)
    systemProperty("k2l.updateGolden", providers.gradleProperty("updateGolden").isPresent)
    providers.gradleProperty("lua").orNull?.let { systemProperty("k2l.lua", it) }
    providers.gradleProperty("only").orNull?.let { systemProperty("k2l.only", it) } // -Ponly=casts,objects_enums
}

// ---- Kotlin/JVM oracle: the expected stdout of every test case comes from running it on the JVM ----

val oracleCompiler = configurations.create("oracleCompiler")

dependencies {
    oracleCompiler("org.jetbrains.kotlin:kotlin-compiler-embeddable:${libs.versions.kotlin.get()}")
}

abstract class KotlinOracle @Inject constructor(private val exec: ExecOperations) : DefaultTask() {
    @get:Classpath abstract val compilerClasspath: ConfigurableFileCollection

    @get:Internal abstract val casesDir: DirectoryProperty

    @get:Internal abstract val workDir: DirectoryProperty

    @get:Input abstract val update: Property<Boolean>

    /** Comma-separated case names to run (`-Ponly=floats,unsigned`, or `-PoracleCases=...`); all cases when empty. */
    @get:Input abstract val only: Property<String>

    @TaskAction
    fun run() {
        val stdlib = compilerClasspath.files.first { it.name.matches(Regex("kotlin-stdlib-[0-9.]+\\.jar")) }
        val cases = casesDir.get().asFile.listFiles().orEmpty().filter {
            File(it, "main.kt").isFile && !File(it, "errors.txt").isFile &&
                (only.get().isEmpty() || it.name in only.get().split(','))
        }.sortedBy { it.name }
        val mismatched = mutableListOf<String>()
        for (case in cases) {
            if (File(case, "jvm-skip").isFile) continue // calls into hand-written Lua, so it can't run on the JVM
            val classes = workDir.get().dir(case.name).asFile.apply {
                deleteRecursively()
                mkdirs()
            }
            val sources = case.walkTopDown().filter { it.extension == "kt" }.map { it.path }.toList()
            val pkg = Regex("""^package\s+([\w.]+)""", RegexOption.MULTILINE).find(File(case, "main.kt").readText())?.groupValues?.get(1)
            exec.javaexec {
                classpath = compilerClasspath
                mainClass.set("org.jetbrains.kotlin.cli.jvm.K2JVMCompiler")
                args(listOf("-no-stdlib", "-no-reflect", "-nowarn", "-classpath", stdlib.path, "-d", classes.path) + sources)
            }
            val stdout = ByteArrayOutputStream()
            exec.javaexec {
                classpath(classes, stdlib)
                mainClass.set(if (pkg != null) "$pkg.MainKt" else "MainKt")
                // Cases print non-ASCII text: do not depend on the locale of the machine
                jvmArgs("-Dfile.encoding=UTF-8", "-Dstdout.encoding=UTF-8")
                standardOutput = stdout
            }
            val actual = stdout.toString(Charsets.UTF_8)
            val expected = File(case, "stdout.txt")
            if (update.get()) {
                expected.writeText(actual)
            } else if (!expected.isFile || expected.readText() != actual) {
                mismatched += case.name
            }
        }
        if (mismatched.isNotEmpty()) {
            throw GradleException("Kotlin/JVM output differs from stdout.txt for $mismatched (rerun with -PupdateOracle)")
        }
        logger.lifecycle("Kotlin/JVM oracle matched stdout.txt for ${cases.size} cases")
    }
}

tasks.register<KotlinOracle>("kotlinOracle") {
    description = "Runs every test case on Kotlin/JVM and checks (or with -PupdateOracle, writes) its stdout.txt."
    group = "verification"
    compilerClasspath.from(oracleCompiler)
    casesDir.set(testCases)
    workDir.set(layout.buildDirectory.dir("oracle"))
    update.set(providers.gradleProperty("updateOracle").isPresent)
    only.set(providers.gradleProperty("only").orElse(providers.gradleProperty("oracleCases")).orElse(""))
}

// ---- The compiler's runtime classpath as one consumable directory, for the Gradle plugin (`dev.k2l`) ----

// The Analysis API jars are published without usable POMs, so a consumer can't resolve them transitively.
// This variant is the exact set of jars (the compiler's own jar included) that `k2l` runs with.
val k2lRuntimeLibs = tasks.register<Sync>("k2lRuntimeLibs") {
    from(tasks.jar)
    from(configurations.runtimeClasspath)
    into(layout.buildDirectory.dir("k2l-runtime"))
}

configurations.consumable("k2lCompilerRuntime") {
    attributes.attribute(Usage.USAGE_ATTRIBUTE, objects.named("k2l-compiler-runtime"))
    outgoing.artifact(layout.buildDirectory.dir("k2l-runtime")) { builtBy(k2lRuntimeLibs) }
}
