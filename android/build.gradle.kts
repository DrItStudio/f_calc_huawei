allprojects {
    repositories {
    // Huawei репозитории приоритетнее, чтобы гарантировать резолв AppUpdate/UpdateSDK
    maven { url = uri("https://developer.huawei.com/repo/") }
    maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
    maven { url = uri("https://developer.hihonor.com/repo/") }
    google()
    mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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