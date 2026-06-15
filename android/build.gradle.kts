
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            ndkVersion = "28.2.13676358"

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }

            defaultConfig {
                externalNativeBuild {
                    cmake {
                        val cleanCompilerEnvironment = rootProject
                            .file("clean-android-cxx-env.sh")
                            .absolutePath
                        arguments += listOf(
                            "-DCMAKE_C_COMPILER_LAUNCHER=$cleanCompilerEnvironment",
                            "-DCMAKE_CXX_COMPILER_LAUNCHER=$cleanCompilerEnvironment",
                        )
                    }
                }
            }
        }
    }
//    afterEvaluate {
//        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
//            val androidExtension = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
//            if (androidExtension != null && androidExtension.namespace == null) {
//                // Read package from plugin manifest fallback
//                val manifestFile = file("src/main/AndroidManifest.xml")
//                if (manifestFile.exists()) {
//                    try {
//                        val parser = javax.xml.parsers.DocumentBuilderFactory.newInstance().newDocumentBuilder()
//                        val document = parser.parse(manifestFile)
//                        val packageName = document.documentElement.getAttribute("package")
//                        if (!packageName.isNullOrEmpty()) {
//                            androidExtension.namespace = packageName
//                        }
//                    } catch (e: Exception) {
//                        // Suppress parsing errors
//                    }
//                }
//                // Complete catchall fallback logic if package string read failed
//                if (androidExtension.namespace == null) {
//                    androidExtension.namespace = "io.agora.uikit.fallback.${name.replace("-", ".")}"
//                }
//            }
//        }
//    }
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
            val androidExtension = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (androidExtension != null) {

                androidExtension.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                androidExtension.compileOptions.targetCompatibility = JavaVersion.VERSION_17
                androidExtension.defaultConfig.minSdk = 23

                // Automated Namespace configuration logic for AGP 8+ compliance
                if (androidExtension.namespace == null) {
                    val manifestFile = file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        try {
                            val parser = javax.xml.parsers.DocumentBuilderFactory.newInstance().newDocumentBuilder()
                            val document = parser.parse(manifestFile)
                            val packageName = document.documentElement.getAttribute("package")
                            if (!packageName.isNullOrEmpty()) {
                                androidExtension.namespace = packageName
                            }
                        } catch (e: Exception) {
                            // Suppress parsing errors
                        }
                    }
                    if (androidExtension.namespace == null) {
                        androidExtension.namespace = "io.agora.uikit.fallback.${name.replace("-", ".")}"
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
