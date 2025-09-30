// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin (AGP integration)
    id("dev.flutter.flutter-gradle-plugin")
}

// Om du kör en äldre struktur kan du behöva flutter { source = "../.." } (se längst ned)

android {
    namespace = "com.tipsypal.app"

    // Läs versioner från Flutter (exponeras av flutter-gradle-plugin)
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.tipsypal.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // multiDexEnabled = true // aktivera om du behöver det senare
    }

    // ✅ Pinna NDK r26d (löser CMake/Clang-problemet på Windows)
    ndkVersion = "26.3.11579264"

    // ✅ Tvinga CMake 3.22.1 även om nyare finns
    externalNativeBuild {
        cmake {
            version = "3.22.1"
        }
    }

    // ✅ Java/Kotlin 17 (krävs av modern AGP/Flutter)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // 🔑 SIGNERING (valfritt — funkar även tomt i debug)
    signingConfigs {
        create("release") {
            val ksPath   = project.findProperty("MY_KEYSTORE") as String?
            val ksPass   = project.findProperty("MY_KEYSTORE_PASSWORD") as String?
            val alias    = project.findProperty("MY_KEY_ALIAS") as String?
            val keyPass  = project.findProperty("MY_KEY_PASSWORD") as String?

            if (!ksPath.isNullOrBlank() && !ksPass.isNullOrBlank() && !alias.isNullOrBlank() && !keyPass.isNullOrBlank()) {
                storeFile = file(ksPath)
                storePassword = ksPass
                this.keyAlias = alias
                keyPassword = keyPass
            } else {
                println("⚠️ Release-signering ej konfigurerad (android/gradle.properties). Debug funkar ändå.")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // standard debug
        }
        getByName("release") {
            isMinifyEnabled = false       // sätt true + proguard om/ när du vill krympa
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // (valfritt) rensa vissa META-INF för konflikter
    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

// Tala om var Flutter-modulen ligger (behövs i typiska Flutter-appar)
flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}


