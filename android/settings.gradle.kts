pluginManagement {
    val flutterSdkPath = settings.extraProperties.get("flutter.sdk")
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // ❌ id("dev.flutter.flutter-plugin-loader") version "1.0.0"  <-- 이 줄이 문제였음! 삭제됨.

    // 안드로이드 기본 플러그인
    id("com.android.application") version "8.1.0" apply false
    
    // 코틀린 플러그인 (버전이 안 맞으면 1.7.10 등으로 낮춰야 할 수도 있음)
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    
    // 구글 서비스 (파이어베이스용) - 이건 꼭 있어야 함!
    id("com.google.gms.google-services") version "4.4.4" apply false
}

include(":app")