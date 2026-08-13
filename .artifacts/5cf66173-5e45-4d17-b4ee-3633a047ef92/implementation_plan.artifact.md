# Implementation Plan - Fix Build Failure by Upgrading Gradle and Android SDK Versions

The project is currently failing to build because several dependencies (including `androidx.core` and various Flutter plugins) require a higher `compileSdk` version (35 or 36) than the current 34. Additionally, Flutter is warning about outdated Gradle, Android Gradle Plugin (AGP), and Kotlin versions.

## Proposed Changes

### [Component] Gradle Configuration

#### [MODIFY] [gradle-wrapper.properties](file:///C:/Users/PAVILION/Desktop/Robox/android/gradle/wrapper/gradle-wrapper.properties)
- Upgrade `distributionUrl` from `gradle-8.10.2-all.zip` to `gradle-8.14.0-all.zip` as recommended by the Flutter build log.

### [Component] Android Project Configuration

#### [MODIFY] [settings.gradle.kts](file:///C:/Users/PAVILION/Desktop/Robox/android/settings.gradle.kts)
- Upgrade `com.android.application` plugin version from `8.7.0` to `8.11.1`.
- Upgrade `org.jetbrains.kotlin.android` plugin version from `2.0.21` to `2.2.20`.

#### [MODIFY] [app/build.gradle.kts](file:///C:/Users/PAVILION/Desktop/Robox/android/app/build.gradle.kts)
- Update `compileSdk` to `36`.
- Update `targetSdk` to `36` to maintain consistency with the new `compileSdk`.

## Verification Plan

### Automated Tests
- I cannot run a full build here, but I will verify the file changes are correct.
- The user should run `flutter build apk` or `flutter run` to verify the build now succeeds.

### Manual Verification
- Verify that the versions in the modified files match the recommendations in the error log.
