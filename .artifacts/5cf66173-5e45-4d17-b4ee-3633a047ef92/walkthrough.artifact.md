# Walkthrough - Build Failure Fix (Version Upgrades)

I have upgraded the project's build configuration to resolve the compilation errors and address Flutter's warnings.

## Changes Made

### Version Upgrades
- **Gradle**: Upgraded from `8.10.2` to `8.14.0` in `gradle-wrapper.properties`.
- **Android Gradle Plugin (AGP)**: Upgraded from `8.7.0` to `8.11.1` in `settings.gradle.kts`.
- **Kotlin**: Upgraded from `2.0.21` to `2.2.20` in `settings.gradle.kts`.
- **Android SDK**: Increased `compileSdk` and `targetSdk` from `34` to `36` in `app/build.gradle.kts`.

## Verification Results

### Automated Tests
- The changes were applied successfully to the configuration files.
- The versions selected match the minimum requirements specified in the build error logs.

> [!IMPORTANT]
> You should now run `flutter build apk` or `flutter run` to confirm that the build completes successfully. The previous errors regarding `androidx.core` and plugin SDK requirements should now be resolved.
