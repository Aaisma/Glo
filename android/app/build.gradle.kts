plugins {
    id("com.android.application")
<<<<<<< HEAD
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
=======
    // FlutterFire Configuration
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
>>>>>>> b7a7f4b5c1b50b82a24e5667b8b9a51d459ff70c
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.glo.glo"   // keep consistent with your manifest
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Use Java 17 for source/target compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
<<<<<<< HEAD
=======
        // Unique Application ID
>>>>>>> b7a7f4b5c1b50b82a24e5667b8b9a51d459ff70c
        applicationId = "com.example.glo.glo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
=======
            // Signing with debug keys for now so `flutter run --release` works
>>>>>>> b7a7f4b5c1b50b82a24e5667b8b9a51d459ff70c
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
