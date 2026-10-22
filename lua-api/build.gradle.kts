plugins {
    alias(libs.plugins.kotlin.jvm)
}

kotlin {
    jvmToolchain(21)
}

publishing {
    publications.create<MavenPublication>("maven") { from(components["java"]) }
}
