plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

val productionKeystorePath = System.getenv("ATHAAR_KEYSTORE_PATH")
val productionKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
val productionKeystorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
val productionKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")
val requireProductionSigning = System.getenv("ATHAAR_REQUIRE_PRODUCTION_SIGNING") == "true"

if (requireProductionSigning && productionKeystorePath.isNullOrBlank()) {
    throw GradleException("Production signing is required but ATHAAR_KEYSTORE_PATH is missing.")
}

android {
    namespace = "com.athaar.athaar"
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Confirm ownership/availability of this application ID before first Play submission.
        applicationId = "com.athaar.athaar"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (!productionKeystorePath.isNullOrBlank()) {
            create("productionRelease") {
                storeFile = file(productionKeystorePath)
                keyAlias = productionKeyAlias
                    ?: throw GradleException("ANDROID_KEY_ALIAS is missing.")
                storePassword = productionKeystorePassword
                    ?: throw GradleException("ANDROID_KEYSTORE_PASSWORD is missing.")
                keyPassword = productionKeyPassword
                    ?: throw GradleException("ANDROID_KEY_PASSWORD is missing.")
            }
        }
    }

    buildTypes {
        release {
            // CI's ordinary test-release is debug-signed. The production workflow sets
            // ATHAAR_REQUIRE_PRODUCTION_SIGNING=true and injects a privately stored key.
            signingConfig = if (!productionKeystorePath.isNullOrBlank()) {
                signingConfigs.getByName("productionRelease")
            } else {
                signingConfigs.getByName("debug")
            }
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
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
