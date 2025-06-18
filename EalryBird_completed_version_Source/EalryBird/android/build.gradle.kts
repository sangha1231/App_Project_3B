// android/build.gradle.kts

import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.*

// --- buildscript 블록: 플러그인 의존성 ---
buildscript {
    // Kotlin 버전을 extra 프로퍼티로 선언
    val kotlinVersion by extra("1.7.10")

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Kotlin Gradle 플러그인
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        // Android Gradle 플러그인
        classpath("com.android.tools.build:gradle:7.4.2")
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// --- 모든 서브프로젝트 공통 레포지토리 설정 ---
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// --- 빌드 출력 디렉토리 재배치 (선택 사항) ---
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// --- 앱 모듈 평가가 먼저 되도록 설정 ---
subprojects {
    project.evaluationDependsOn(":app")
}

// --- clean 태스크 재정의 ---
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
