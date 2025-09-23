plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin ska ligga efter Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tipsypal.app"
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
        applicationId = "com.tipsypal.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Om du behöver multidex:
        // multiDexEnabled = true
    }

    // 🔑 SIGNERING (läser från gradle.properties)
    signingConfigs {
        create("release") {
            val ksFile = project.findProperty("MY_KEYSTORE") as String?
            val ksPass = project.findProperty("MY_KEYSTORE_PASSWORD") as String?
            val keyAlias = project.findProperty("MY_KEY_ALIAS") as String?
            val keyPass = project.findProperty("MY_KEY_PASSWORD") as String?

            if (ksFile != null && ksPass != null && keyAlias != null && keyPass != null) {
                storeFile = file(ksFile)
                storePassword = ksPass
                this.keyAlias = keyAlias
                keyPassword = keyPass
            } else {
                println("⚠️ Release-signering är inte konfigurerad. Kontrollera android/gradle.properties.")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // Debug kör som vanligt med debug-nycklar
        }
        getByName("release") {
            isMinifyEnabled = false      // sätt true + proguard-files om/ när du vill krympa
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }

    // (valfritt) städa bort vissa META-INF för kompatibilitet
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

flutter {
    source = "../.."
}

// Här brukar man inte behöva lägga till extra dependencies manuellt – Flutter hanterar
// det via .gradle/.m2. Om du absolut behöver något extra, gör det så här:
// dependencies {
//     implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
// }

