buildscript {
    // حدد إصدار Kotlin هنا
    ext.kotlin_version = '1.9.23' 
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // تحديث classpath الخاص بـ Gradle
        classpath 'com.android.tools.build:gradle:8.2.0' 
        // تحديث classpath الخاص بـ Kotlin
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // تحديث classpath الخاص بـ Google Services
        classpath 'com.google.gms:google-services:4.4.2'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
