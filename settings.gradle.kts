rootProject.name = "k2l"

pluginManagement {
    repositories {
        gradlePluginPortal()
        // The Kotlin plugin's POM imports kotlin-gradle-plugins-bom, which only Maven Central has.
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        mavenCentral()
        // Kotlin Analysis API ("-for-ide" artifacts) is only published here.
        maven("https://redirector.kotlinlang.org/maven/intellij-dependencies")
        maven("https://www.jetbrains.com/intellij-repository/releases")
    }
}

include("lua-api")
include("compiler")
include("gradle-plugin")
