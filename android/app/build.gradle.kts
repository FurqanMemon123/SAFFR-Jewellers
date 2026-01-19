plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.jewellery_app"
    compileSdk = 36  // <--- CHANGED: 34 se 35 kar diya (Latest Libraries ke liye)
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.jewellery_app"

        // ML Kit aur Stripe ke liye 21 theek hai
        minSdk = flutter.minSdkVersion
        targetSdk = 36 // <--- CHANGED: Isay bhi 35 kar diya
        
        // Fixed Versions
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        // SDK 35 ke liye Java 17 behtar hai
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")
    
    // Desugaring fixed
    add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:2.0.4")
}


// ... Upar ka sara code wesa hi rehne den ...

// File ke bilkul end mein yeh add karen:
// Yeh code end mein hona chahiye:
configurations.all {
    resolutionStrategy {
        force("androidx.activity:activity:1.9.3")
        force("androidx.activity:activity-ktx:1.9.3")
        force("androidx.activity:activity-compose:1.9.3")
    }
}