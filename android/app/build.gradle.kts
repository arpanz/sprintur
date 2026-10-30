import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing comes from android/key.properties locally, or from the
// SPRINTUR_KEYSTORE_* environment variables in CI. Without either, release
// builds fall back to the debug key so `flutter run --release` still works.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
fun signingValue(property: String, env: String): String? =
    (keyProperties.getProperty(property) ?: System.getenv(env))?.takeIf { it.isNotBlank() }
val releaseStoreFile = signingValue("storeFile", "SPRINTUR_KEYSTORE_PATH")

android {
    namespace = "com.livinlabs.sprintur"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications needs java.time on older Android.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.livinlabs.sprintur"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseStoreFile != null) {
            create("release") {
                storeFile = file(releaseStoreFile)
                val password = signingValue("storePassword", "SPRINTUR_KEYSTORE_PASSWORD")
                storePassword = password
                // A PKCS12 keystore has one password, so the key's defaults
                // to the store's.
                keyAlias = signingValue("keyAlias", "SPRINTUR_KEY_ALIAS") ?: "sprintur"
                keyPassword = signingValue("keyPassword", "SPRINTUR_KEY_PASSWORD") ?: password
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
