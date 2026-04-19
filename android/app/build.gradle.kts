import groovy.json.JsonSlurper

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.germana"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.germana"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // One-key workflow: read from Gradle property / env var / local .env.json.
        val envJsonKey = run {
            val candidates = listOf(
                // Android root (android/.env.json)
                rootProject.file(".env.json"),
                // Workspace root (../.env.json)
                rootProject.file("../.env.json"),
            )

            val envFile = candidates.firstOrNull { it.exists() }
            if (envFile == null) {
                null
            } else {
                val parsed = JsonSlurper().parseText(envFile.readText()) as? Map<*, *>
                parsed?.get("GOOGLE_MAPS_API_KEY")?.toString()
            }
        }

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] =
            listOf(
                project.findProperty("GOOGLE_MAPS_API_KEY") as String?,
                System.getenv("GOOGLE_MAPS_API_KEY"),
                envJsonKey,
            ).firstOrNull { !it.isNullOrBlank() } ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
