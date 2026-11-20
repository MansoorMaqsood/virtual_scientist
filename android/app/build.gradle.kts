plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


dependencies {
 implementation(project(":unityLibrary")) 

    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    implementation("com.google.firebase:firebase-analytics")
     implementation("androidx.annotation:annotation:1.9.1")
    // Add more Firebase modules if needed
}

android {
    namespace = "com.example.virtual_scientist"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    defaultConfig {
        applicationId = "com.example.virtual_scientist"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
  ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }
 sourceSets {
        getByName("main") {
            jniLibs.srcDirs("../unityLibrary/src/main/jniLibs")
        }
    }
sourceSets["main"].java.srcDirs("src/main/java")
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("debug") {
            // Keep debug builds simple
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
        isShrinkResources = true
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android.txt"),
            "proguard-rules.pro"
        )
    }
    }
}

flutter {
    source = "../.."
}
