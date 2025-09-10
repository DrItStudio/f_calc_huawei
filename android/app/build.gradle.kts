import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Загрузка свойств keystore для подписи Huawei
val keystoreProperties = Properties()
val keystorePropertiesFile = File(rootProject.projectDir, "key.properties")

// Загружаем свойства keystore
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ndkVersion = "27.0.12077973"
    namespace = "com.dritstudio.forest_calculator"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Включаем функцию buildConfig для генерации BuildConfig класса
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // ✅ ИСПРАВЛЕНО: Уникальное имя пакета
        applicationId = "com.dritstudio.forest_calculator"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Включаем поддержку multidex для решения проблемы дублированных классов
        multiDexEnabled = true
        
        // Автоматически генерируем BuildConfig
        buildConfigField("String", "HMS_APP_ID", "\"${project.findProperty("hms.app_id") ?: "defaultAppId"}\"")
    }

    // Конфигурация подписи для Huawei AppGallery
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias") ?: "huawei_key"
            keyPassword = keystoreProperties.getProperty("keyPassword") ?: "123456"
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) } ?: file("huawei-keystore.jks")
            storePassword = keystoreProperties.getProperty("storePassword") ?: "123456"
        }
    }

    buildTypes {
        release {
            // Отключаем подпись для создания неподписанного AAB для AppGallery
            // signingConfig = signingConfigs.getByName("release")
            
            // ВКЛЮЧАЕМ минификацию с правилами ProGuard для HMS SDK
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Правила Proguard/R8 для правильной работы HMS SDK (КРИТИЧЕСКИ ВАЖНО)
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        
        debug {
            // Debug использует debug подпись
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
dependencies {
    // Поддержка multidex для решения проблемы дублированных классов
    implementation("androidx.multidex:multidex:2.0.1")

    // Локальные AAR из папки libs (если вы положите appupdate/update-sdk сюда)
    implementation(fileTree(mapOf(
        "dir" to "libs",
        "include" to listOf("*.aar")
    )))
    
    // 🚨🚨🚨 HMS Core SDK ДЛЯ checkUpdate API - ОФИЦИАЛЬНАЯ РЕАЛИЗАЦИЯ 🚨🚨🚨
    // HUAWEI MODERATION: Эти зависимости содержат требуемый checkUpdate API
    implementation("com.huawei.hms:base:6.9.0.300")
    implementation("com.huawei.hms:network-common:5.0.10.302")
    implementation("com.huawei.agconnect:agconnect-core:1.9.1.300")
    
    // 🔥 ДОПОЛНИТЕЛЬНЫЕ HMS SDK ДЛЯ ПОЛНОЙ ПОДДЕРЖКИ checkUpdate API
    implementation("com.huawei.hms:hianalytics:6.9.0.300")
    
    // Зависимости для рекламы HMS Ads
    implementation("com.huawei.hms:ads-lite:13.4.77.300")
    implementation("com.huawei.hms:ads-consent:3.4.77.300")
    implementation("com.huawei.hms:ads-vast:3.4.44.303")
    implementation("com.huawei.hms:ads-vast-player:3.4.44.303")
    
    // HMS IAP для работы с покупками и подписками
    implementation("com.huawei.hms:iap:6.3.0.300")
    
    // Примечание: appservice/update берём из локальных AAR (android/app/libs),
    // чтобы избежать дублирования классов удаляем Maven-версии
    
    // HMS AppUpdate SDK не добавляем напрямую, используем рефлексию (см. MainActivity)
    
    // Добавляем Conscrypt для поддержки сетевых операций
    implementation("org.conscrypt:conscrypt-android:2.5.2")
    
    // Добавляем Cronet зависимость для решения проблемы с missing classes
    implementation("org.chromium.net:cronet-embedded:76.3809.111")
}

flutter {
    source = "../.."
}

// Optional: Task to pull specific AARs via Gradle and copy them into libs
// Usage: gradlew :app:fetchHmsAars
tasks.register<Copy>("fetchHmsAars") {
    val tmp by lazy { File(buildDir, "tmp/hmsAars") }
    from(provider {
        val cfg = configurations.detachedConfiguration(
            dependencies.create("com.huawei.hms:appupdate:6.11.0.302"),
            dependencies.create("com.huawei.updatesdk:update-sdk:3.1.2.300")
        )
        cfg.isTransitive = false
        cfg.resolve().map { it }
    })
    into(tmp)
    doLast {
        val libsDir = File(projectDir, "libs")
        if (!libsDir.exists()) libsDir.mkdirs()
        tmp.listFiles()?.forEach { f ->
            if (f.name.endsWith(".aar")) {
                f.copyTo(File(libsDir, f.name), overwrite = true)
                println("Copied ${'$'}{f.name} to libs/")
            }
        }
    }
}

// Auto-fetch Huawei update-sdk (tries several versions) before build if not already present.
tasks.register("autoFetchHuaweiUpdateSdk") {
    doLast {
        val libsDir = File(projectDir, "libs")
        if (!libsDir.exists()) libsDir.mkdirs()
        val already = libsDir.listFiles()?.any { it.name.startsWith("update-sdk-") || it.name.startsWith("appupdate-") } ?: false
        if (already) {
            println("[autoFetchHuaweiUpdateSdk] AAR already present, skip.")
            return@doLast
        }
        val versions = listOf("3.1.2.300","3.1.0.300","3.0.2.300","3.0.1.300")
        var fetched = false
        for (v in versions) {
            try {
                println("[autoFetchHuaweiUpdateSdk] Try version $v")
                val cfg = configurations.detachedConfiguration(
                    dependencies.create("com.huawei.updatesdk:update-sdk:$v")
                )
                cfg.isTransitive = false
                val files = cfg.resolve()
                files.forEach { f ->
                    if (f.name.endsWith(".aar")) {
                        f.copyTo(File(libsDir, f.name), overwrite = true)
                        println("[autoFetchHuaweiUpdateSdk] Downloaded ${f.name}")
                        fetched = true
                    }
                }
                if (fetched) break
            } catch (e: Exception) {
                println("[autoFetchHuaweiUpdateSdk] Version $v not found: ${e.message}")
            }
        }
        if (!fetched) {
            println("[autoFetchHuaweiUpdateSdk] No versions fetched. Ensure VPN access to Huawei repos and rebuild.")
        }
    }
}

// Ensure fetch runs before compilation so the AAR is on classpath via fileTree
tasks.matching { it.name == "preBuild" }.configureEach {
    dependsOn("autoFetchHuaweiUpdateSdk")
}
