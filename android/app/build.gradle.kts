plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.gas_monitor"
    
    // --- SỬA LẠI ĐOẠN NÀY (Ép lên bản 34) ---
    compileSdk = 34 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 🔧 BẬT DESUGARING CHO ANDROID CŨ
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.gas_monitor"
        
        // --- SỬA LẠI ĐOẠN NÀY ---
        minSdk = flutter.minSdkVersion      // Thư viện mới cần tối thiểu 23
        targetSdk = 34   // Ép lên bản 34
        // -------------------------
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // 🔧 Desugaring library cho Android cũ
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
