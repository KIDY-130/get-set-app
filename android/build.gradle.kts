// 👇 [수정] 이 부분을 파일의 '맨 위'로 올렸습니다!
plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
    id("com.android.application") version "8.7.0" apply false // (선택사항) 혹시 몰라 안드로이드 버전도 명시
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false // (선택사항) 코틀린 버전 명시
}

allprojects {
    repositories {
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