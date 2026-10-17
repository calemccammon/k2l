rootProject.name = "k2l"

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
