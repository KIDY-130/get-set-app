plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.4" 
}

android {
    namespace = "com.example.GET_SET_APP"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.GET_SET_APP"
        
        // 👇 [중요] 파이어베이스 사용을 위해 21로 변경했습니다!
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 1. 파이어베이스 BoM
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))

    // 2. 기본 기능 (Analytics)
    implementation("com.google.firebase:firebase-analytics")

    // 3. 로그인 기능 (Auth)
    implementation("com.google.firebase:firebase-auth")
}
