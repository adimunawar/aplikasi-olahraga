allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Restore the workaround used by the last successful staging release.
    // Android Lint crashes while analyzing Flutter Firebase plugin sources
    // during release builds in the current Android toolchain.
    tasks.matching { it.name.startsWith("lintVital") }.configureEach {
        enabled = false
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
