import org.gradle.process.ExecOperations
import javax.inject.Inject
import java.io.ByteArrayOutputStream

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

    testImplementation(platform(libs.junit.bom))
    testImplementation(libs.junit.jupiter)
    testRuntimeOnly(libs.junit.launcher)
}

application {
    mainClass.set("dev.k2l.MainKt")
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

    @TaskAction
    fun run() {
        val stdlib = compilerClasspath.files.first { it.name.matches(Regex("kotlin-stdlib-[0-9.]+\\.jar")) }
        val cases = casesDir.get().asFile.listFiles().orEmpty().filter { File(it, "main.kt").isFile && !File(it, "errors.txt").isFile }.sortedBy { it.name }
        val mismatched = mutableListOf<String>()
        for (case in cases) {
            val classes = workDir.get().dir(case.name).asFile.apply { deleteRecursively(); mkdirs() }
            exec.javaexec {
                classpath = compilerClasspath
                mainClass.set("org.jetbrains.kotlin.cli.jvm.K2JVMCompiler")
                args("-no-stdlib", "-no-reflect", "-nowarn", "-classpath", stdlib.path, "-d", classes.path, File(case, "main.kt").path)
            }
            val stdout = ByteArrayOutputStream()
            exec.javaexec {
                classpath(classes, stdlib)
                mainClass.set("MainKt")
                standardOutput = stdout
            }
            val actual = stdout.toString(Charsets.UTF_8)
            val expected = File(case, "stdout.txt")
            if (update.get()) expected.writeText(actual)
            else if (!expected.isFile || expected.readText() != actual) mismatched += case.name
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
}

tasks.register("printClasspath") {
    val cp = configurations.runtimeClasspath
    doLast { cp.get().files.forEach { println(it) } }
}
